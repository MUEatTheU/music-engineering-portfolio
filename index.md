---
layout: default
title: Music Engineering Portfolio
---

<h1>Music Engineering Portfolio</h1>

<div class="grid">
{% assign sorted = site.projects | sort: "publish_date" | reverse %}
{% for project in sorted %}
  <div class="card">
    <a href="{{ project.url | relative_url }}">
      <img src="{{ project.thumbnail_image | relative_url }}" alt="{{ project.title }}">
      <h3>{{ project.title }}</h3>
    </a>
    <p class="meta">
  <a href="{{ '/students/' | append: project.student_slug | append: '/' | relative_url }}">
  {{ project.student_name }}
</a>
      • 
  {% assign cat_slug = project.category | slugify %}

<a href="{{ '/categories/' | append: cat_slug | relative_url }}">
  {{ project.category }}
</a>

</p>
    <p>{{ project.short_blurb }}</p>
  </div>
{% endfor %}
</div>
