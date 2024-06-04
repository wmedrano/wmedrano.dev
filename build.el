;;; package -- Build script for wmedrano.dev
;;; Commentary:
;;;   Builds wmedrano.dev website by converting .org files into html.
;;;   ~emacs -Q --script build.el~
;;; Code:
(require 'ox-publish)

(defun build-wmedrano-dev-site ()
  "Build wmedrano.dev website.

The static site is output into the site directory."
  (let ((org-html-home/up-format "
<div id=\"org-div-home-and-up\">
 <!--%s-->
 <a href=\"%s\">HOME</a>
</div>
")
        (org-html-link-up "../") ;; Unused. Required for home/up to render.
        (org-publish-project-alist
         `(("wmedrano-site" :components ("wmedrano-home" "wmedrano-posts"))
           ("wmedrano-home"
            :base-directory "./src"
            :publishing-directory "./src"
            :publishing-function org-html-publish-to-html
            :recursive nil
            :exclude ".*"
            :include ("index.org" "about.org")
            :with-toc nil
            :section-numbers nil
            :html-link-home "./"
            )
           ("wmedrano-posts"
            :base-directory "./src/posts"
            :publishing-directory "./src/posts"
            :publishing-function org-html-publish-to-html
            :recursive t
            :section-numbers nil
            :html-link-home "../.."
            )))
        (org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\"/>")
        (org-html-validation-link nil)
        (org-export-with-author nil)
        (org-export-with-date t))
    (org-publish-project "wmedrano-site" t)))

(build-wmedrano-dev-site)

(provide 'build)
;;; build.el ends here
