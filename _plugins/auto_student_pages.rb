require "cgi"

module Jekyll
  class AutoStudentPages < Generator
    safe true
    priority :low

    def generate(site)
      projects = site.collections.fetch("projects", nil)&.docs || []
      return if projects.empty?

      grouped = {}

      projects.each do |project|
        slug = project.data["student_slug"].to_s.strip
        name = project.data["student_name"].to_s.strip
        next if slug.empty?

        grouped[slug] ||= { "name" => (name.empty? ? titleize_slug(slug) : name), "projects" => [] }
        grouped[slug]["projects"] << project
      end

      grouped.each do |slug, entry|
        site.pages << GeneratedStudentPage.new(site, slug, entry["name"], entry["projects"])
      end
    end

    private

    def titleize_slug(slug)
      slug.split("-").map(&:capitalize).join(" ")
    end
  end

  class GeneratedStudentPage < Page
    def initialize(site, slug, student_name, projects)
      @site = site
      @base = site.source
      @dir = File.join("students", slug)
      @name = "index.html"

      process(@name)

      self.data = {
        "layout" => "default",
        "title" => "#{student_name} | Music Engineering Portfolio"
      }
      self.content = build_content(slug, student_name, projects)
    end

    private

    def build_content(slug, student_name, projects)
      sorted_projects = projects.sort_by { |project| project.data["publish_date"].to_s }.reverse
      lines = []
      lines << "<section class=\"stack\">"
      lines << "  <p class=\"meta\">Student Profile</p>"
      lines << "  <h1>#{h(student_name)}</h1>"
      lines << "</section>"
      lines << ""
      lines << "<section class=\"section stack\">"
      lines << "  <h2>Projects</h2>"
      lines << "  <div class=\"grid\">"

      sorted_projects.each do |project|
        title = project.data["title"].to_s
        category = project.data["category"].to_s
        blurb = project.data["short_blurb"].to_s
        image = project.data["thumbnail_image"].to_s
        project_url = with_base(project.url.to_s)
        category_url = with_base("/categories/#{Utils.slugify(category)}/")

        lines << "    <div class=\"card\">"
        lines << "      <a class=\"card-media\" href=\"#{h(project_url)}\">"
        lines << "        <img src=\"#{h(with_base(image))}\" alt=\"#{h(title)}\">"
        lines << "      </a>"
        lines << "      <div class=\"card-body\">"
        lines << "        <h3 class=\"card-title\"><a href=\"#{h(project_url)}\">#{h(title)}</a></h3>"
        lines << "        <p class=\"meta\">Project Type: <a href=\"#{h(category_url)}\">#{h(category)}</a></p>"
        lines << "        <p class=\"card-description\">#{h(blurb)}</p>"
        lines << "      </div>"
        lines << "    </div>"
      end

      lines << "  </div>"
      lines << "  <p class=\"meta\"><a href=\"#{with_base('/students/')}\">← Back to Students</a> • <a href=\"#{with_base('/')}\">Home</a></p>"
      lines << "</section>"
      lines.join("\n")
    end

    def with_base(path)
      return path if @site.baseurl.to_s.empty?
      "#{@site.baseurl}#{path}"
    end

    def h(value)
      CGI.escapeHTML(value.to_s)
    end
  end
end
