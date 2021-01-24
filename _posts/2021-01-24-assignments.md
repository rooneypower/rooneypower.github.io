---
layout: post
title: "Created index for assignments directory"
date: 2021-01-24
---

Using references for [Jekyll site variables](https://jekyllrb.com/docs/variables/) and [Liquid tags](https://shopify.dev/docs/themes/liquid/reference/tags), I was able to create a page that lists all the static files in the assignments subdirectory. I imagine there is a more direct and efficient way of doing this than looping through site.static_files and checking if the first /-delimited piece of path is assignments, but this seems to work.
