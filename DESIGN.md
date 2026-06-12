# Design Notes

## Stylesheet

Site styles live in:

```
static/css/styles.css
```

## Color Palette

Colors are recorded in HSL so hue relationships stay clear.

### Accent Triad

These three hues form the main palette.

| Role                        | HSL                   |
|-----------------------------|-----------------------|
| Warm accent (links)         | `hsl(30, 85%, 43%)`   |
| Cool accent (visited links) | `hsl(195, 55%, 35%)`  |
| Heading accent              | `hsl(270, 45%, 25%)`  |

### Backgrounds & Neutrals

| Role                                 | HSL                   |
|--------------------------------------|-----------------------|
| Page background                      | `hsl(200, 20%, 97%)`  |
| Card / table / code block background | `hsl(0, 0%, 98%)`     |
| Table header background              | `hsl(255, 31%, 95%)`  |
| Body text                            | `hsl(0, 0%, 13%)`    |
| Secondary text                       | `hsl(0, 0%, 27%)`    |
| Strong border                        | `hsl(0, 0%, 80%)`    |
| Subtle border / divider              | `hsl(0, 0%, 93%)`    |
| Postamble border                     | `hsl(0, 0%, 20%)`    |
| Code inline border                   | `hsl(0, 0%, 67%)`    |

### Syntax Highlighting

Code colors are drawn from the same triad so blocks don’t feel like a rainbow palette intruding on the page.

| Role                                             | Color                | HSL                  |
|--------------------------------------------------|----------------------|----------------------|
| Comments                                         | Dusty teal           | `hsl(195, 20%, 45%)` |
| Keywords, builtins, preprocessors              | Deep lavender        | `hsl(270, 45%, 25%)` |
| Function names, selectors, types, constants    | Teal                 | `hsl(195, 55%, 35%)` |
| Variables, properties, strings, doc strings      | Warm                 | `hsl(30, 85%, 43%)`  |

### Charts

Gnuplot charts use the heading lavender for bars so they sit next to section headings without clashing.

| Role         | Color      | HSL                 |
|--------------|------------|---------------------|
| Chart bars   | Deep lavender   | `hsl(270, 45%, 25%)` |
| Chart text   | Body text  | `hsl(0, 0%, 13%)`    |
| Chart border | Secondary  | `hsl(0, 0%, 27%)`    |
