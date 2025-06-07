---
title: "이코테"
layout: archive
permalink: categories/['이코테']
author_profile: true
sidebar_main: true
---

{% assign posts = site.categories.['이코테'] %}
{% for post in posts %} {% include archive-single2.html type=page.entries_layout %} {% endfor %}