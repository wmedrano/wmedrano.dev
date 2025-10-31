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

(require 'ox-publish)

;; Set options for exporting Org to HTML.
(setq
 ;; Do not use the built-in org mode html styling. Instead, import the custom
 ;; stylesheet defined at ./content/css/styles.css.
 org-html-style-default "
<link rel=\"stylesheet\" href=\"/css/htmlize-styles.css\">
<link rel=\"stylesheet\" href=\"/css/styles.css\">
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
      (images (list "wmedrano dot dev images"
                    :recursive t
                    :base-directory "./content"
                    :base-extension "png\\|svg\\|css"
                    :publishing-directory "./public"
                    :publishing-function 'org-publish-attachment)))
  (setq-local org-publish-project-alist
              (list website images))
  (org-publish-all t))

(provide 'build)
;;; build.el ends here
