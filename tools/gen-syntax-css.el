;;; gen-syntax-css.el --- Write htmlize CSS for the current Emacs theme -*- lexical-binding: t; -*-
;;; Commentary:
;; Must run in a graphical frame; batch mode has no face colors.  Use
;; tools/gen-syntax-css.sh rather than loading this directly.
;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(package-initialize)
(require 'ox-html)
(require 'htmlize)
(dolist (mode '(rust-mode zig-mode markdown-mode css-mode))
  (require mode))

;; Only export faces that can show up in code blocks.
(advice-add 'face-list :filter-return
            (lambda (faces)
              (seq-filter
               (lambda (face)
                 (string-match-p "\\`\\(font-lock\\|rust\\|zig\\|markdown\\|css\\)-"
                                 (symbol-name face)))
               faces)))

(let ((out (getenv "SYNTAX_CSS_OUT")))
  (condition-case err
      (progn
        (org-html-htmlize-generate-css)
        (write-region (point-min) (point-max) out)
        (kill-emacs 0))
    (error (message "%S" err)
           (kill-emacs 1))))

;;; gen-syntax-css.el ends here
