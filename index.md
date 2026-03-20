---
layout: default
title: Music Engineering Portfolio
---

{% assign sorted = site.projects | sort: "publish_date" | reverse %}
{% assign all_tags = "" | split: "" %}
{% for project in sorted %}
  {% if project.tags %}
    {% assign all_tags = all_tags | concat: project.tags %}
  {% endif %}
{% endfor %}
{% assign all_tags = all_tags | uniq | sort %}

<section class="container stack">
  <p class="meta">Student showcase</p>
  <h1>Music Engineering Portfolio</h1>
  <p class="meta">Explore standout work across production, DSP, and creative audio technology.</p>
  <div>
    <a class="button-link" href="https://github.com/MUEatTheU/music-engineering-portfolio/new/main/_projects?filename=your-project.md&value=---%0Alayout%3A%20project%0Atitle%3A%20%22Project%20Title%22%0Astudent_name%3A%20%22Your%20Name%22%0Astudent_slug%3A%20%22your-name%22%0Acategory%3A%20%22Category%22%0Atags%3A%0A%20%20-%20tag-one%0A%20%20-%20tag-two%0Ashort_blurb%3A%20%22One%20sentence%20summary.%22%0Athumbnail_image%3A%20%22%2Fassets%2Fimages%2Fprojects%2Fyour-image.jpg%22%0Afull_description%3A%20%22Describe%20your%20project%20in%20detail.%22%0Arepo_url%3A%20%22%22%0Ademo_url%3A%20%22%22%0Afeatured%3A%20false%0Apublish_date%3A%202026-03-20%0A---%0A">Submit Project</a>
  </div>
</section>

<section class="container section stack">
  <h2>Featured Projects</h2>
  {% assign has_featured = false %}
  <div class="grid grid-featured">
  {% for project in sorted %}
    {% if project.featured %}
      {% assign has_featured = true %}
      <div class="card card-featured">
        <a class="card-media" href="{{ project.url | relative_url }}">
          <img src="{{ project.thumbnail_image | relative_url }}" alt="{{ project.title | escape }}">
        </a>
        <div class="card-body">
          <h3 class="card-title">
            <a href="{{ project.url | relative_url }}">{{ project.title }}</a>
          </h3>
          <p class="meta">
            <a href="{{ '/students/' | append: project.student_slug | append: '/' | relative_url }}">{{ project.student_name }}</a>
            •
            {% assign cat_slug = project.category | slugify %}
            <a href="{{ '/categories/' | append: cat_slug | append: '/' | relative_url }}">{{ project.category }}</a>
          </p>
          <p class="card-description">{{ project.short_blurb }}</p>
        </div>
      </div>
    {% endif %}
  {% endfor %}
  </div>
  {% unless has_featured %}
    <p class="meta">No featured projects yet.</p>
  {% endunless %}
</section>

<section class="container section stack">
  <h2>Browse All Projects</h2>
  <div>
    <p class="meta">Filter by tag:</p>
    <a href="#" class="tag-filter-link is-active" data-tag="all">All</a>
    {% for tag in all_tags %}
      <a href="#" class="tag-filter-link" data-tag="{{ tag | downcase }}">{{ tag }}</a>
    {% endfor %}
  </div>

  <div class="grid" id="projects-grid">
  {% for project in sorted %}
    {% unless project.featured %}
      {% assign project_tags = project.tags | default: "" | join: "," | downcase %}
      <div class="card" data-tags="{{ project_tags }}">
        <a class="card-media" href="{{ project.url | relative_url }}">
          <img src="{{ project.thumbnail_image | relative_url }}" alt="{{ project.title | escape }}">
        </a>
        <div class="card-body">
          <h3 class="card-title">
            <a href="{{ project.url | relative_url }}">{{ project.title }}</a>
          </h3>
          <p class="meta">
            <a href="{{ '/students/' | append: project.student_slug | append: '/' | relative_url }}">{{ project.student_name }}</a>
            •
            {% assign cat_slug = project.category | slugify %}
            <a href="{{ '/categories/' | append: cat_slug | append: '/' | relative_url }}">{{ project.category }}</a>
          </p>
          <p class="card-description">{{ project.short_blurb }}</p>
          {% if project.tags %}
            <p class="meta">
              Tags:
              {% for tag in project.tags %}
                <span>{{ tag }}</span>{% unless forloop.last %}, {% endunless %}
              {% endfor %}
            </p>
          {% endif %}
        </div>
      </div>
    {% endunless %}
  {% endfor %}
  </div>
</section>

<script>
  (function () {
    var links = document.querySelectorAll('.tag-filter-link');
    var cards = document.querySelectorAll('#projects-grid .card');

    function setActive(link) {
      links.forEach(function (item) {
        item.classList.remove('is-active');
      });
      link.classList.add('is-active');
    }

    function filterCards(tag) {
      cards.forEach(function (card) {
        var tags = card.getAttribute('data-tags') || '';
        var matches = tag === 'all' || tags.split(',').indexOf(tag) !== -1;
        card.style.display = matches ? '' : 'none';
      });
    }

    links.forEach(function (link) {
      link.addEventListener('click', function (event) {
        event.preventDefault();
        var tag = link.getAttribute('data-tag');
        setActive(link);
        filterCards(tag);
      });
    });
  })();
</script>
