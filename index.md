---
layout: default
title: Music Engineering Portfolio
---

# Music Engineering Portfolio

## Latest Projects

<ul>
{% assign sorted = site.projects | sort: "publish_date" | reverse %}
{% for project in sorted %}
  <li>
    <a href="{{ project.url | relative_url }}">
      <strong>{{ project.title }}</strong>
    </a><br>
    {{ project.student_name }} — {{ project.category }}<br>
    {{ project.short_blurb }}
  </li>
{% endfor %}
</ul>


