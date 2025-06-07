---
title: "Programming"
layout: archive
permalink: categories/Programming
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.Programming %}
{% for post in posts %} {% include archive-single2.html type=page.entries_layout %} {% endfor %}