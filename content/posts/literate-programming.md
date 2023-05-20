+++
title = "Literate Programming"
author = ["Will Medrano"]
date = 2023-04-20
lastmod = 2023-05-20T12:11:11-07:00
tags = ["emacs", "literate-programming"]
draft = false
+++

## TLDR {#LiterateProgramming-7cxbcx401uj0}

<div class="SUMMARY">

By looking into Org Mode, I managed to sidetrack myself into writing my Emacs
Configuration as a literate program.

</div>


## What is Emacs and Org Mode? {#LiterateProgrammingWhatisEmacsandOrgMode-2u91zi71ktj0}

Emacs is a (very old) text editor that is highly customizable. The configuration
is one of the main appeals of Emacs.

Org Mode is a note-taking and list management system. Superficially, it is
similar to Markdown but predates it by about a year (2003 vs 2004). I am just
now beginning to look into Org Mode to organize my life, but I plan to
incorporate it into most aspects of my note taking and task tracking.

For my recent return to Emacs, I wanted to focus on learning Org Mode. However,
I first needed to remake my Emacs configuration! It turns out that it is
somewhat fashionable to write Emacs configuration in Org Mode!

{{< figure src="/ox-hugo/literate-programming-emacs-org-config.png" >}}


## What Is Literate Programming? {#LiterateProgrammingWhatIsLiterateProgramming-5ra1zi71ktj0}

Literate programming  is a methodology that focuses on create a literate
document. This is opposed to the traditional paradigm in which the code is a
first class citizen and documentation is secondary. Modern day tooling that
enables this includes Jupyter Notebooks and Org Mode.

From [literateprogramming.com](https://www.literateprogramming.com) by Donald Knuth:

> ... Instead of imagining that our main task is to instruct a computer what to
> do, let us concentrate rather on explaining to human beings what we want a
> computer to do.


## Emacs Lisp in Org Mode Experience {#LiterateProgrammingEmacsLispinOrgModeExperience-77b1zi71ktj0}

At first, writing an Emacs Lisp program with Org Mode felt pretty normal and
everything worked as expected. However, I noticed a deficiency once I exported
the Org file to HTML. Although the layout of my code made sense, the final HTML
artifact didn't feel high quality, it was not very readable. Adding more code
made the document even more unreadable which led me down the rabbit hole of
refactoring around the HTML until... At some point I learned my lesson. Instead
of just making code changes to start, I instead skimmed the document to find the
perfect place for the code to fit into the narrative.


## Result {#LiterateProgrammingResult-nmb1zi71ktj0}

The final literate program can be read at
<https://www.wmedrano.dev/posts/emacs-config> with the source code
residing in <https://github.com/wmedrano/emacs-config>.


## Observations {#LiterateProgrammingObservations-h1c1zi71ktj0}


#### Narrative {#LiterateProgrammingObservationsNarrative-ygc1zi71ktj0}

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


### Refactoring {#LiterateProgrammingObservationsRefactoring-mwc1zi71ktj0}

Due to having to create a narrative, literate programming requires knowing more
up front. Since I have written my Emacs configuration from scratch several
times, I was able to come up with something cohesive. However, moving around
pieces required significantly more refactoring effort. This could be a problem
when prototyping in a new space. Overall, I would say that the increased effort
required to refactor is the biggest weakness in going all in on literate
programming.


### Tooling {#LiterateProgrammingObservationsTooling-ecd1zi71ktj0}

Org Mode has great tooling to export Org Mode files. There's support for Emacs
Lisp, markdown, and HTML. Writing an Org file is also a great literary
experience with Emacs containing many shortcuts. However, I noticed significant
tooling deficiencies when writing the Emacs Lisp parts of the program. The
functionality that I'm accustomed to was broken out of the box. This includes:

-   Auto completion.
-   Go to definition.
-   Refactoring support like renaming a variable.


## Future Work {#LiterateProgrammingFutureWork-brd1zi71ktj0}

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


## References {#LiterateProgrammingReferences-57e1zi71ktj0}

-   [Dynamic Notebooks and Literate Programming - Sam Ritchie](https://www.youtube.com/watch?v=UCEzBNh9ufs) - London Clojurians
    YouTube channel.
-   [My Literate Emacs Configuration](https://www.wmedrano.dev/literate-programs/emacs-config)
