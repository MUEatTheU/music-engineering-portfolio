---
layout: default
title: Students
permalink: /students/
---

<h1>Students</h1>

<ul>
{% assign sorted_projects = site.projects | sort: "student_name" %}
{% assign seen_slugs = "|" %}
{% for project in sorted_projects %}
  {% assign marker = "|" | append: project.student_slug | append: "|" %}
  {% unless seen_slugs contains marker %}
    <li>
      <a href="{{ '/students/' | append: project.student_slug | append: '/' | relative_url }}">
        {{ project.student_name }}
      </a>
    </li>
    {% assign seen_slugs = seen_slugs | append: project.student_slug | append: "|" %}
  {% endunless %}
{% endfor %}
</ul>

<p><a href="{{ '/' | relative_url }}">← Back to Home</a></p>
