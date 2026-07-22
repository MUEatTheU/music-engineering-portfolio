#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "net/http"
require "uri"

ROOT = File.expand_path("..", __dir__)
PROJECTS_DIR = File.join(ROOT, "_projects")
IMAGES_DIR = File.join(ROOT, "assets", "images", "projects")
ALLOWED_CATEGORIES = ["Research", "Recording", "Project", "Capstone", "Demo"].freeze
ALLOWED_ATTACHMENT_HOSTS = [
  "github.com",
  "private-user-images.githubusercontent.com",
  "user-images.githubusercontent.com"
].freeze
ALLOWED_IMAGE_TYPES = {
  "image/gif" => ".gif",
  "image/jpeg" => ".jpg",
  "image/png" => ".png",
  "image/webp" => ".webp"
}.freeze
MAX_IMAGE_BYTES = 15 * 1024 * 1024
ISSUE_FIELD_LABELS = [
  "Student name",
  "Student slug",
  "Project title",
  "Course",
  "Project type",
  "Tags",
  "Repository URL",
  "Demo URL",
  "Short blurb",
  "Full description",
  "Thumbnail image filename",
  "Images",
  "Image placement notes",
  "Final checklist"
].freeze

def slugify(text)
  text.to_s.downcase.strip
      .gsub(/[^a-z0-9\s-]/, "")
      .gsub(/\s+/, "-")
      .gsub(/-+/, "-")
      .gsub(/\A-|-+\z/, "")
end

def clean_issue_value(value)
  cleaned = value.to_s.strip
  return "" if cleaned == "_No response_"

  cleaned
end

def issue_sections(body)
  sections = {}
  labels_pattern = ISSUE_FIELD_LABELS.map { |label| Regexp.escape(label) }.join("|")

  body.to_s.scan(/^###\s+(#{labels_pattern})\s*\n+(.*?)(?=^###\s+(?:#{labels_pattern})\s*$|\z)/m) do |label, value|
    key = label.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
    sections[key] = clean_issue_value(value)
  end

  sections
end

def basename_only(filename)
  ascii = filename.to_s.strip.encode("ASCII", invalid: :replace, undef: :replace, replace: "")
  File.basename(ascii).gsub(/[^A-Za-z0-9._-]/, "-").gsub(/-+/, "-").gsub(/-+\z/, "")
end

def yaml_string(value)
  value.to_s.inspect
end

def yaml_block(key, value)
  lines = value.to_s.strip.split("\n")
  lines = [""] if lines.empty?

  ([%Q(#{key}: |-)] + lines.map { |line| "  #{line}" }).join("\n")
end

def normalize_asset_paths(markdown)
  markdown.to_s.gsub("](assets/images/projects/", "](/assets/images/projects/")
end

def github_attachment?(url)
  uri = URI.parse(url)
  return false unless uri.is_a?(URI::HTTPS)
  return false unless ALLOWED_ATTACHMENT_HOSTS.include?(uri.host)

  uri.host != "github.com" || uri.path.start_with?("/user-attachments/assets/")
rescue URI::InvalidURIError
  false
end

def trusted_attachment_redirect?(url)
  return true if github_attachment?(url)

  uri = URI.parse(url)
  uri.is_a?(URI::HTTPS) && uri.host.to_s.match?(/\Agithub-production-user-asset-[a-z0-9]+\.s3\.amazonaws\.com\z/)
rescue URI::InvalidURIError
  false
end

def extract_attachments(markdown)
  markdown.to_s.scan(/!\[[^\]]*\]\(https:\/\/[^\s\)]+\)|<img\b[^>]*>/i).filter_map do |tag|
    if tag.start_with?("![")
      match = tag.match(/!\[([^\]]*)\]\((https:\/\/[^\s\)]+)\)/)
      alt = match[1]
      url = match[2]
    else
      url = tag[/\bsrc=["'](https:\/\/[^"']+)["']/i, 1]
      alt = tag[/\balt=["']([^"']*)["']/i, 1].to_s
    end
    next unless url && github_attachment?(url)

    { alt: alt.strip, url: url }
  end
end

def image_filenames(text)
  text.to_s.scan(/\b[A-Za-z0-9][A-Za-z0-9._-]*\.(?:gif|jpe?g|png|webp)\b/i).map do |filename|
    basename_only(filename)
  end.uniq
