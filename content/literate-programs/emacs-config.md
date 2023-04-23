+++
title = "Emacs Configuration"
author = ["Will S. Medrano"]
date = 2023-04-18
lastmod = 2023-04-23T16:06:32-07:00
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

```emacs-lisp-code
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
                                  evil-terminal-cursor-changer
                                  flyspell-correct
                                  flyspell-correct-ivy
                                  htmlize
                                  ivy
                                  ivy-emoji
                                  ivy-rich
                                  magit
                                  markdown-mode
                                  nord-theme
                                  ox-gfm
                                  ox-hugo
                                  powerline
                                  powerline-evil
                                  projectile
                                  rust-mode
                                  swiper
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
(unless (display-graphic-p)
  (require 'evil-terminal-cursor-changer)
  (evil-terminal-cursor-changer-activate))
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
  (diminish 'auto-fill-function "")
  (diminish 'company-mode "")
  (diminish 'counsel-mode "")
  (diminish 'eldoc-mode "")
  (diminish 'evil-commentary-mode "")
  (diminish 'ivy-mode "")
  (diminish 'which-key-mode ""))
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
(defalias 'forward-evil-word 'forward-evil-symbol)
;; Jumps to definition. If Eglot is active, then the language server is used
;; to find the definition.
(w/define-motion-key (kbd "gd") #'evil-goto-definition)
;; Swiper is a replacement for the standard VIM searching. It is a bit more
;; interactive and provides a preview.
;; (w/define-motion-key (kbd "/") #'swiper)
(define-key evil-insert-state-map (kbd "C-S-v") #'evil-paste-after)
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

Emacs has a habit of asking `yes` or `no` questions. This requires entering the
whole word but I prefer to just type `y` or `n`.

```emacs-lisp
(defalias 'yes-or-no-p 'y-or-n-p)
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


### Refreshing {#refreshing}

Files changed on disk are automatically reloaded. Changes are detected every
second. To manually refresh, call `C-c r`. Technically, this calls
`revert-buffer-quick`. This has the following behavior:

-   Reverts the current buffer.
-   If the current file has been editing, a prompt will ask if it is OK to discard
    the changes.
-   If the current file is a compilation buffer, a prompt will ask if it is OK to
    rerun the command.

<!--listend-->

```emacs-lisp
(global-auto-revert-mode t)
;; Emacs default is 5, but we use a 1 second interval. This is usually fine on
;; modern a modern SSD or NVMe drive.
(setq auto-revert-interval 1)
(global-set-key (kbd "C-c r") #'revert-buffer-quick)
```


### Spell Correction {#spell-correction}

Flyspell is used to assist in spell correction. It assists in both general spell
correction for text modes (like Markdown and Org) as well as spell correction
within the comments of programming modes. Spell corrections manifest themselves
as red (or orange) squiggles that can be interacted with using the mouse middle
click or with `C-c a`.

