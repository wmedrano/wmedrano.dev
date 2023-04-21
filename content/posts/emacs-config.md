+++
title = "Emacs Configuration"
author = ["Will S. Medrano"]
date = 2023-04-18
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">Table of Contents</div>

- [Introduction](#introduction)
    - [Org Mode](#org-mode)
        - [Coding Conventions](#coding-conventions)
        - [Bootstrapping](#bootstrapping)
        - [Dependencies](#dependencies)
- [Basics](#basics)
    - [Theme](#theme)
    - [Line Numbering](#line-numbering)
    - [Mode Line](#mode-line)
        - [In Editor Help and Documentation](#in-editor-help-and-documentation)
        - [Noise Reduction](#noise-reduction)
    - [Key Bindings](#key-bindings)
        - [Bindings](#bindings)
        - [Mini-Buffer Completions](#mini-buffer-completions)
- [Text and Formatting](#text-and-formatting)
    - [Spell Correction](#spell-correction)
    - [Auto Fill](#auto-fill)
    - [Tabs &amp; Spaces](#tabs-and-spaces)
    - [Parenthesis and Braces](#parenthesis-and-braces)
- [Advanced](#advanced)
    - [Project Management](#project-management)
    - [Version Control](#version-control)
    - [Disable File Backups](#disable-file-backups)
    - [Auto-Complete](#auto-complete)
    - [Extra Utility Functions](#extra-utility-functions)
- [Language Specific Configurations](#language-specific-configurations)
    - [Rust Mode](#rust-mode)
- [Text Specific Configurations](#text-specific-configurations)
    - [Markdown Mode](#markdown-mode)
    - [Org Mode](#org-mode)
        - [Useful Keybindings](#useful-keybindings)
        - [Static Site Generation - Hugo](#static-site-generation-hugo)
        - [GitHub Markdown](#github-markdown)
    - [YAML Mode](#yaml-mode)
- [Source Code](#source-code)

</div>
<!--endtoc-->



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

`M-x w/install-dependencies` installs all the dependencies.

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
                                  all-the-icons-ivy-rich
                                  company
                                  counsel
                                  counsel-projectile
                                  diff-hl
                                  diminish
                                  eglot
                                  evil
                                  evil-commentary
                                  htmlize
                                  ivy
                                  ivy-rich
                                  markdown-mode
                                  nord-theme
                                  ox-gfm
                                  ox-hugo
                                  powerline
                                  powerline-evil
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
(set-frame-parameter (selected-frame) 'alpha '(95 . 95))
(require 'nord-theme)
(load-theme 'nord t)
;; Allow the terminal's default background to shine through. This is required
;; in order for Nord theme to not override the terminal's transparency
;; settings.
(unless (display-graphic-p)
  (set-face-attribute 'default nil :background "unspecified-bg"))
```


### Line Numbering {#line-numbering}

```emacs-lisp
;; Show the line number on the left of the editor with a minimum of 3
;; characters.
(setq display-line-numbers-width 3)
(global-display-line-numbers-mode t)
(global-hl-line-mode t)
;; Display the column number in the modeline.
(column-number-mode t)
(set-frame-font "fira code 11")
```


### Mode Line {#mode-line}

```emacs-lisp
(require 'powerline)
(require 'powerline-evil)
(powerline-evil-vim-color-theme)
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
(setq inhibit-startup-screen t
      ring-bell-function 'ignore)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
```

```emacs-lisp
(defun w/diminish-noisy-modes ()
  "Diminish all modes that are not worth showing."
  (require 'diminish)
  (diminish 'ivy-mode "")
  (diminish 'counsel-mode "")
  (diminish 'which-key-mode "")
  (diminish 'auto-fill-function "")
  (diminish 'evil-commentary-mode "")
  (diminish 'company-mode ""))
(add-hook 'emacs-startup-hook #'w/diminish-noisy-modes)
;; Diminish needs to run after startup, but we also run it here in case the
;; list has been updated and reload config has been requested.
(w/diminish-noisy-modes)
```

```emacs-lisp
(defun w/command-error-fn (data context caller)
  "Ignore several (noisy) signals and pass the rest to the default handler."
  (when (not (memq (car data) '(buffer-read-only
                                beginning-of-buffer
                                end-of-buffer
                                beginning-of-line
                                end-of-line)))
    (command-error-default-function data context caller)))

(setq command-error-function #'w/command-error-fn)
```


### Key Bindings {#key-bindings}

The keybindings are based around the [Evil](https://www.emacswiki.org/emacs/Evil) package. Evil is the most popular
Emacs package that implements VIM key bindings. The key bindings present in this
section are basic bindings. More specific bindings are littered throughout this
document.


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

Disable the VIM TAB key. This allows TAB to pass through to the underlying
buffer. Underlying modes often have better functionality under the tab key
compared to VIM's default. For example, Org Mode uses TAB to expand/collapse
headings and programming languages use TAB to automatically fix the indentation.

```emacs-lisp
(define-key evil-motion-state-map (kbd "TAB") nil)
```

I prefer to use some more standard key bindings. For example, Emacs uses `C-x
C-s` to save while most other modern tools use just `C-s`.

```emacs-lisp
(defun w/save-and-maybe-normal-mode ()
  "Saves the buffer and then switches to normal mode if in Evil insert state."
  (interactive)
  (when (evil-insert-state-p) (evil-normal-state))
  (save-buffer))
(global-set-key (kbd "C-s") #'w/save-and-maybe-normal-mode)
```

Evil commentary mode enables VIM style keybindings for commenting out code. The
binding for this is `gc` followed by the type of entity like `w` for word or `c`
for the entire line.

```emacs-lisp
(evil-commentary-mode t)
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
-   `?` - Show help menu. This reveals tons of other prefix keys.

<!--listend-->

```emacs-lisp
;; Always show the dispatch menu even if there are only 2 options.
(setq aw-dispatch-always t)
(w/define-motion-key (kbd "gw") #'ace-window)
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

All the icons integration can also be used to add pretty icons to the
completions when in GUI (not terminal) mode. If the icons are displaying their
Unicode values instead, run `M-x all-the-icons-install-fonts`.

```emacs-lisp
(require 'ivy-rich)
(require 'all-the-icons-ivy-rich)
(ivy-rich-mode t)
(all-the-icons-ivy-rich-mode t)
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

By default, spaces are preferred over tabs. Additionally, pressing the tab key
does not insert a tab. Instead, it auto-formats the indentation on the current
line/region.

```emacs-lisp
;; Prefer using spaces over tabs.
(setq-default indent-tabs-mode nil)
;; Trim all trailing whitespace before saving.
(add-hook 'before-save-hook #'delete-trailing-whitespace)
```


### Parenthesis and Braces {#parenthesis-and-braces}

Matching end parenthesis and braces are automatically inserted.

```emacs-lisp
(electric-pair-mode t)
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
```

The major key bindings for this are:

-   `gpp` is used to switch to a new project.
-   `gpf` is used to select a file within the project.
-   `gpb` is used to select an opened buffer within the project.
-   `gpu` to run a command at the root of the project. This opens a new
    compilation buffer with the results of the command.

Counsel Projectile provides Ivy minibuffer completion for projectile similar to
how Counsel provides minibuffer completion for most built-in Emacs functions.

```emacs-lisp
(require 'counsel-projectile)
(counsel-projectile-mode t)
```


### Version Control {#version-control}

```emacs-lisp
(require 'diff-hl)
(global-diff-hl-mode t)
;; Terminal's do not support fringes so we have to fall back to use the
;; margin.
(when (not (display-graphic-p))
  (diff-hl-margin-mode t))
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
(setq make-backup-files nil
      auto-save-default nil)
```


### Auto-Complete {#auto-complete}

The [Company](https://company-mode.github.io) Emacs Lisp package is used to handle auto complete. By default,
Company mode provides a simple completion engine. However, if an LSP is
configured for the major-mode, then the completions should improve.

Keybindings when in completion:

-   Up/Down Arrow - Go up and down selections.
-   `TAB` - Auto-complete to selection.
-   `C-h` - Show documentation for selection.
-   `C-g` - Abort selection.

<!--listend-->

```emacs-lisp
(require 'company)
(global-company-mode)
(define-key company-active-map (kbd "TAB") #'company-complete-selection)
(define-key company-active-map (kbd "<tab>") #'company-complete-selection)
(define-key company-active-map (kbd "RET") nil)
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

Properly supporting requires installing the `rust-analyzer` LSP. Proper support
enables things like smart auto-complete, compile checking, code refactors, and
other stuff. `rust-analyzer` can be installed with:

```bash
rustup component add rust-analyzer
```

```emacs-lisp
(require 'rust-mode)
(require 'eglot)

(add-to-list 'eglot-server-programs
             '((rust-ts-mode rust-mode) . ("rustup" "run" "stable" "rust-analyzer")))

(defun w/setup-rust-mode ()
  (setq-local fill-column 100)
  (eglot-ensure))
(add-hook 'rust-mode-hook #'w/setup-rust-mode)
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
    (org-gfm-export-to-markdown nil)
    (rename-file "emacs-config.md" "README.md" t)
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


#### GitHub Markdown {#github-markdown}

GitHub markdown is known as GitHub flavored Markdown. The `ox-gfm` package
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

Source Code: <https://github.com/wmedrano/emacs-config/blob/main/emacs-config.org>
