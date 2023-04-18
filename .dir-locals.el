(
 (org-mode . (
              ;; Set the base directory for Hugo. This is hard coded but should
              ;; ideally be inferred to be the directory .dir-locals.el is in.
              (org-hugo-base-dir . "~/src/wmedrano.dev")
              ;; Auto export Org files after saving.
              (eval . (org-hugo-auto-export-mode))
              ))
 )
