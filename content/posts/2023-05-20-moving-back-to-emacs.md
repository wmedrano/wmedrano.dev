+++
title = "Moving Back To Emacs"
author = ["Will Medrano"]
date = 2023-05-20
lastmod = 2023-05-21T16:01:35-07:00
tags = ["emacs", "literate-programming"]
draft = false
+++

## TLDR {#TLDR-szbezj301uj0}

Emacs is a great editor and a joy to configure. Since I’m in no rush to be
productive, it's a great time to have fun configuring my Emacs and honing my
Emacs Lisp skills.


## Strengths of Emacs {#EmacsStrengthsofEmacs-24ufo2101uj0}

One of the main strengths of Emacs is its unmatched extensibility. Emacs is
configured in the language Emacs Lisp which makes it very powerful, and frankly
more fun to configure.


### Extensibility {#EmacsStrengthsofEmacsExtensibility-a6b1oc101uj0}

Emacs is configured with Emacs Lisp. In fact, every action in Emacs runs an
Emacs Lisp function.

This can be demonstrated with the following exercise:

1.  Press `M-x` to bring up a prompt to execute an Emacs Lisp function.
2.  Enter `describe-key` and hit Enter.
3.  Press alpha numeric character.

Running the above commands will show you documentation for the key that was
pressed and the function it runs.

```text
f runs the command self-insert-command (found in global-map), which is an
interactive built-in function in ‘C source code’.

It is bound to many ordinary text characters.

(self-insert-command N &optional C)

Insert the character you type.
Whichever character C you type to run this command is inserted.
The numeric prefix argument N says how many times to repeat the insertion.
Before insertion, ‘expand-abbrev’ is executed if the inserted character does
not have word syntax and the previous character in the buffer does.
After insertion, ‘internal-auto-fill’ is called if
‘auto-fill-function’ is non-nil and if the ‘auto-fill-chars’ table has
a non-nil value for the inserted character.  At the end, it runs
‘post-self-insert-hook’.

  Probably introduced at or before Emacs version 22.1.

[back]
```

Most editors claim to be extensible, but Emacs exposes nearly all its internals
for customization.


### Longevity {#EmacsStrengthsofEmacsLongevity-j221vp101uj0}

This is something that I'm just beginning to value. I've usually been one of the
first to line up to try something new. I've tried several editors[^fn:1] and have made
significant efforts to configure at least 4 other ones, 2 are debatably on the
downtrend. GNU Emacs has been around since 1985 and it has kept up pace with
more modern text editors[^fn:2].

Additionally, it is community driven with ideas that seem to align with I
want. I have a stronger belief that this will remain the case as opposed to `VS
Code` which could change at a whim due to Microsoft's ownership.


## New Opportunities {#EmacsNewFocuses-6tufo2101uj0}


### Org Mode {#EmacsNewOpportunitiesOrgMode-asmbs4201uj0}

My latest foray into Emacs was mainly to try out Org Mode. Throughout the years
I have heard rumors that Org Mode is one of the greatest inventions and that you
can base your life around this. I have been in a more literate/writer mood this
past year and decided to give it a try. I'm still learning Org Mode and it may
eventually take over my life!

At the moment, I see Org Mode as a decent step up from Markdown. Additionally my
experiment in literate programming proved interesting. I will continue to use
Org Mode and I may very well become a huge proponent of Org Mode.


### Learning Emacs Lisp {#EmacsNewOpportunitiesLearningEmacsLisp-mh58ml201uj0}

Long story:

I'm at an interesting point in my career. As a "tech lead" in a enormous
organization, my day to day success involves very little code and even
architectural design. Unfortunately the biggest challenges are office politics
and coordinating road-maps. Needless to say I have lots of creative energy and
some free-time, but not enough free time (and maybe skill) to focus on an
impactful and rewarding personal project. Although I would like to do this, my
past efforts in making meaningful progress on a personal project while having a
full time job have led to some productivity at the cost of increased stress
levels.

**So what does this leave me with...**

Weirdly enough, my observation has been that I don't have the energy for a large
rewarding personal project but I do have the energy to muck around with Emacs
and Emacs Lisp. So, I'll probably be spending some time with smaller projects,
which includes maintaining my Emacs setup.


## Challenges {#EmacsChallenges-5m4c0q201uj0}

My work configuration is significantly different than something I would use at
home. Google uses several custom tools, some open source and some closed. For
editing code, I can't even rely on the standard file system! Additionally,
Google uses a monorepo that stores most of the company's code in a single
repository [(publication)](https://research.google/pubs/pub45424/). Lots of tools break at this scale. The following
challenges arise:

1.  The main supported text editor for Google is a **heavily** customized version of
    a web based VS Code. The Emacs support is driven by a small community of
    Emacs users. Emacs at Google is not a first class citizen.
2.  The monorepo nature breaks things. Grepping over the whole codebase is not
    feasible and packages like `projectile` break.
3.  Google does not use Git.Google's version control is fine but I miss
    using [`Magit`](https://magit.vc/).
4.  ... And lots of other small tooling differences that are well supported by
    Google's custom editor but require work in Emacs or are not as polished.

[^fn:1]: I've tried (in roughly chronological order with bolding signifying
    significant customization effort in bold): Notepad++, Sublime, Visual Studio,
    CodeBlocks, ****CodeLite****, Arduino IDE, Eclipse, ****Atom****, XCode, ****Emacs****,
    ****VIM****, LightTable, proprietary-google-ide-1, ****NeoVim****, ****VSCode****,
    ****proprietary-google-ide-2****.
[^fn:2]: At some point I was worried VSCode would lap Emacs due to Language Server
    Protocol. Luckily, Emacs (and many other editors) have a good enough LSP
    integration.