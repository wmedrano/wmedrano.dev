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

;; Set options for exporting Org to HTML.
(setq
 ;; Do not use the built-in org mode html styling. Instead, import the custom
 ;; stylesheet defined at ./content/css/styles.css.
 org-html-style-default "
<link rel=\"icon\" type=\"image/svg+xml\" href=\"/favicon.svg\">
<link rel=\"icon\" type=\"image/png\" href=\"/favicon.png\">
<link rel=\"icon\" href=\"/favicon.ico\" sizes=\"any\">

<link rel=\"stylesheet\" href=\"/css/styles.css\">
<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
<link href=\"https://fonts.googleapis.com/css2?family=Baskervville:wght@700&family=Jost:ital,wght@0,100..900;1,100..900&family=Roboto+Mono:ital,wght@0,100..700;1,100..700&family=Sen:wght@400..800&display=swap\" rel=\"stylesheet\">
"
 ;; When doing syntax highlighting, output as CSS classes instead of the default
 ;; inline CSS. The color theme is defined in ./content/css/htmlize-styles.css. To get
 ;; the CSS for the current theme, `(org-html-htmlize-generate-css)'.
 org-html-htmlize-output-type 'css
 ;; HTML shows home and up buttons at the top. We overwrite the default with our
 ;; own custom navigation bar.
 org-html-home/up-format "
<div class=\"navbar\" id=\"org-div-home-and-up\">
 <!--Ignore %s-->
 <a accesskey=\"H\" href=\"%s\">wmedrano dot dev</a>
 <a href=\"/about.html\">About</a>
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
      ;; Define recipe for exporting static assets.
      ;; Publish files that must live at the domain root (verification, robots, sitemap, etc.).
      (meta (list "site meta"
                   :base-directory "./meta"
                   :publishing-directory "./public"
                   :publishing-function 'org-publish-attachment))
      (images (list "wmedrano dot dev images"
                    :recursive t
                    :base-directory "./content"
                    :base-extension "png\\|jpg\\|svg\\|ico\\|css\\|woff2\\|ogg"
                    :publishing-directory "./public"
                    :publishing-function 'org-publish-attachment)))
  (setq-local org-publish-project-alist
              (list website meta images))
  (org-publish-all t))

(provide 'build)
;;; build.el ends here
