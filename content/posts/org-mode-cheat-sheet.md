+++
title = "Org Mode Cheat Sheet"
author = ["Will Medrano"]
date = 2023-05-21
lastmod = 2023-05-21T16:10:57-07:00
tags = ["emacs", "literate-programming", "cheat-sheet"]
draft = false
+++

## TLDR {#TLDR-szbezj301uj0}

A reference of useful Org Mode (with a focus on literate programming)
functionality.


### General Default Key Bindings {#KeyBindingsGeneralDefaults-atgfelb01uj0}

The following keybindings are set up by default.

| key     | function            | description                                                                                |
|---------|---------------------|--------------------------------------------------------------------------------------------|
| C-c C-l | `org-insert-link`   | Insert a link. Prompts for the URI and then a description. Links can be to HTML or images. |
| C-c C-o | `org-open-at-point` | Open link, timestamp, footnote, or tag at point. Links are opened in the browser.          |


### Text Blocks {#TLDRTextBlocks-pszkznb01uj0}

| key     | function            | description                                                                                                                                                     |
|---------|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| C-c C-' | `org-edit-special`  | Does several things depending on what's at the point. Calls `org-edit-src-code` when over a source code block. This opens a new buffer to edit the source code. |
| C-c C-c | `org-ctrl-c-ctrl-c` | Does several things depending on what's at the piont. Calls `org-confirm-babel-evaluate` when over a source code block. This runs the code at the block.        |


### Python {#TLDRPiChart-cdb7van01uj0}


#### Charts with Matplotlib {#TLDRPythonChartswithMatplotlib-te5f4vn01uj0}

To create a chart with Matplotlib:

1.  Set the `:results` to `file` and `:exports` to `results` to show the image or
    `values` to show the image and the code block.
2.  Save the figure to a file.
3.  Return the name of the file.

<!--listend-->

```org
#+begin_src python :results file :exports results
  import matplotlib.pyplot as plt
  plt.pie([30, 40, 30])
  fname = '/org-mode-cheat-sheet/pie.png'
  plt.savefig(fname)
  return fname
#+end_src
```

{{< figure src="/ox-hugo/wmedrano-dev/org-mode-cheat-sheet-pie.png" >}}
