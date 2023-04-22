+++
title = "Literate Programming With Org Mode"
author = ["Will Medrano"]
date = 2023-04-20
draft = false
+++

<div class="SUMMARY">

By looking into Org Mode, I managed to sidetrack myself into writing my Emacs
Configuration as a literate program.

</div>


## What is Emacs and Org Mode? {#what-is-emacs-and-org-mode}

Emacs is a (very old) text editor that is highly customizable. The configuration
is one of the main appeals of Emacs. It is configured using Emacs Lisp. Pretty
much everything in Emacs is extensible. The documentation (and built in editor
documentation) for Emacs is also fantastic. Don't know what a key will do, type
`C-h k <key that you want to know>` and Emacs will open up a help window with
the function that the key will run and where that function is defined. Need to
know what a function does, type `C-h f <function>` to open up its documentation
with a link to its source code. Although this means Emacs is very powerful, that
really isn't the draw for me. As a Software Engineer, I much prefer writing code
as opposed to writing a config. This is why I have spent countless hours
configuring Emacs as opposed to the bare minimum configuring VSCode. Emacs also
has a large community of developers that have created several packages. My main
source for discovering these is [Melpa](https://melpa.org/#/). Unfortunately I have mostly been off
Emacs lately. The primary reason being that LSP integration is not quite as good
as VSCode.

Org Mode is a note-taking and list management system. Superficially, it is
similar to Markdown but predates it by about a year (2003 vs 2004). I am just
now beginning to look into Org Mode to organize my life, but I plan to
incorporate it into most aspects of my note taking and task tracking.


## Journey To Literate Programming {#journey-to-literate-programming}

For my recent return to Emacs, I wanted to focus on learning Org Mode. However,
I first needed to remake my Emacs configuration! Conveniently, it turns out that
Org Mode is one of the supported ways of writing an Emacs configuration. Writing
in Org Mode is also often considered a form of literate programming.


## What Is Literate Programming? {#what-is-literate-programming}

Literate programming  is a methodology that focuses on create a literate
document. This is opposed to the traditional paradigm in which the code is a
first class citizen and documentation is secondary. Modern day tooling that
enables this includes Jupyter Notebooks and Org Mode.

From [literateprogramming.com](https://www.literateprogramming.com) by Donald Knuth:

> ... Instead of imagining that our main task is to instruct a computer what to
> do, let us concentrate rather on explaining to human beings what we want a
> computer to do.


## Emacs Lisp in Org Mode Experience {#emacs-lisp-in-org-mode-experience}

At first, writing an Emacs Lisp program with Org Mode felt pretty normal and
everything worked as expected. However, I noticed a deficiency once I exported
the Org file to HTML. Although I thought that the layout of my code made sense,
the final HTML didn't feel high quality. After some refactoring the document
started to become more readable. And then, it clicked. When adding a new feature
to my configuration, I started thinking more in terms of the literate part. When
adding a new feature, my first thought is now to take a look at the outline and
find the place where it fits best.


## Result {#result}

The final literate program can be read at
<https://www.wmedrano.dev/living-programs/emacs-config> with the source code
residing in <https://github.com/wmedrano/emacs-config>.


## Observations {#observations}


### Narrative {#narrative}

Literate programming focuses on readability front and foremost. When adding
features to my Emacs configuration, I first have to envision how it fits into
the current narrative. In practice, this comes down to finding the right
sections to edit. Although I have yet to apply this principle outside of the
Emacs configuration, I will try to incorporate the idea into my everyday
programming.

> What should the narrative of my program look like?

This shift in focus essentially means that literate programmers are writers
first and programmers second. As someone who has seen increasing enjoyment in
writing documentation, I am very interested in pursuing the ideas of literate
programming further. For people like my younger self that saw documentation as a
chore, I expect that literate programming is utterly unappealing.


### Refactoring {#refactoring}

Due to having to create a narrative, literate programming requires knowing more
up front. Since I have written my Emacs configuration from scratch several
times, I was able to come up with something cohesive. However, moving around
pieces required significantly more refactoring effort. In areas that I'm less
familiar with, I would imagine that creating a fully literate program may not be
feasible or worth it.


### Tooling {#tooling}

Org Mode has great tooling to export Org Mode files. There's support for Emacs
Lisp, markdown, and HTML. Writing an Org file is also a great literary
experience with Emacs containing many shortcuts. However, I noticed significant
tooling deficiencies when writing the Emacs Lisp parts of the program. The
functionality that I'm accustomed to was broken out of the box. This includes:

-   Auto completion.
-   Go to definition.
-   Refactoring support like renaming a variable.


## Future Work {#future-work}

**Will I migrate any of my real work to literate programming?**

No. The primary reason I would not use literate programming at work is that it
requires that other teammates be onboard. This is a big ask. I'm essentially
asking the team to become writers first and programmers second.

For solo work, I would still say mostly no. The main reason being that the
broken tooling would degrade my programming experience. Even then, I'm not
always in the literate mood. Sometimes I'm in the "get things done" mood.

**Will I continue to experiment with literate programming?**

Definitely. I will

-   continue to think of my Emacs configuration as literature first.
-   continue to explore Org Mode.
-   think about what the narrative of my code is, even outside the context of a
    literate program.
-   improve the readability/narrative of future literate programs. I'm mainly
    thinking about Python data science like work here.
-   read some literate programs.


## References {#references}

-   [Dynamic Notebooks and Literate Programming - Sam Ritchie](https://www.youtube.com/watch?v=UCEzBNh9ufs) - London Clojurians
    YouTube channel.
-   [My Literate Emacs Configuration](https://www.wmedrano.dev/living-programs/emacs-config)