end

def fetch_image(url, redirect_limit = 5)
  raise "Too many redirects while downloading #{url}" if redirect_limit.zero?

  uri = URI.parse(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "music-engineering-portfolio-project-importer"
  token = ENV.fetch("GH_TOKEN", "").strip
  request["Authorization"] = "Bearer #{token}" if !token.empty? && uri.host == "github.com"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    http.open_timeout = 15
    http.read_timeout = 60
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    content_type = response["content-type"].to_s.split(";").first
    extension = ALLOWED_IMAGE_TYPES[content_type]
    raise "Unsupported attachment type #{content_type.inspect} for #{url}" unless extension
    raise "Attachment exceeds 15 MB: #{url}" if response.body.bytesize > MAX_IMAGE_BYTES

    [response.body, extension]
  when Net::HTTPRedirection
    redirect_url = URI.join(url, response.fetch("location")).to_s
    raise "Untrusted attachment redirect: #{redirect_url}" unless trusted_attachment_redirect?(redirect_url)

    fetch_image(redirect_url, redirect_limit - 1)
  else
    raise "Could not download attachment #{url}: HTTP #{response.code}"
  end
end

def filename_with_extension(filename, fallback, extension)
  cleaned = basename_only(filename)
  cleaned = fallback if cleaned.empty?
  current_extension = File.extname(cleaned).downcase
  cleaned = "#{File.basename(cleaned, ".*")}#{extension}" unless current_extension == extension
  cleaned
end

def unique_image_path(filename)
  stem = File.basename(filename, ".*")
  extension = File.extname(filename)
  path = File.join(IMAGES_DIR, filename)
  counter = 2

  while File.exist?(path)
    path = File.join(IMAGES_DIR, "#{stem}-#{counter}#{extension}")
    counter += 1
  end

  path
end

def same_filename?(left, right)
  File.basename(left.to_s, ".*").downcase == File.basename(right.to_s, ".*").downcase
end

def requested_paragraph_number(notes, filename)
  escaped_filename = Regexp.escape(filename)
  match = notes.to_s.match(
    /#{escaped_filename}.*?after (?:the )?(first|second|third|\d+)(?:st|nd|rd|th)? paragraph/i
  )
  return nil unless match

  { "first" => 1, "second" => 2, "third" => 3 }.fetch(match[1].downcase, match[1].to_i)
end

def insert_after_paragraph(markdown, image_markdown, paragraph_number)
  sections = markdown.to_s.split(/\n{2,}/)
  insert_index = [paragraph_number, sections.length].min
  sections.insert(insert_index, image_markdown)
  sections.join("\n\n")
end

def download_attachments(attachments, project_slug, requested_thumbnail, requested_filenames)
  FileUtils.mkdir_p(IMAGES_DIR)
  downloaded = []
  remaining_names = requested_filenames.reject { |filename| same_filename?(filename, requested_thumbnail) }

  attachments.uniq { |attachment| attachment[:url] }.each_with_index do |attachment, index|
    body, extension = fetch_image(attachment[:url])
    thumbnail_match = !requested_thumbnail.empty? && same_filename?(attachment[:alt], requested_thumbnail)
    requested_name = if thumbnail_match || (index.zero? && !requested_thumbnail.empty?)
                       requested_thumbnail
                     elsif !remaining_names.empty?
                       remaining_names.shift
                     else
                       attachment[:alt]
                     end
    fallback_name = "#{project_slug}-image-#{index + 1}"
    filename = filename_with_extension(requested_name, fallback_name, extension)
    path = unique_image_path(filename)
    File.binwrite(path, body)
    downloaded << attachment.merge(
      filename: File.basename(path),
      requested_filename: filename,
      site_path: "/assets/images/projects/#{File.basename(path)}",
      thumbnail: thumbnail_match || (index.zero? && !requested_thumbnail.empty?)
    )
  end

  downloaded
end

def unique_project_path(base_slug)
  slug = base_slug.empty? ? "student-project" : base_slug
  path = File.join(PROJECTS_DIR, "#{slug}.md")
  counter = 2

  while File.exist?(path)
    path = File.join(PROJECTS_DIR, "#{slug}-#{counter}.md")
    counter += 1
  end

  path
end

issue_json_path = ARGV.fetch(0) do
  warn "Usage: ruby scripts/create_project_from_issue.rb issue.json"
  exit 1
end

issue = JSON.parse(File.read(issue_json_path))
fields = issue_sections(issue.fetch("body", ""))

student_name = fields.fetch("student_name", "").strip
project_title = fields.fetch("project_title", "").strip
student_slug = fields.fetch("student_slug", "").strip
student_slug = slugify(student_name) if student_slug.empty?
student_slug = slugify(student_slug)

category = fields.fetch("project_type", "").strip
category = "Project" unless ALLOWED_CATEGORIES.include?(category)

tags = fields.fetch("tags", "").split(",").map { |tag| tag.strip.downcase }.reject(&:empty?)
tags = ["audio"] if tags.empty?

thumbnail_filename = basename_only(fields.fetch("thumbnail_image_filename", ""))
if thumbnail_filename.empty?
  thumbnail_filename = fields.fetch("images", "")[/Thumbnail:\s*([^\s,\)]+)/i, 1].to_s
  thumbnail_filename = basename_only(thumbnail_filename)
