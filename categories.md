---
layout: default
title: Categories
---

<h1>Categories</h1>

<ul>
{% assign categories = site.projects | map: "category" | uniq %}
{% for category in categories %}
  {% assign cat_slug = category | slugify %}
  <li>
    <a href="{{ '/categories/' | append: cat_slug | append: '/' | relative_url }}">
      {{ category }}
    </a>
  </li>
{% endfor %}
</ul>

<p><a href="{{ '/' | relative_url }}">← Back to Home</a></p>
