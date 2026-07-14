# Design Tokens

## Base
- Body background: `#f4f2ef`
- Content block bg (tables, images, code blocks): `#fafafa`
- Inline code bg: `#f0ede6`, border: `#e0dcd5`
- Global border: `#e0dcd5`
- Navbar border: `#f3f0f7`
- Postamble: border-top `#333`, font-size 10px, opacity 0.5, first child hidden

## Links
- Default: `#4078f2`
- Hover: `#2666d6`

## Syntax — Atom One Light
- Keywords / Preprocessor / Markdown language: `#a626a4`
- Builtins / Functions / Lists: `#4078f2`
- Types: `#c18401`
- Variables / Properties / Negation / Rust `?`: `#e45649`
- Constants / Markdown inline code: `#986801`
- Strings: `#50a14f`
- Comments / Docs / Markdown markup: `#a0a1a7` (italic for comment delimiter)

## Typography
- Sans: DM Sans (Google Fonts)
- Mono: DM Mono (Google Fonts)
- Serif: Sen (Google Fonts, for tables)
- Content max-width: 800px
- Content padding: 0 1rem (≥800px: 0 2rem)
- Body line-height: 1.5
- Code/pre line-height: 1.1
- Font sizes: body 18px, code 14px, h1–h6 descending from 36px
- Navbar: brand 22px / 800 weight, link 14px / 500 weight
- Misc: `#table-of-contents` 18px, `label.org-src-name` 16px, `.post-date` / `.figure p` 14px

## Tables
- Font: Sen, 1rem
- Border / cell border: `#e0dcd5`
- Cell padding: 0.5em 1em
- Box-shadow: `0 1px 3px rgba(0,0,0,0.04)`
- Scrollable block container (`overflow-x: auto`)

## Graphs (DOT / SVG)
- Background: `#f4f2ef` (body background, not transparent)
- Edge lines: `#a0a1a7`, arrowsize: 0.8
- Node defaults: `fontname="sans-serif"`, `fontsize=12`, `penwidth=1.2`
- Box fills (processes): `#f3f0f7` with border `#4078f2`, `shape=box`, `style="filled"`
- Note fills (files/data): `#fafafa` with border `#c18401`, `shape=note`
- Multi-item lists: `shape=record` (e.g. `"Patch 0|Patch 1|…|Patch N"`)
- Cluster: `style="filled"`, bg `#f4f2ef`, border `#e0dcd5`, label inherits fontname/fontsize
- Boxes: straight corners (no rounded)
- Layout: `rankdir=LR`

## Graphs (Gnuplot)
- Terminal: SVG, size 600×300
- Background: `#fafafa` (via `set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb '#fafafa' behind`)
- Bar fill: `#4078f2` (accent blue, `set style line 1 lc rgb '#4078f2'`)
- Fill style: `solid 0.85 border rgb '#333'`
- Box width: 0.6
- Text color: `#333` (title, ylabel, axes, tics via `textcolor rgb '#333'`)
- Border: `set border 11 lw 1.5 lc rgb '#333'`
- Legend off (`set key off`)
- X-tick labels: rotated -20°
- Data: inline heredoc (`$data << EOD … EOD`)
- Plot: `with boxes ls 1`

## Decorative
- Box shadow: `0 1px 3px rgba(0,0,0,0.04)`
- Border radius: `.src` / `img` 6px, inline `code` 3px
