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
             (t (file-name-sans-extension path))))))

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
      (replace-regexp-in-string "\\.html\\([#\"]\\)" "\\1" text))))
(add-to-list 'org-export-filter-link-functions
             'wm-strip-html-extension)

;; Set options for exporting Org to HTML.
(setq
 ;; Do not use the built-in org mode html styling. Instead, import the custom
 ;; stylesheet defined at ./static/css/styles.css.
 org-html-style-default "
<link rel=\"icon\" type=\"image/svg+xml\" href=\"/favicon.svg\">
<link rel=\"icon\" type=\"image/png\" href=\"/favicon.png\">
<link rel=\"icon\" href=\"/favicon.ico\" sizes=\"any\">

<link rel=\"stylesheet\" href=\"/css/styles.css\">
<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
<link href=\"https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,200..900;1,200..900&family=Roboto+Mono:wght@100..700&family=DM+Sans:ital,wght@0,100..1000;1,100..1000&display=swap\" rel=\"stylesheet\">
"
 ;; When doing syntax highlighting, output as CSS classes instead of the default
 ;; inline CSS. The color theme is defined in ./static/css/styles.css. To get
 ;; the CSS for the current theme, `(org-html-htmlize-generate-css)'.
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
 ;; Fix '_' and '^' behavior
 org-use-sub-superscripts nil
 org-export-with-sub-superscripts nil
 ;; The postamble shows up at the foot of the page.
 org-html-postamble t
 ;; We overwrite the default postamble to remove the broken "Validation" link.
 org-html-postamble-format
 '(("en" "
<div></div>
<p class=\"postamble-title\">Title: %t</p>
<p class=\"author\">Author: %a</p>
<p class=\"date\">Date: %d</p>
")))


(let ((website (list "wmedrano dot dev"
                     :recursive t
                     :base-directory "./content"
                     :publishing-directory "./public"
                     :publishing-function 'org-html-publish-to-html))
      ;; Publish files served verbatim from the site root (favicons,
      ;; verification, robots, css, etc.).
      (static (list "site static"
                    :recursive t
                    :base-directory "./static"
                    :base-extension 'any
                    :publishing-directory "./public"
                    :publishing-function 'org-publish-attachment))
      (images (list "wmedrano dot dev images"
                    :recursive t
                    :base-directory "./content"
                    :base-extension "png\\|jpg\\|svg\\|ico\\|ogg"
                    :publishing-directory "./public"
                    :publishing-function 'org-publish-attachment)))
  (setq-local org-publish-project-alist
              (list website static images))
  (org-publish-all t))

(provide 'build)
;;; build.el ends here