```emacs-lisp
(require 'flyspell)
(require 'flyspell-correct)
(require 'flyspell-correct-ivy)
(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'text-mode-hook #'flyspell-mode)
(define-key flyspell-mode-map (kbd "C-c a") #'flyspell-correct-wrapper)
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


### Emojis {#emojis}

Emoji's can be inserted by running `M-x ivy-emoji` to select an emoji and insert
it.

```emacs-lisp
(require 'ivy-emoji)
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

Projectile automatically tracks known projects. However, there are some cases
where there is a valid project but we would normally not navigate their
directly. An example of this is projects under `.cargo` which are downloaded by
the compiler and navigated to when using "go to definition" of the library
functions.

```emacs-lisp
(defun w/projectile-project-is-ignored (root)
  "Returns t if the project at the given root should be ignored."
  (or (string-match-p "\.cargo" root)
      (string-match-p "\.rustup" root)))
(setq projectile-ignored-project-function #'w/projectile-project-is-ignored)
```


#### Hugo Projects {#hugo-projects}

Hugo is a framework for making static websites out of Markdown. To bring up a
demo for Hugo, the Hugo command is used. This is the perfect use case for using
the `gpu` command! However, Projectile needs to know that the command is safe to
run or else it will prompt the user every time. We allow list running Hugo
projects to reduce the friction.

```emacs-lisp
(add-to-list 'safe-local-variable-values '(projectile-project-run-cmd . "hugo server --buildDrafts"))
```

It's also useful to export on save. `w/export-to-hugo-on-save` can be used to
automatically export on save. It must be manually run.

```emacs-lisp
(defun w/export-to-hugo-on-save ()
  "Export to Hugo on save."
  (interactive)
  (add-hook 'after-save-hook #'org-hugo-export-to-md 0 t))
```


#### Literate Programming {#literate-programming}

```emacs-lisp
(defun w/tangle-on-save ()
  "Run tangle command on save."
  (interactive)
  (add-hook 'after-save-hook #'org-babel-tangle 0 t))
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


#### <span class="org-todo todo TODO">TODO</span> Git {#git}


### Disable File Backups {#disable-file-backups}

Emacs creates backup files by default. This is accomplished by creating a backup
of file `<file>` as `<file>~`. Although this seems good in theory, it is
somewhat noisy for the filesystem so I disable it. The lack of backups is fine
as:

-   File corruption is a very rare occurrence.
-   Important checkpoints are backed up with version control like git + GitHub.

<!--listend-->

```emacs-lisp
(setq make-backup-files nil
      auto-save-default nil)
```


### Eglot {#eglot}

Code refactoring depends on `eglot`. Eglot is an Emacs package that supports
interfacing with LSPs. See the
<https://microsoft.github.io/language-server-protocol> for more
details. Essentially Language Servers are servers that provide smart
functionality for specific languages. This is typically what people consider to
be "IDE" functionality. There are a few packages that require Eglot or at the
very least provide a better experience with Eglot.

Eglot is configured for each major mode separately. See the Language Specific
configurations sections to see if the Major Mode supports Eglot. For example,
`rust-mode` supports Eglot for enhanced functionality.


#### Code Refactoring {#code-refactoring}

```emacs-lisp
(require 'eglot)
(w/define-motion-key (kbd "<f2>") #'eglot-rename)
(w/define-motion-key (kbd "g.") #'eglot-code-actions)
```


#### Auto-Complete {#auto-complete}

The [Company](https://company-mode.github.io) Emacs Lisp package is used to handle auto complete. By default,
Company mode provides a simple completion engine. However, if an Eglot is
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


#### Syntax Checking {#syntax-checking}

Syntax checking is exposed through the flymake package which is bundled with
Emacs. To get improved syntax checking, Eglot needs to be enabled for the major
mode.

```emacs-lisp
(w/define-motion-key (kbd "<f8>") #'flymake-goto-next-error)
```


### Extra Utility Functions {#extra-utility-functions}

```emacs-lisp
(setq w/emacs-org-config (expand-file-name "emacs-config.org" user-emacs-directory))
(defun w/reload-emacs-config ()
  "Reload the emacs config."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory))
  (message "Emacs config reloaded."))

(defun w/open-emacs-config ()
  "Open the Emacs configuration."
  (interactive)
  (find-file (expand-file-name "emacs-config.org" user-emacs-directory)))

(defun w/is-emacs-org-config ()
  "Returns t if the current buffer is the primary org config"
  (string= w/emacs-org-config buffer-file-name))
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
  (eglot-ensure)
  (add-hook 'before-save-hook #'eglot-format-buffer 0 t))
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
(setq
 ;; wmedrano.dev is assumed to be under this specific directory.
 org-hugo-base-dir "~/src/wmedrano.dev"
 ;; Automatically set the "last modified" property.
 org-hugo-auto-set-lastmod t)
(defun w/setup-hugo-autoexport ()
  (when (w/is-emacs-org-config)
    (message (format "Setting up autoexport for %s" buffer-file-name))
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


#### <span class="org-todo todo TODO">TODO</span> Graphviz Support {#graphviz-support}

Graphviz is not fully supported yet. The desired behavior is to be able to
export graphs by adding `dot` source blocks within Org files.

```emacs-lisp
(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t))) ; this line activates dot
```


### YAML Mode {#yaml-mode}

```emacs-lisp
(require 'yaml-mode)
```


#### <span class="org-todo todo TODO">TODO</span> YAML Language Server {#yaml-language-server}

Warning: I have not gotten the YAML language server to run yet. I have been able
to install it, but encounter a crash at runtime. The crash has the error
`[stderr] SyntaxError: Unexpected token '?'`.

YAML requires installing the YAML language server to `~/.local/npm/bin`. This
can be installed with NPM by running:

```bash
npm install -g yaml-language-server --prefix ~/.local/npm
```

```emacs-lisp
(require 'yaml-mode)
(add-to-list 'eglot-server-programs
             '((yaml-mode) . ("~/.local/npm/bin/yaml-language-server")))
(defun w/setup-yaml-mode ()
  "Sets up the YAML major mode."
  ;; Eglot is commented out until the YAML language server is proven to
  ;; successfuly run.
  ;; (eglot-ensure)
  ;; (add-hook 'before-save-hook #'eglot-format-buffer 0 t)
  )
(add-hook 'yaml-mode-hook #'w/setup-yaml-mode)
```


## Other Modes {#other-modes}


### File Explorer - Dired Mode {#file-explorer-dired-mode}

`Dired Mode` is used for exploring the file system. It works well enough out of
the box but needs some tweaks for a better experience with Evil.

```emacs-lisp
(add-to-list 'evil-motion-state-modes 'dired-mode)
(defun w/wmedrano-dired-mode-setup ()
  "Set up dired mode."
  (define-key evil-motion-state-local-map (kbd "RET") #'dired-find-file))
(add-hook 'dired-mode-hook #'w/wmedrano-dired-mode-setup)
```


## Source Code {#source-code}

Source Code: <https://github.com/wmedrano/emacs-config/blob/main/emacs-config.org>