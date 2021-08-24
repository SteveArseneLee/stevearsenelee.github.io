---
title: "Django"
layout: archive
permalink: categories/Django
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.Django %}
{% for post in posts %} {% include archive-single2.html type=page.entries_layout %} {% endfor %}