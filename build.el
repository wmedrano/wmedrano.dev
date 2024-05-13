;;; package -- Build script for wmedrano.dev
;;; Commentary:
;;;   Builds wmedrano.dev website by converting .org files into html.
;;; Code:
(require 'ox-publish)

(defun build-wmedrano-dev-site ()
  (let ((org-publish-project-alist
         '(("wmedrano-site" :components ("wmedrano-home" "wmedrano-posts"))
           ("wmedrano-home"
            :base-directory "./src"
            :publishing-function org-html-publish-to-html
            :publishing-directory "./site"
            :recursive nil
            :exclude ".*"
            :include ("index.org" "about.org")
            :with-toc nil
            :section-numbers nil
            :html-link-home "./"
            :html-link-up "./")
           ("wmedrano-posts"
            :base-directory "./src/posts"
            :publishing-function org-html-publish-to-html
            :publishing-directory "./site/posts"
            :recursive t
            :auto-sitemap t
            :sitemap-title "Posts"
            :sitemap-filename "index.org"
            :html-link-home "/.."
            :html-link-up "./index.html")))
        (org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"/>")
        (org-html-validation-link nil))
    (org-publish-project "wmedrano-site" nil)
    (copy-file "src/style.css" "site/style.css" t)))

(build-wmedrano-dev-site)

(provide 'build)
;;; build.el ends here
