---
layout: default
title: Categories
---

<h1>Categories</h1>

<ul>
{% assign categories = site.projects | map: "category" | uniq %}
{% for category in categories %}
  <li>
    <a href="{{ '/categories/' | append: category | slugify | relative_url }}">
      {{ category }}
    </a>
  </li>
{% endfor %}
</ul>
