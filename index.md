---
layout: default
title: Music Engineering Portfolio
---

{% assign sorted = site.projects | sort: "publish_date" | reverse %}
{% assign featured_projects = sorted | where_exp: "project", "project.featured" %}
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
</section>

{% if featured_projects.size > 0 %}
<section class="container section stack">
  {% if featured_projects.size == 1 %}
    <h2>Featured Project</h2>
  {% else %}
    <h2>Featured Projects</h2>
  {% endif %}
  <div class="grid grid-featured">
  {% for project in featured_projects %}
      <div class="card card-featured">
        <a class="card-media" href="{{ project.url | relative_url }}">
          <img src="{{ project.thumbnail_image | relative_url }}" alt="{{ project.title | escape }}">
        </a>
        <div class="card-body">
          <h3 class="card-title">
            <a href="{{ project.url | relative_url }}">{{ project.title }}</a>
          </h3>
          <p class="meta">
            <a href="{{ '/students/' | append: project.student_slug | relative_url }}">{{ project.student_name }}</a>
            •
            {% assign cat_slug = project.category | slugify %}
            Project Type:
            <a href="{{ '/categories/' | append: cat_slug | relative_url }}">{{ project.category }}</a>
          </p>
          <p class="card-description">{{ project.short_blurb }}</p>
        </div>
      </div>
  {% endfor %}
  </div>
</section>
{% endif %}

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
          <a href="{{ '/students/' | append: project.student_slug | relative_url }}">{{ project.student_name }}</a>
          •
          {% assign cat_slug = project.category | slugify %}
          Project Type:
          <a href="{{ '/categories/' | append: cat_slug | relative_url }}">{{ project.category }}</a>
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
