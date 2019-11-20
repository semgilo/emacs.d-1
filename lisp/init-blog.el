(require-package 'ox-hugo)

(with-eval-after-load 'ox
  (require 'ox-hugo))

(defconst blog-root "~/Documents/git/www.lanhuzi.com1/blog")

;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
(with-eval-after-load 'org-capture
  (defun org-hugo-new-subtree-post-capture-template ()
    "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
    (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
           (fname (org-hugo-slug title)))
      (mapconcat #'identity
                 `(
                   ,(concat "* TODO " title)
                   ":PROPERTIES:"
                   ,(concat ":EXPORT_FILE_NAME: " fname)
                   ":END:"
                   "%?\n")              ;Place the cursor here finally
                 "\n")))

  (add-to-list 'org-capture-templates
               '("h"                    ;`org-capture' binding + h
                 "Hugo post"
                 entry
                 ;; It is assumed that below file is present in `org-directory'
                 ;; and that it has a "Blog Ideas" heading. It can even be a
                 ;; symlink pointing to the actual location of all-posts.org!
                 (file+olp "~/Documents/git/gtd/all-posts.org" "Blog Ideas")
                 (function org-hugo-new-subtree-post-capture-template))))


(defun semgilo/hugo-new-post (name)
  (interactive "sInput post name")
  (setq fullpath
        (concat
         blog-root
         "/content-org/"
         name
         ".org"))
  (find-file fullpath))

(defun semgilo/insert-org-img-link (path)
  (if (equal (file-name-extension (buffer-file-name)) "org")
      (insert (format "[[%s]]" path))))

(defun semgilo/capture-screenshot (filename)
  "Take a screenshot into a time stamped unique-named file in the
  same directory as the org-buffer/markdown-buffer and insert a link to this file."
  (interactive "sScreenshot name: ")
  (if (equal filename "")
      (setq filename (format-time-string "%Y%m%d_%H%M%S")))

  (setq cur-org-file-name-base (file-name-base (buffer-file-name)))
  (setq output-path
        (concat (file-name-directory (buffer-file-name))
                "/../static/images/"
                cur-org-file-name-base
                "/"
                filename
                ".png"))

  (setq blog-relative-path
        (concat "/images/"
                cur-org-file-name-base
                "/"
                filename
                ".png"))
  (message output-path)
  (setq output-dir (file-name-directory output-path))

  (unless (file-directory-p output-dir)
    (make-directory output-dir t))

  
  (progn
    (call-process "screencapture" nil nil nil "-s" output-path)
    (call-process "open" nil nil nil output-path)
    (semgilo/insert-org-img-link blog-relative-path))

  (insert "\n"))



(defun semgilo/record-screencapture (filename)
  "Take a screenshot into a time stamped unique-named file in the
  same directory as the org-buffer/markdown-buffer and insert a link to this file."
  (interactive "sScreenshot name: ")
  (call-process "/Applications/LICPcap.app" nil 0)
  )
  
(global-set-key [C-s-268632065] 'semgilo/capture-screenshot)

(provide 'init-blog)
