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
(setq
 org-html-style-default "
 <link rel=\"stylesheet\"
          href=\"https://fonts.googleapis.com/css?family=Quicksand\">
<link rel=\"stylesheet\" href=\"/css/styles.css\">
"
 org-html-htmlize-output-type 'css
 org-html-link-home "/"
 org-html-home/up-format "
<div class=\"navbar\" id=\"org-div-home-and-up\">
 <!--Ignore %s-->
 <a accesskey=\"H\" href=\"%s\">wmedrano dot dev</a>
</div>"
 org-html-postamble t
 org-html-postamble-format
 '(("en" "
<div></div>
<p class=\"postamble-title\">Title: %t</p>
<p class=\"author\">Author: %a</p>
<p class=\"date\">Date: %d</p>
"
)))
(setq website
      (list "wmedrano dot dev"
            :recursive t
            :base-directory "./content"
            :publishing-directory "./public"
            :publishing-function 'org-html-publish-to-html))
(setq images
      (list "wmedrano dot dev images"
            :recursive t
            :base-directory "./content"
            :base-extension "png\\|svg\\|css"
            :publishing-directory "./public"
            :publishing-function 'org-publish-attachment))
(setq-local org-publish-project-alist
      (list website images))

(org-publish-all t)

(provide 'build)
;;; build.el ends here
