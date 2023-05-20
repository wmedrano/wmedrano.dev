(
 (nil . ((projectile-project-run-cmd . "hugo server --buildDrafts")))
 (org-mode . (
              ;; Set the base directory for Hugo. This is hard coded but should
              ;; ideally be inferred to be the directory .dir-locals.el is in.
              (org-hugo-base-dir . "~/src/wmedrano.dev"))
              (org-hugo-default-static-subdirectory-for-externals . "ox-hugo/wmedrano-dev")
              (mode . org-hugo-auto-export))
 )
