+++
title = "Emacs Configuration"
author = ["Will S. Medrano"]
date = 2023-04-18
draft = false
+++

## Introduction {#introduction}

This page describes my (will.s.medrano@gmail.com) Emacs configuration. Emacs is
a highly customizable text editor that can be customized with Emacs Lisp. This
page is written in Org and is the primary [source code](https://github.com/wmedrano/emacs-config) for my actual Emacs
configuration!


### Org Mode {#org-mode}

My Emacs configuration is written with Emacs Org Mode.

<div class="verse">

A **GNU Emacs** major mode for keeping notes, authoring documents, computational<br />
notebooks, literate programming, maintaining to-do lists, planning projects,<br />
and more --- in a fast and effective plain text system.<br />
<br />
&nbsp;&nbsp;&nbsp;--- <https://orgmode.org><br />

</div>

The primary data flows are:

-   config.org &rarr; config.html for displaying in a website.
-   config.org &rarr; config.el for use with Emacs. This is done by running
    Emacs Lisp function `org-babel-load-file`. This automatically runs all the
    `emacs-lisp` code blocks within `config.org`.

Using Org Mode to write an Emacs configuration is a form of Literate
Programming. Literate Programming is a paradigm that combines the code and
documentation to provide a literate document that also serves as the source
code. However, the main drawback is reduced "IDE" support. Standard code
documentation and auto-complete packages are broken out of the box.


#### Coding Conventions {#coding-conventions}

All custom functions are prefixed with `w/` since Emacs lisp does not support
officially support name-spacing.


#### Bootstrapping {#bootstrapping}

To use this configuration, load the source code from the main Emacs config. This
can be done by creating a file named `~/.emacs.d/init.el` and placing the
following:

```nil
(org-babel-load-file (expand-file-name "emacs-config.org" user-emacs-directory))
```

Following this, dependencies should be (re)installed.


#### Dependencies {#dependencies}

Dependencies can be installed by running `M-x w/install-dependencies`.

```emacs-lisp
(require 'package)
;; Taken from https://melpa.org/#/getting-started
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; This is required to obtain the htmlize package. htmlize is used to improve
;; the output of Org Mode to html.
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/")
             t)
(setq package-selected-packages '(
                                  ace-window
                                  company
                                  counsel
                                  counsel-projectile
                                  evil
                                  htmlize
                                  ivy
                                  markdown-mode
                                  mini-modeline
                                  nord-theme
                                  smart-modeline
                                  ox-gfm
                                  ox-hugo
                                  projectile
                                  rust-mode
                                  which-key
                                  yaml-mode
                                  ))
(package-initialize)

(defun w/install-dependencies ()
  "Install all dependencies and remove any unused dependencies. If you wish to
  only install new dependencies and not refresh the index and clean up old
  dependencies, use (package-install-selected-packages) instead."
  (interactive)
  (package-initialize)
  (package-refresh-contents)
  (package-install-selected-packages)
  (package-autoremove))
```


## Basics {#basics}


### Theme {#theme}

{{< figure src="/ox-hugo/theme.png" >}}

The Nord theme is a clean theme that is available in many places, including
Emacs. See <https://nordtheme.com> for more details.

```emacs-lisp
(require 'nord-theme)
(load-theme 'nord t)
```


### Line Numbering {#line-numbering}

```emacs-lisp
;; Show the line number on the left of the editor.
(global-display-line-numbers-mode t)
(global-hl-line-mode t)
;; Display the column number in the modeline.
(column-number-mode t)
(set-frame-font "fira code 11")
```


#### In Editor Help and Documentation {#in-editor-help-and-documentation}

Emacs provides plenty of built in help. There are several functions that can be
activated with `M-x`.

-   `describe-variable` - Open the documentation and source code for an Emacs Lisp
    variable.
-   `describe-function` - Open the documentation and source code for an Emacs Lisp
    function.
-   `describe-key` - After running, the next key map action will be recorded. This
    will then open the documentation for the function that runs when that key is
    pressed. For example, in the default normal state of Evil, pressing
    `describe-key` followed by `j` opens the documentation for `evil-next-line`.

`which-key-mode` is used to print out the available keys in scenarios where keys
are changed. For example, in normal mode, the "g" key is used as a prefix for
several commands like "gd" (go to definition) and "gg" (go to top of
file). Enabling which-key-mode will show a small popup with the available
actions if the prefix "g" is pressed. This is very convinient and is not
intrusive as the pop-up only comes up when a small delay is detected.

{{< figure src="/ox-hugo/which-key.png" >}}

```emacs-lisp
(require 'which-key)
(setq which-key-idle-delay 0.5)
(which-key-mode t)
```


#### Noise Reduction {#noise-reduction}

This section contains configuration that removes noisy elements from the UI.

```emacs-lisp
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

(require 'smart-mode-line)
(setq custom-safe-themes '(
                           "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa"
                           "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223"
                           default))
(sml/setup)
(sml/apply-theme 'respectful)
;; Shrink the size of the modeline. Mostly useful for gui (not terminal) mode.
(require 'mini-modeline)
(mini-modeline-mode t)
```


### Key Bindings {#key-bindings}

The keybindings are based around the [Evil](https://www.emacswiki.org/emacs/Evil) package. Evil is the most popular
Emacs package that implements VIM key bindings. The key bindings present in this
section are basic bindings. More specific bindings are littered throughout this
document.


#### Utility Functions {#utility-functions}

```emacs-lisp
(defun w/define-motion-key (keys fn)
  "Define a new motion key binding on KEYS that runs function FN."
  (define-key evil-normal-state-map keys nil)
  (define-key evil-motion-state-map keys fn))
```


#### Bindings {#bindings}

Enable Evil mode globally to use VIM like modal editing.

```emacs-lisp
(evil-mode)
```

Use "J" and "K" to scroll up and down the buffer as opposed to the standard
"Ctrl+u" and "Ctrl+d" that VIM uses.

```emacs-lisp
(w/define-motion-key (kbd "J") #'evil-scroll-down)
(w/define-motion-key (kbd "K") #'evil-scroll-up)
```

To navigate windows, `gw` is used to bring up an interactive menu that supports
the following commands:

-   `<number>` - Each window is given a number. Selecting a number will jump to
    that window.
-   `m <number>` - Swap window.
-   `x <number>` - Close the window.
-   `v <number>` - Split the window vertically.
-   `b <number>` - Split the window horizontally.
-   `o <number>` - Maximize the selected window.
-   `?` - Show help for all prefix keys.

<!--listend-->

```emacs-lisp
;; Always show the dispatch menu even if there are only 2 options.
(setq aw-dispatch-always t)
(w/define-motion-key (kbd "gw") #'ace-window)
```

Disable the VIM TAB key. This allows TAB to pass through to the underlying
buffer. Underlying modes often have better functionality under the tab key
compared to VIM's default. For example, Org Mode uses TAB to expand/collapse
headings and programming languages use TAB to automatically fix the indentation.

```emacs-lisp
(define-key evil-motion-state-map (kbd "TAB") nil)
```


#### Mini-Buffer Completions {#mini-buffer-completions}

By default Emacs does not show completions in the minibuffer unless Tab is
pressed. And even then, the completions could be improved. Ivy is used for fuzzy
minibuffer completions. Counsel is also used to wrap common built in Emacs
methods to use Ivy minibuffer completion. See <https://github.com/abo-abo/swiper>.

{{< figure src="/ox-hugo/minibuffer.png" >}}

```emacs-lisp
(require 'ivy)
(require 'counsel)
(ivy-mode t)
(counsel-mode t)
```


## Text and Formatting {#text-and-formatting}


### Spell Correction {#spell-correction}

Flyspell is used to assist in spell correction. It assists in both general spell
correction for text modes (like Markdown and Org) as well as spell correction
within the comments of programming modes. Spell corrections manifest themselves
as red (or orange) squiggles that can be interacted with using the mouse middle
click.

```emacs-lisp
(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'text-mode-hook #'flyspell-mode)
```


### Auto Fill {#auto-fill}

Auto fill mode implements automatic line breaking. That is, lines will
automatically be formatted to fit within (by default) 80 characters.

```emacs-lisp
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode)
```


### Tabs &amp; Spaces {#tabs-and-spaces}

```emacs-lisp
;; Prefer using spaces over tabs.
(setq-default indent-tabs-mode nil)
;; Trim all trailing whitespace before saving.
(add-hook 'before-save-hook #'delete-trailing-whitespace)
```


## Advanced {#advanced}


### Project Management {#project-management}

<https://github.com/bbatsov/projectile> is used to manage projects. This involves
do things within the scope of a project (usually git). Actions include:

-   Finding a particular file or regular expression.
-   Saving all the files in a project.
-   Compiling, running, or testing a project.

<!--listend-->

```emacs-lisp
(require 'projectile)
(require 'counsel-projectile)
(projectile-mode t)
(w/define-motion-key (kbd "gp") #'projectile-command-map)
(w/define-motion-key (kbd "gpp") #'counsel-projectile)
```

The major key bindings for this are:

-   `gpp` runs counsel-projectile. This handles both opening a file and switching to
    a buffer. For just files use `gpf` and for just buffers use `gpb`.
-   `gpu` to run a command at the root of the project. This opens a new compilation
    buffer with the results of the command.

Counsel Projectile provides Ivy minibuffer completion for projectile similar to
how Counsel provides minibuffer completion for most built-in Emacs functions.

```emacs-lisp
(require 'counsel-projectile)
(counsel-projectile-mode t)
```


### Disable File Backups {#disable-file-backups}

Emacs creates backup files by default. This is accomplished by creating a backup
of file `<file>` as `<file>~`. Although this seems good in theory, it is
somewhat noisy for the filesystem so I disable it. The lack of backups is fine
as:

-   File corruption is a very rare occurence.
-   Important checkpoints are backed up with version control like git + GitHub.

<!--listend-->

```emacs-lisp
(setq make-backup-files nil)
```


### Auto-Complete {#auto-complete}

The [Company](https://company-mode.github.io) Emacs Lisp package is used to handle auto complete.

```emacs-lisp
(require 'company)
(global-company-mode)
```


### Extra Utility Functions {#extra-utility-functions}

```emacs-lisp
(defun w/reload-emacs-config ()
"Reload the emacs config."
(interactive)
(load-file (expand-file-name "init.el" user-emacs-directory))
(message "Emacs config reloaded."))

(defun w/is-emacs-org-config ()
"Returns t if the current buffer is the primary org config"
(string=
  (expand-file-name "emacs-config.org" user-emacs-directory)
  buffer-file-name))
```


## Language Specific Configurations {#language-specific-configurations}


### Rust Mode {#rust-mode}

```emacs-lisp
(require 'rust-mode)
```


## Text Specific Configurations {#text-specific-configurations}


### Markdown Mode {#markdown-mode}

```emacs-lisp
(require 'markdown-mode)
```


### Org Mode {#org-mode}

Org Mode is a mode for general writing, organizing, planning, and literate
programming.

-   Source code blocks should be syntax highlighted.

<!--listend-->

```emacs-lisp
(setq org-src-fontify-natively t)
```

-   Saving the configuration (`"emacs-config.org"`) reloads the Emacs configuration and
    exports the corresponding html file.

<!--listend-->

```emacs-lisp
(defun w/org-after-save ()
  (when (w/is-emacs-org-config)
    ;; TODO: Automatically export to README.md. Currently running
    ;; org-gfm-export-to-markdown from w/org-after-save fails.
    ;; (org-gfm-export-to-markdown)
    (w/reload-emacs-config)
    (message "Emacs config reloaded.")))

(defun w/setup-org-mode ()
  ;; Saving a file in org mode will export the corresponding HTML file by
  ;; default.
  (add-hook 'after-save-hook #'w/org-after-save 0 t))
(add-hook 'org-mode-hook #'w/setup-org-mode)
```


#### Useful Keybindings {#useful-keybindings}

-   `C-c C-l` - Insert or update a link.
-   `TAB` on header - Expand or collapse the section.


#### Static Site Generation - Hugo {#static-site-generation-hugo}

Hugo is a static site generator. I use it for my blog at [wmedrano.dev.](https://www.wmedrano.dev) Hugo
supports Markdown and Org Mode. However, the Org Mode support is not quite
feature rich. For this reason, I use `ox-hugo` to export better formatted
Markdown for my blog. The workflow for `ox-hugo` and Emacs is:

1.  Create/edit the appropriate Org file. This includes even this configuration
    itself.
2.  Run `M-x org-hugo-export-to-md` which will export the Markdown to the Hugo
    blog source directory. This step depends on knowing the base directory for
    the Hugo source. This can be done either through an environment variable or
    by filling in the `org-hugo-base-dir` Emacs Lisp variable. I use the latter
    for configuration simplicity but may switch to an environment variable if I
    start to vary my directory structure from machine to machine.

<!--listend-->

```emacs-lisp
(require 'ox-hugo)
(setq org-hugo-base-dir "~/src/wmedrano.dev")
(defun w/setup-hugo-autoexport ()
  (when (w/is-emacs-org-config)
      (add-hook 'after-save-hook #'org-hugo-export-to-md 0 t)))
(add-hook 'org-mode-hook #'w/setup-hugo-autoexport)
```


#### Github Markdown {#github-markdown}

Github markdown is known as Github flavored Markdown. The `ox-gfm` package
provides `M-x org-gfm-export-as-markdown` to export to this specific flavor of
Markdown.

```emacs-lisp
(require 'ox-gfm)
```


### YAML Mode {#yaml-mode}

```emacs-lisp
(require 'yaml-mode)
```


## Source Code {#source-code}

[source code](https://github.com/wmedrano/emacs-config)
