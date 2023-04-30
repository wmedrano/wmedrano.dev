+++
title = "Emacs Configuration"
author = ["Will S. Medrano"]
date = 2023-04-18
lastmod = 2023-04-30T14:03:29-07:00
draft = false
+++

{{< figure src="/ox-hugo/gnu.png" >}}


## Introduction {#Introduction-g4g72r913tj0}

This page describes my (will.s.medrano@gmail.com) Emacs configuration. Emacs is
a highly customizable text editor that can be customized with Emacs Lisp. This
page is written in Org and is the primary [source code](https://github.com/wmedrano/emacs-config) for the actual Emacs
configuration!


### Org Mode {#IntroductionOrgMode-c5h72r913tj0}

This Emacs configuration is written with Emacs Org Mode.

<div class="verse">

A **GNU Emacs** major mode for keeping notes, authoring documents, computational<br />
notebooks, literate programming, maintaining to-do lists, planning projects,<br />
and more --- in a fast and effective plain text system.<br />
<br />
&nbsp;&nbsp;&nbsp;--- <https://orgmode.org><br />

</div>

The primary data flows are:

-   emacs-config.org &rarr; emacs-config.html for displaying in a website.
-   emacs-config.org &rarr; init.el for use with Emacs. This is done by running
    Emacs Lisp function `org-babel-tangle` with `emacs-config` in the `~.emacs.d`
    directory. This exports the code blocks to file.

Using Org Mode to write an Emacs configuration is a form of Literate
Programming. Literate Programming is a paradigm that combines the code and
documentation to provide a literate document that also serves as the source
code. However, the main drawback is reduced "IDE" support. Standard code
documentation and auto-complete packages are broken out of the box.


#### Coding Conventions {#IntroductionOrgModeCodingConventions-hwh72r913tj0}

All custom functions are prefixed with `w/` since Emacs lisp does not support
officially support name-spacing.


#### Bootstrapping {#IntroductionOrgModeBootstrapping-0ni72r913tj0}

To use this configuration, load the source code from the main Emacs config and
run `M-x org-babel-tangle`. This will generate `init.el` which can be placed in
`~/.emacs.d/`.

```emacs-lisp-code
(org-babel-load-file (expand-file-name "emacs-config.org" user-emacs-directory))
```

Following this, dependencies should be (re)installed.


#### Dependencies {#IntroductionOrgModeDependencies-3fj72r913tj0}

Several packages are installed from [Melpa](https://melpa.org/#/). Check out the website for any recent
package updates or

```emacs-lisp
(require 'package)
;; Taken from https://melpa.org/#/getting-started
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-selected-packages '(
                                  ace-window
                                  all-the-icons-ivy-rich
                                  company
                                  company-box
                                  counsel
                                  counsel-projectile
                                  diff-hl
                                  dracula-theme
                                  doom-modeline
                                  eglot
                                  evil
                                  evil-anzu
                                  evil-commentary
                                  evil-surround
                                  evil-terminal-cursor-changer
                                  flyspell-correct
                                  flyspell-correct-ivy
                                  graphviz-dot-mode
                                  htmlize
                                  ivy
                                  ivy-emoji
                                  ivy-rich
                                  ivy-posframe
                                  magit
                                  markdown-mode
                                  monokai-pro-theme
                                  nord-theme
                                  org-sidebar
                                  org-unique-id
                                  ox-gfm
                                  ox-hugo
                                  projectile
                                  rust-mode
                                  swiper
                                  toml-mode
                                  which-key
                                  yaml-mode
                                  ))
(package-initialize)
```

`M-x w/install-dependencies` installs all the dependencies and prunes any that
are no longer needed.

```emacs-lisp
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


## Basics {#Basics-g7k72r913tj0}


### Theme {#BasicsTheme-1tk72r913tj0}

```emacs-lisp
(require 'monokai-pro-theme)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("24168c7e083ca0bbc87c68d3139ef39f072488703dcdd82343b8cab71c0f62a7" "f681100b27d783fefc3b62f44f84eb7fa0ce73ec183ebea5903df506eb314077" default))
 '(package-selected-packages
   '(evil-anzu company-quickhelp ace-window all-the-icons-ivy-rich company company-box counsel counsel-projectile diff-hl dracula-theme doom-modeline eglot evil evil-commentary evil-surround evil-terminal-cursor-changer flyspell-correct flyspell-correct-ivy graphviz-dot-mode htmlize ivy ivy-emoji ivy-rich ivy-posframe magit markdown-mode monokai-pro-theme nord-theme org-sidebar org-unique-id ox-gfm ox-hugo projectile rust-mode swiper toml-mode which-key yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(load-theme 'monokai-pro)
(set-frame-font "Fira Code 12")
(when (display-graphic-p)
  (set-frame-parameter (selected-frame) 'alpha '(97 . 97)))
```

Use a posframe for ivy completion. By default, completions are at the bottom of
the frame. Posframes allow these to move anywhere on the frame. I move it to
`point` to prevent having to focus on a different part of the screen.

```emacs-lisp
(require 'ivy-posframe)
(setq ivy-posframe-style 'point
      ivy-posframe-font "Fira Code 13"
      ivy-posframe-border-width 4
      ivy-height 20)
(ivy-posframe-mode t)
```


### Line Numbering {#BasicsLineNumbering-efl72r913tj0}

```emacs-lisp
;; Show the line number on the left of the editor with a minimum of 3
;; characters. The default minimum is too low
(setq display-line-numbers-grow-only t)
(global-display-line-numbers-mode t)
(global-hl-line-mode t)
;; Display the column number in the modeline. Admittedly, the number appears all
;; the way to the right in the modeline. This means that it is not visible for
;; smaller windows.
(column-number-mode t)
(unless (display-graphic-p)
  (require 'evil-terminal-cursor-changer)
  (evil-terminal-cursor-changer-activate))
```


### Mode Line {#BasicsModeLine-i2m72r913tj0}

[Doom Modeline](https://github.com/seagle0128/doom-modeline#customize) is used to create a pretty modeline. See the [documentation for
more options.](https://github.com/seagle0128/doom-modeline#customize)

```emacs-lisp
(require 'doom-modeline)
(doom-modeline-mode t)
(setq
 ;; Make the modeline as small as possible. This usually shrinks it down to be
 ;; slightly larger than the font size.
 doom-modeline-height 0
 ;; Don't show the word count. This is the default since it may cause
 ;; slowness.
 doom-modeline-enable-word-count nil
 ;; Use doom to show the battery. This does not enabling displaying batter and
 ;; requires entering display-battery-mode.
 doom-modeline-battery t
 doom-modeline-unicode-fallback t)
```


#### In Editor Help and Documentation {#BasicsModeLineInEditorHelpandDocumentation-1rm72r913tj0}

Emacs provides plenty of built in help. There are several functions that can be
activated with `M-x`.

-   `describe-variable` - Open the documentation and source code for an Emacs Lisp
    variable. Also accessible with `C-h v`.
-   `describe-function` - Open the documentation and source code for an Emacs Lisp
    function. Also accessible with `C-h f`.
-   `describe-key` - After running, the next key map action will be recorded. This
    will then open the documentation for the function that runs when that key is
    pressed. For example, in the default normal state of Evil, pressing
    `describe-key` followed by `j` opens the documentation for
    `evil-next-line`. Also accessible with `C-h k`.

`which-key-mode` is used to print out the available keys in scenarios where keys
are changed. For example, when pressing `C-h`, a small popup with help
information will show after a small delay.

```emacs-lisp
(require 'which-key)
(setq which-key-idle-delay 0.5)
(which-key-mode t)
```


#### Noise Reduction {#BasicsModeLineNoiseReduction-lgn72r913tj0}

This section contains configuration that removes noisy elements from the UI.

```emacs-lisp
(setq inhibit-startup-screen t
      ring-bell-function 'ignore)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
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


### Key Bindings {#BasicsKeyBindings-m5o72r913tj0}

The keybindings are based around the [Evil](https://www.emacswiki.org/emacs/Evil) package. Evil is the most popular
Emacs package that implements VIM key bindings. The key bindings present in this
section are basic bindings. More specific bindings are littered throughout this
document.

```emacs-lisp
(defun w/define-motion-key (keys fn)
  "Define a new motion key binding on KEYS that runs function FN."
  (define-key evil-normal-state-map keys nil)
  (define-key evil-motion-state-map keys fn))
```


#### Bindings {#BasicsKeyBindingsBindings-muo72r913tj0}

Enable Evil mode globally to use VIM like modal editing.

```emacs-lisp
(evil-mode)
(defalias 'forward-evil-word 'forward-evil-symbol)
;; Jumps to definition. If Eglot is active, then the language server is used
;; to find the definition.
(w/define-motion-key (kbd "gd") #'evil-goto-definition)
;; Fuzzy search through all open buffers.
(w/define-motion-key (kbd "g/") #'swiper)
;; Paste contents into the current cursor. This is used to keep consistency of
;; the paste command in terminal and GUI modes. Most terminal emulators paste
;; the current clipboard text on C-S-v.
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

```emacs-lisp
(global-evil-surround-mode t)
```

To navigate windows, `gw` is used to bring up an interactive menu that supports
the following commands:

-   `<number>` - Each window is given a number. Selecting a number will jump to
    that window.
-   `m <number>` - Swap window.
-   `x <number>` - Close the window.
-   `v <number>` - Split the window vertically.
-   `b <number>` - Split the window horizontally.
-   `F <number>` - Split the window either vertically or horizontally, whichever
    is more fair.
-   `o <number>` - Maximize the selected window.
-   `?` - Show help menu. This reveals tons of other prefix keys.

<!--listend-->

```emacs-lisp
;; Always show the dispatch menu even if there are only 2 options.
(setq aw-dispatch-always t)
(global-set-key (kbd "C-w") #'ace-window)
(w/define-motion-key (kbd "gw") #'ace-window)
;; Required to override Evil's window switching functionality.
(w/define-motion-key (kbd "C-w") #'ace-window)
```

Emacs has a habit of asking `yes` or `no` questions. This requires entering the
whole word but I prefer to just type `y` or `n`.

```emacs-lisp
(defalias 'yes-or-no-p 'y-or-n-p)
```


#### Mini-Buffer Completions {#BasicsKeyBindingsMiniBufferCompletions-8lp72r913tj0}

By default Emacs does not show completions in the minibuffer unless Tab is
pressed. And even then, the completions could be improved. Ivy is used for fuzzy
minibuffer completions. Counsel is also used to wrap common built in Emacs
methods to use Ivy minibuffer completion. See <https://github.com/abo-abo/swiper>.

{{< figure src="./screenshots/minibuffer.png" >}}

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


#### Mouse and Scrolling {#BasicsKeyBindingsTerminalMouseSupport-5hygwil09tj0}

Enable using the mouse in terminal mode.

```emacs-lisp
(xterm-mouse-mode t)
```

When scrolling, the cursor generally stays on the same position. However, if we
scroll out of the range of the cursor, then the cursor it clamped to the nearest
point; this is usually the first or last visible point in the window. However,
this behavior is disorienting so scroll lock is enabled to keep the cursor on
the same spot on the screen.

```emacs-lisp
(scroll-lock-mode t)
```


## Text and Formatting {#TextandFormatting-r9q72r913tj0}


### Search {#TextandFormattingSearch-fq73xbx0atj0}

```emacs-lisp
(define-key evil-motion-state-map (kbd "/") #'evil-search-forward)
```

Evil anzu is used to display the current candidate number and the total
candidates at the bottom left.

```emacs-lisp
(require 'evil-anzu)
(global-anzu-mode t)
(setq anzu-minimum-input-length 2)
```


### Refreshing {#TextandFormattingRefreshing-4xq72r913tj0}

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
(w/define-motion-key (kbd "gr") #'revert-buffer-quick)
```


### Spell Correction {#TextandFormattingSpellCorrection-qlr72r913tj0}

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


### Auto Fill {#TextandFormattingAutoFill-mas72r913tj0}

Auto fill mode implements automatic line breaking. That is, lines will
automatically be formatted to fit within (by default) 80 characters.

```emacs-lisp
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode)
```


### Tabs &amp; Spaces {#TextandFormattingTabsSpaces-m0t72r913tj0}

By default, spaces are preferred over tabs. Additionally, pressing the tab key
does not insert a tab. Instead, it auto-formats the indentation on the current
line/region.

```emacs-lisp
;; Prefer using spaces over tabs.
(setq-default indent-tabs-mode nil)
;; Trim all trailing whitespace before saving.
(add-hook 'before-save-hook #'delete-trailing-whitespace)
```


### Parenthesis and Braces {#TextandFormattingParenthesisandBraces-uqt72r913tj0}

Matching end parenthesis and braces are automatically inserted.

```emacs-lisp
(electric-pair-mode t)
```


### Emojis {#TextandFormattingEmojis-0fu72r913tj0}

Emoji's can be inserted by running `M-x ivy-emoji` to select an emoji and insert
it.

```emacs-lisp
(require 'ivy-emoji)
```


## Advanced {#Advanced-o1v72r913tj0}


### Project Management {#AdvancedProjectManagement-6pv72r913tj0}

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


#### Hugo Projects {#AdvancedProjectManagementHugoProjects-sfw72r913tj0}

Hugo is a framework for making static websites out of Markdown. To bring up a
demo for Hugo, the Hugo command is used. This is the perfect use case for using
the `gpu` command! However, Projectile needs to know that the command is safe to
run or else it will prompt the user every time. We allow list running Hugo
projects to reduce the friction.

```emacs-lisp
(add-to-list 'safe-local-variable-values
             '(projectile-project-run-cmd . "hugo server --buildDrafts"))
```

It's also useful to export on save. `org-hugo-auto-export-mode` can be enabled
for this.


### Version Control {#AdvancedVersionControl-oux72r913tj0}

```emacs-lisp
(require 'diff-hl)
(global-diff-hl-mode t)
;; Terminal's do not support fringes so we have to fall back to use the
;; margin.
(when (not (display-graphic-p))
  (diff-hl-margin-mode t))
```


#### <span class="org-todo todo TODO">TODO</span> Git {#AdvancedVersionControlGit-5jy72r913tj0}


### Disable File Backups {#AdvancedDisableFileBackups-d7z72r913tj0}

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


### Eglot {#AdvancedEglot-1wz72r913tj0}

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


#### Code Refactoring {#AdvancedEglotCodeRefactoring-xk082r913tj0}

```emacs-lisp
(require 'eglot)
(w/define-motion-key (kbd "<f2>") #'eglot-rename)
(w/define-motion-key (kbd "g.") #'eglot-code-actions)
```


#### Auto-Complete {#AdvancedEglotAutoComplete-7a182r913tj0}

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

Company box mode is used since it looks a little bit better. However, it is only
compatible with GUI mode. Additionally, the help/documentation background shows
up as white with sometimes white text, depending on the theme. The issue is
mitigated by hardcoding the background color.

```emacs-lisp
(when (display-graphic-p)
  (require 'company-box)
  (setq company-quickhelp-color-background "dim gray")
  (add-hook 'company-mode #'company-box-mode))
```


#### Syntax Checking {#AdvancedEglotSyntaxChecking-80282r913tj0}

Syntax checking is exposed through the flymake package which is bundled with
Emacs. To get improved syntax checking, Eglot needs to be enabled for the major
mode.

```emacs-lisp
(w/define-motion-key (kbd "<f8>") #'flymake-goto-next-error)
```

```emacs-lisp
(defun w/force-eglot-didSave ()
  "Forces eglot to communicate a didSave signal. This usually kicks off syntax
  checking."
  (when (eglot-managed-p)
    (message "Forcing Eglot to send didSave signal.")
    (message nil)
    (eglot--signal-textDocument/didSave)))
(add-hook 'after-revert-hook #'w/force-eglot-didSave)
```


### Extra Utility Functions {#AdvancedExtraUtilityFunctions-op282r913tj0}

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


## Language Specific Configurations {#LanguageSpecificConfigurations-he382r913tj0}


### Rust Mode {#LanguageSpecificConfigurationsRustMode-93482r913tj0}

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


## Org Mode {#TextSpecificConfigurationsOrgMode-y5682r913tj0}

Org Mode is a mode for general writing, organizing, planning, and literate
programming.

-   Source code blocks should be syntax highlighted.

<!--listend-->

```emacs-lisp
(setq org-src-fontify-natively t)
```

-   Saving any file creates unique IDs for any headers without an ID.

<!--listend-->

```emacs-lisp
(defun w/setup-org-mode ()
  (require 'org-unique-id)
  (add-hook 'before-save-hook #'org-unique-id 0 t))
(add-hook 'org-mode-hook #'w/setup-org-mode)
```


### Useful Keybindings {#TextSpecificConfigurationsOrgModeUsefulKeybindings-uv682r913tj0}

-   `C-c C-c` - Run the code block at the cursor.
-   `C-c C-j` - Jump to a section within the Org file.
-   `C-c C-l` - Insert or update a link.
-   `TAB` on header - Expand or collapse the section.
-   `Shift + TAB` - Collapse all headers.
-   Evil normal state + `gl` - Open the Org reference This works in all modes, not
    just Org mode. Org references look like:
    `[[file:emacs-config.org::#something][Something:1]]`

<!--listend-->

```emacs-lisp
(require 'org)
(define-key org-mode-map (kbd "C-c C-j") #'counsel-org-goto)
(w/define-motion-key (kbd "gl") #'org-open-at-point-global)
```


### Code Blocks {#OrgModeCodeBlocks-omqb0u114tj0}

Code blocks can be inserted in Org Mode using the `#+begin_src`.

```org
#+begin_src <language> <header-args...>
  <source code>
#+end_src
```

See [Header Arguments](https://orgmode.org/manual/Using-Header-Arguments.html) documentation. Some popular header args:

-   `:tangle <filename>` - Where to tangle the file.
-   `:comments link` - If tangled source code should include references to the Org
    document. This allows detangling the code to incorporate it back into the org
    document.
-   `:results replace|silent` - If the results of code evaluating (C-c C-c) should
    be shown.
-   `:exports code|results|none` - If the code block should be exported as a code
    block, the results only, or not at all.

Header arguments may be set file wide. To do this, use `:PROPERTIES:` as the
first line in the file. Example:

```org
:PROPERTIES:
:header-args: :results silent
:END:
```


#### Executing {#OrgModeCodeBlocksExecutingCodeBlocks-7vvf5e314tj0}

Code blocks can be executed by selecting them with the cursor and running `C-c
C-c`. This prompts for y-or-n if the code should be evaluated and evaluates the
code if it is requested. The prompt can also be disabled for the file by setting
a local variable:

```emacs-lisp
(setq-local org-confirm-babel-evaluate nil)
```


#### Editing {#OrgModeCodeBlocksEditing-2hvafd119tj0}

Source code blocks can be edited in a different buffer and window with `C-c
C-'`. To save the contents and return to the Org document, save the file or use
`C-c C-'`.

```emacs-lisp
(define-key org-src-mode-map (kbd "C-s") #'org-edit-src-exit)
(define-key org-src-mode-map (kbd "C-c C-'") #'org-edit-src-exit)
```


#### Tangling/Untangling {#OrgModeCodeBlocksTangling-9rog60i09tj0}

Tangling takes the Org document and writes any blocks with `:tangle <filename>`
to their file. The inverse of this is detangling. Detangling in a tangled source
file updates the Org document contents according to the source code. Note that
detangling requires that the `:comments link` property is set and that all the
code in the source file is surrounded by valid Org links.

-   `org-babel-tangle` - Tangle the current Org document.
-   `org-babel-detangle` - Detangle the current source code.

Org files may automatically be tangled on save with
`org-babel-auto-tangle-mode`.

```emacs-lisp
(require 'ob-tangle)
(defun org-babel-detangle-keep-window ()
  "Detangles the current source file while staying on the current window. This
  is as opposed to the default behavior of detangling and opening the tangled
  file."
  (interactive)
  (let* ((keep-window (selected-window))
         (keep-buffer (window-buffer keep-window))
         (keep-window-count (length (window-list)))
         (point-before-tangle (point)))
    (org-babel-detangle)
    (set-window-buffer keep-window keep-buffer)
    ;; Close a newly opened window the state originally only had a single window
    ;; open.
    (if (eq keep-window-count 1)
        (delete-other-windows keep-window)
      (select-window keep-window))
    (goto-char point-before-tangle)))
```

```emacs-lisp
;; Declare variables to prevent warning:
;; File local-variables error: (void-function org-babel-auto-detangle-mode)
(define-minor-mode org-babel-auto-tangle-mode
  "Toggle auto tangling on save."
  :lighter "tangle"
  (defvar org-babel-auto-tangle-mode)
  (if org-babel-auto-tangle-mode
      (add-hook 'after-save-hook #'org-babel-tangle :append :local)
    (remove-hook 'after-save-hook #'org-babel-tangle :local)))

(define-minor-mode org-babel-auto-detangle-mode
  "Toggle auto detangling on save."
  :lighter "detangle"
  (defvar org-babel-auto-detangle-mode nil)
  (if org-babel-auto-detangle-mode
      (add-hook 'after-save-hook #'org-babel-detangle-keep-window :append :local)
    (remove-hook 'after-save-hook #'org-babel-detangle-keep-window :local)))
```


### Static Site Generation - Hugo {#TextSpecificConfigurationsOrgModeStaticSiteGenerationHugo-8m782r913tj0}

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
```


### GitHub Markdown {#TextSpecificConfigurationsOrgModeGitHubMarkdown-jd882r913tj0}

GitHub markdown is known as GitHub flavored Markdown. The `ox-gfm` package
provides `M-x org-gfm-export-as-markdown` to export to this specific flavor of
Markdown.

```emacs-lisp
(require 'ox-gfm)
```


### <span class="org-todo todo TODO">TODO</span> Graphviz Support {#TextSpecificConfigurationsOrgModeGraphvizSupport-g5982r913tj0}

Graphviz is not fully supported yet. The desired behavior is to be able to
export graphs by adding `dot` source blocks within Org files.

```emacs-lisp
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (dot . t)))
```


## Text Specific Configurations {#TextSpecificConfigurations-qr482r913tj0}


### Graphviz Dot Mode {#TextSpecificConfigurationsGraphvizDotMode-y1tf32a13tj0}

Support for graphviz dot files. [Graphviz](https://graphviz.org/) is a graph visualization software.

```emacs-lisp
(require 'graphviz-dot-mode)
```


### Markdown Mode {#TextSpecificConfigurationsMarkdownMode-rg582r913tj0}

```emacs-lisp
(require 'markdown-mode)
```


### YAML Mode {#TextSpecificConfigurationsYAMLMode-5x982r913tj0}

```emacs-lisp
(require 'yaml-mode)
```


#### <span class="org-todo todo TODO">TODO</span> YAML Language Server {#TextSpecificConfigurationsYAMLModeYAMLLanguageServer-3qa82r913tj0}

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


## Other Modes {#OtherModes-kgb82r913tj0}


### File Explorer - Dired Mode {#OtherModesFileExplorerDiredMode-o6c82r913tj0}

`Dired Mode` is used for exploring the file system. It works well enough out of
the box but needs some tweaks for a better experience with Evil.

```emacs-lisp
(add-to-list 'evil-motion-state-modes 'dired-mode)
(evil-define-key 'motion dired-mode-map (kbd "RET") #'dired-find-file)
```


## Source Code {#SourceCode-1wc82r913tj0}

Source Code: <https://github.com/wmedrano/emacs-config/blob/main/emacs-config.org>


### Directory Local Variables {#SourceCodeDirectoryLocalVariables-pqcla5019tj0}

Directory local variables can be used to set Emacs variables for all files
within a directory. To make use of this, create a `.dir-locals.el` file. The
directory local variables for this repo help in auto exporting to Hugo as well
as keeping the Org and Emacs Lisp in sync.

```lisp-data
;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")
(("init.el" . ((mode . org-babel-auto-detangle)))
 (".dir-locals.el" . ((mode . org-babel-auto-detangle)))
 (org-mode . ((org-hugo-section . "literate-programs")
              (mode . org-babel-auto-tangle)
              (mode . org-hugo-auto-export)
              )))
```
