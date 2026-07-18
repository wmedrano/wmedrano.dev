---
description: Create a new blog post scaffold and add it to the index
argument-hint: "<description>"
---
You are creating a new blog post for a static site generator. Based on the
user's description, derive the following:

1. **Title**: Use the description to create a title-case title.
2. **Slug**: lowercase, spaces → hyphens, no special chars (e.g. "Fonts Q2" → "fonts-q2").
3. **Date**: Use today's date in `YYYY-MM-DD` and `YYYY-MM-DD Day` formats.
4. **Archive Section**: Read `content/index.org` and pick the best fit among the existing sections (General, Retrospectives, Tutorials).

## Before acting, present:
- Derived title, slug, date, and chosen archive section
- Wait for confirmation before making changes

## Once confirmed:

### Create the post file
Create `content/post/YYYY/MM/DD/<slug>.org` with this structure:

```
#+title: <Title>
#+date: <YYYY-MM-DD Day>
#+author: Will S. Medrano

/(Reading time: X minutes)/

* Introduction

* Footnotes
```

### Update the index
Edit `content/index.org`:

- Add `[[file:post/YYYY/MM/DD/<slug>.org][<Title>]] @@html:<span class="post-date">YYYY-MM-DD</span>@@` as the **first entry** under `* Recent`.
- Add the same line as the **first entry** under the chosen archive subsection (e.g. `** Retrospectives`).

Follow the exact formatting already used in the file.
