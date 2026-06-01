#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"

ROOT = File.expand_path("..", __dir__)
PROJECTS_DIR = File.join(ROOT, "_projects")
ALLOWED_CATEGORIES = ["Research", "Recording", "Project", "Capstone", "Demo"].freeze
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
thumbnail_filename = "replace-with-thumbnail.jpg" if thumbnail_filename.empty?

full_description = normalize_asset_paths(fields.fetch("full_description", "").strip)
full_description = "Describe this project." if full_description.empty?

project_slug = slugify(project_title)
output_path = unique_project_path(project_slug)

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
  "Maintainer image checklist:",
  "- Download the issue attachments.",
  "- Add them to assets/images/projects/.",
  "- Confirm thumbnail_image points to the correct file.",
  "- Add any inline image Markdown to full_description if needed.",
  "",
  "Submitted image notes:",
  fields.fetch("images", "").strip,
  "",
  "Submitted image placement notes:",
  fields.fetch("image_placement_notes", "").strip,
  "-->",
  ""
].flatten.join("\n")

File.write(output_path, front_matter)
puts "Created #{output_path.sub("#{ROOT}/", "")}"
