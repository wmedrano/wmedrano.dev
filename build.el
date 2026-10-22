;;; package --- Build wmedrano.dev
;;; Commentary:
;;; Code:

;; Install dependencies.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(package-install 'htmlize)
(package-install 'zig-mode)
(package-install 'rust-mode)
(package-install 'markdown-mode)

(require 'ox-publish)

(defvar wm-content-dir (expand-file-name "./content"))

(defun wm-org-html-canonical-url (input-file)
  "Return the canonical URL for INPUT-FILE relative to `wm-content-dir'."
  (let* ((rel (if (and input-file (string-prefix-p wm-content-dir input-file))
                  (substring input-file (length wm-content-dir))
                (file-relative-name (or input-file "") wm-content-dir)))
         (path (replace-regexp-in-string "^/" "" rel)))
    (concat "https://wmedrano.dev/"
            (cond
             ((string-match "\\(?:^\\|/\\)index\\.org$" path)
              (let ((dir (substring path 0 (match-beginning 0))))
                (if (equal dir "") "" (concat dir "/"))))
             (t (concat (file-name-sans-extension path) ".html"))))))

(defun wm-org-html-canonical-link (text backend info)
  (when (eq backend 'html)
    (let ((url (wm-org-html-canonical-url (plist-get info :input-file))))
      (replace-regexp-in-string "</head>"
                                (format "<link rel=\"canonical\" href=\"%s\">\n</head>" url)
                                text))))
(add-to-list 'org-export-filter-final-output-functions
             'wm-org-html-canonical-link)

(defun wm-strip-html-extension (text backend _info)
  "Strip .html extension from internal links in HTML output."
  (when (eq backend 'html)
    (unless (string-match-p "href=\"https?://" text)
      (replace-regexp-in-string "/index\\.html\\([#\"]\\)" "/\\1" text))))
(add-to-list 'org-export-filter-link-functions
             'wm-strip-html-extension)

;; Set options for exporting Org to HTML.
(setq
 ;; Do not use the built-in org mode html styling.
 org-html-style-default "
<link rel=\"icon\" type=\"image/svg+xml\" href=\"/favicon.svg\">
<link rel=\"icon\" type=\"image/png\" href=\"/favicon.png\">
<link rel=\"icon\" href=\"/favicon.ico\" sizes=\"any\">
<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css2?family=Spectral:ital,wght@0,400;0,600;0,700;1,400&family=Sometype+Mono:ital,wght@0,400;0,700;1,400&display=swap\">
<link rel=\"stylesheet\" href=\"/css/style.css\">
<link rel=\"stylesheet\" href=\"/css/syntax.css\">
"
 ;; When doing syntax highlighting, output as CSS classes instead of the default
 ;; inline CSS. To get the CSS for the current theme,
 ;; `(org-html-htmlize-generate-css)', or run tools/gen-syntax-css.sh.
 org-html-htmlize-output-type 'css
 ;; HTML shows home and up buttons at the top. We overwrite the default with our
 ;; own custom navigation bar.
 org-html-home/up-format "
<div class=\"navbar\" id=\"org-div-home-and-up\">
 <!--Ignore %s-->
 <a accesskey=\"H\" href=\"%s\">wmedrano dot dev</a>
  <a href=\"/about\">About</a>
</div>"
 ;; Set the home link to the homepage.
 org-html-link-home "/"
 ;; Drop the border/rules/frame attributes on tables; style.css handles them.
 org-html-table-default-attributes nil
 ;; Fix '_' and '^' behavior
 org-use-sub-superscripts nil
 org-export-with-sub-superscripts nil
 ;; The postamble shows up at the foot of the page.
 org-html-postamble t
 ;; A single quiet line with the author and date. This also drops the default
 ;; postamble's broken "Validation" link.
 org-html-postamble-format
 '(("en" "<p>%a · %d</p>")))


(let ((website (list "wmedrano dot dev"
                     :recursive t
                     :base-directory "./content"
                     :publishing-directory "./docs"
                     :publishing-function 'org-html-publish-to-html))
      ;; Publish files served verbatim from the site root (favicons,
      ;; verification, robots, css, etc.).
      (static (list "site static"
                    :recursive t
                    :base-directory "./static"
                    :base-extension 'any
                    :publishing-directory "./docs"
                    :publishing-function 'org-publish-attachment))
      (images (list "wmedrano dot dev images"
                    :recursive t
                    :base-directory "./content"
                    :base-extension "png\\|jpg\\|svg\\|ico\\|ogg"
                    :publishing-directory "./docs"
                    :publishing-function 'org-publish-attachment)))
  (setq-local org-publish-project-alist
              (list website static images))
  (org-publish-all t))

(provide 'build)
;;; build.el ends here
