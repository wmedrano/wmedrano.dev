+++
title = "Org Mode Cheat Sheet"
author = ["Will Medrano"]
date = 2023-05-21
lastmod = 2023-05-29T21:27:24-07:00
tags = ["emacs", "literate-programming", "cheat-sheet"]
draft = false
+++

## TLDR {#TLDR-szbezj301uj0}

A reference of useful Org Mode (with a focus on literate programming)
functionality.

For a more official reference on Org Babel for literate programming, see
[Introducing Babel](https://orgmode.org/worg/org-contrib/babel/intro.html).


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


### Programming {#TLDRProgramming-4rdc14n0duj0}


#### Async Evaluation {#TLDRProgrammingAsyncEvaluation-p1fc14n0duj0}

Asynchronous evaluation is provided by the `ob-async` package. It must be loaded
with `(require 'ob-async)`. After loading, a block may be executed
asynchronously with the following header:

```org
#+begin_src python :async
return 2 + 2
#+end_src
```


#### Python {#TLDRPiChart-cdb7van01uj0}

<!--list-separator-->

-  Charts with Matplotlib

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
