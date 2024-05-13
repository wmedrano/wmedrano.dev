;;; package -- Build script for wmedrano.dev
;;; Commentary:
;;;   Builds wmedrano.dev website by converting .org files into html.
;;; Code:
(require 'ox-publish)

(setq org-publish-project-alist
      '(
        ("wmedrano-home"
         :base-directory "./src"
         :publishing-function org-html-publish-to-html
         :publishing-directory "./site"
         :recursive nil
         :auto-sitemap nil
         :exclude ".*"
         :include ("index.org" "about.org")
         :with-toc nil
         :section-numbers nil
         :html-link-home "./"
         :html-link-up "./"
         :html-head "<style>body { padding: 1rem }</style>")
        ("wmedrano-posts"
         :base-directory "./src/posts"
         :publishing-function org-html-publish-to-html
         :publishing-directory "./site/posts"
         :recursive t
         :auto-sitemap t
         :sitemap-title "Posts"
         :sitemap-filename "index.org"
         :html-link-home "/.."
         :html-link-up "./index.html"
         :html-head "<style>body { padding: 1rem }</style>")
        ("wmedrano-site" :components ("wmedrano-home" "wmedrano-posts"))
        ))

(delete-directory "./site" t t)
(org-publish-project "wmedrano-site" t)

(provide 'build)
;;; build.el ends here
