---
layout: default
title: Authors
permalink: /students/
---

<h1>Authors</h1>

<ul>
{% assign authors = site.authors | sort: "name" %}
{% for author in authors %}
  <li>
    <a href="{{ '/students/' | append: author.slug | append: '/' | relative_url }}">
      {{ author.name }}
    </a>
  </li>
{% endfor %}
</ul>

<p><a href="{{ '/' | relative_url }}">← Back to Home</a></p>