end

full_description = normalize_asset_paths(fields.fetch("full_description", "").strip)
full_description = "Describe this project." if full_description.empty?

project_slug = slugify(project_title)
output_path = unique_project_path(project_slug)

image_attachments = extract_attachments(fields.fetch("images", ""))
description_attachments = extract_attachments(full_description)
downloaded_images = download_attachments(
  image_attachments + description_attachments,
  project_slug.empty? ? "student-project" : project_slug,
  thumbnail_filename,
  image_filenames(fields.fetch("image_placement_notes", ""))
)

downloaded_images.each do |image|
  full_description = full_description.gsub(image[:url], image[:site_path])
end

thumbnail = downloaded_images.find { |image| image[:thumbnail] } || downloaded_images.first
thumbnail_filename = thumbnail[:filename] if thumbnail
thumbnail_filename = "replace-with-thumbnail.jpg" if thumbnail_filename.empty?

gallery_images = downloaded_images.reject do |image|
  image[:filename] == thumbnail_filename || full_description.include?(image[:site_path])
end
placement_notes = fields.fetch("image_placement_notes", "")
unplaced_images = []
gallery_images.each do |image|
  alt = image[:alt].empty? || image[:alt].casecmp("image").zero? ? File.basename(image[:filename], ".*") : image[:alt]
  image_markdown = "![#{alt}](#{image[:site_path]})"
  paragraph_number = requested_paragraph_number(placement_notes, image[:requested_filename])
  if paragraph_number
    full_description = insert_after_paragraph(full_description, image_markdown, paragraph_number)
  else
    unplaced_images << image_markdown
  end
end
unless unplaced_images.empty?
  full_description = [full_description, "## Project Images", unplaced_images.join("\n\n")].join("\n\n")
end

FileUtils.mkdir_p(PROJECTS_DIR)

front_matter = [
  "---",
  "layout: project",
  "title: #{yaml_string(project_title.empty? ? "Project Title" : project_title)}",
  "student_name: #{yaml_string(student_name.empty? ? "Student Name" : student_name)}",
  "student_slug: #{yaml_string(student_slug.empty? ? "student-name" : student_slug)}",
  "category: #{yaml_string(category)}",
  "tags:",
  tags.map { |tag| "  - #{tag}" },
  "course: #{yaml_string(fields.fetch("course", "").strip)}",
  yaml_block("short_blurb", fields.fetch("short_blurb", "").strip),
  "thumbnail_image: #{yaml_string("/assets/images/projects/#{thumbnail_filename}")}",
  yaml_block("full_description", full_description),
  "repo_url: #{yaml_string(fields.fetch("repository_url", "").strip)}",
  "demo_url: #{yaml_string(fields.fetch("demo_url", "").strip)}",
  "publish_date: #{Date.today.iso8601}",
  "---",
  "",
  "<!--",
  "Generated from issue: #{issue.fetch("url", "")}",
  "",
  "Downloaded images:",
  downloaded_images.map { |image| "- #{image[:filename]}" },
  "",
  "Submitted image placement notes:",
  placement_notes.strip,
  "-->",
  ""
].flatten.join("\n")

File.write(output_path, front_matter)
puts "Created #{output_path.sub("#{ROOT}/", "")}"
