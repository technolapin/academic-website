;; (require 'org)
;; (require 'org-roam)
;; (require 'org-roam-ui)

(require 'org-roam-export)
(require 'org-roam-protocol)

(setq dir-root default-directory)
(setq dir-build  (concat dir-root   "build/" ))
(setq dir-assets (concat dir-root   "assets/"))
(setq dir-images (concat dir-assets "images/"))
(setq dir-css    (concat dir-assets "css/"   ))


; need a default directory
(setq org-roam-directory (file-truename "org"))
; (setq find-file-visit-truename t)
;(org-roam-db-autosync-mode)
(setq org-roam-db-location (concat dir-root "org-roam.db"))
(server-start)

;; the sitemap.html file
(defun roam-sitemap (title list)
  (concat "#+OPTIONS: ^:nil author:nil html-postamble:nil\n"
          "#+SETUPFILE: ./simple_inline.theme\n"
          "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"" "../assets/css/wiki.css\" />\n"
          "#+TITLE: " title "\n\n"
          (org-list-to-org list) "\n"
          "#+ATTR_HTML: :width 100px\
[[../assets/images/selphie.png]]" ))


(setq org-html-validation-link nil)
(setq my-publish-time 0)   ; see the next section for context
(defun roam-publication-wrapper (plist filename pubdir)
;  (org-roam-graph)
  (org-html-publish-to-html plist filename pubdir)
  (setq my-publish-time (cadr (current-time))))

(setq org-publish-project-alist
  `(("roam"
     :base-directory ,org-roam-directory
     :auto-sitemap t
     :sitemap-function roam-sitemap
     :sitemap-title "Roam notes"
     :publishing-function roam-publication-wrapper
     :publishing-directory ,dir-build
     :section-number nil
     :table-of-contents nil
     :html-head ,(concat "<link rel=\"stylesheet\" href=\"" "../assets/css/" "wiki.css\" type=\"text/css\">") ; ne marche pas???
     )))



; y'a un truc bizarre de parenthèsage, on dirait qu'il en manque une mais en fait non
(add-hook 'org-roam-graph-generation-hook
          (lambda (dot svg) (if (< (- (cadr (current-time)) my-publish-time) 5)
                                (progn (copy-file svg (concat dir-build "sitemap.svg") 't)
                                       (kill-buffer (file-name-nondirectory svg))
                                       (setq my-publish-time 0)))))





; for handy image inserting (does not work with tramp)
(use-package org-download
  :after org
  :bind
  (:map org-mode-map
        (("s-Y" . org-download-screenshot)
         ("s-T" . org-download-yank))))
(setq org-download-screenshot-method "xfce4-screenshooter -r -o cat > %s") 
(setq org-download-image-dir dir-images)


; allows to have a body when capturing a node (with firefox for instance)
; cf https://org-roam.discourse.group/t/org-roam-protocol-not-appending-body/2694/3
(setq org-roam-capture-ref-templates
      '(("d" "default" plain
         "%?"
         :if-new (file+head "${slug}.org" "#+title: ${title}\n")
         :unnarrowed t)
        ("r" "ref" plain
         "%?"
         :target
         (file+head "${slug}.org" "#+title: ${title}\n[[${ref}][link]]\n\n${body}")
         :unnarrowed t)))
;; force the inline image size to be 300 dpi, so that it does not takes too much space and freeze emacs
;; if emacs freezes because of an image too wide, C-g unfreezes it.
(setq org-image-actual-width 300)

(message "Finished project setup")



(keymap-global-set "C-S-a" 'org-roam-node-insert)
(keymap-global-set "C-S-z" 'org-id-get-create)
(keymap-global-set "C-S-e" 'org-roam-node-find)

