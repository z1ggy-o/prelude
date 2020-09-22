(setq default-frame-alist '((font . "Sarasa Mono SC 16")))

;; Turn on auto-fill-mode in org-mode
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;; Pinyin Input
(prelude-require-package 'pyim)
(require 'pyim)
(add-to-list 'load-path "~/.emacs.d/elpa/pyim-greatdict/")
(require 'pyim-greatdict)  ;; a dict that has more than 3 million vocabularies. Need to install manually
(pyim-greatdict-enable)

(setq default-input-method "pyim")
(setq pyim-default-scheme 'xiaohe-shuangpin)
(defun evil-toggle-input-method ()
  "when toggle on input method, switch to evil-insert-state if possible.
when toggle off input method, switch to evil-normal-state if current state is evil-insert-state"
  (interactive)
  (if (not current-input-method)
      (if (not (string= evil-state "insert"))
          (evil-insert-state))
    (if (string= evil-state "insert")
        (evil-normal-state)))
  (toggle-input-method))

(global-set-key (kbd "C-\\") 'evil-toggle-input-method)

;; Use command key as meta in macOS, that means we need to use Alt+C/V to copy/paste
(cond
 ((string-equal system-type "darwin")
  (setq mac-option-modifier 'super
        mac-command-modifier 'meta)
  )
 )

;;;;;;;;;;;;;;;;;;;;;
;; Some self-defined variable to simplify future modifications:
;; Here I choose to use relative path because there are symbol links,
;; and the absolute path are different in different machines.
(setq roam_notes "~/silverpath/org-roam-db/"
      other_notes "~/silverpath/org-roam-db/other_notes/"
      paper_notes "~/silverpath/org-roam-db/research/paper_notes/"
      zot_bib "~/silverpath/org-roam-db/total_bib.bib"
      pdf_dir "~/silverpath/papers/"
      org-directory other_notes
      )

;;;;;;;;;;;;;;;;;;
;; ORG-REF PART ;;
;; Help us to insert reference by bibtex.
;; I do not use this to manage bibtex, instead, I use Zotero generated bibtex.
;;;;;;;;;;;;;;;;;;

(prelude-require-package 'org-ref)
(require 'org-ref)
;; set the bibtex file for org-ref
(setq reftex-default-bibliography zot_bib)
;; set notes, pdf directory
(setq org-ref-bibligraphy-notes (concat other_notes "bibnotes.org")
      org-ref-notes-directory paper_notes
      org-ref-default-bibliography zot_bib
      org-ref-pdf-directory pdf_dir)
;;
(setq
 ;; use helm-bibtex to find pdf
 org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-helm-bibtex
 org-ref-note-title-format "* TODO %y - %t\n :PROPERTIES:\n  :Custom_ID: %k\n  :NOTER_DOCUMENT: %F\n :ROAM_KEY: cite:%k\n  :AUTHOR: %9a\n  :JOURNAL: %j\n  :YEAR: %y\n  :VOLUME: %v\n  :PAGES: %p\n  :DOI: %D\n  :URL: %U\n :END:\n\n"
 ;; use org-roam's note setting instead of org-ref's
 org-ref-notes-function 'orb-edit-notes
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ORG-ROAM PART
;; The core package that help us maintain our knowledge and link them together
;; All notes are under org-roam's database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(prelude-require-package 'org-roam)
(require 'org-roam)
(require 'org-roam-protocol)
;; following part is init info for roam
(setq org-roam-directory roam_notes
      org-roam-db-location "~/.org-roam.db"  ;; move it out of sync directory.
      org-roam-tag-sources '(prop last-directory)  ;; let roam use dir to generate tags for us
      ;; org-id-link-to-org-use-id t ;; make a ID for each file
      )

(add-hook 'after-init-hook 'org-roam-mode)

(define-key org-roam-mode-map (kbd "C-c m l") #'org-roam)
(define-key org-roam-mode-map (kbd "C-c m i") #'org-roam-insert)
(define-key org-roam-mode-map (kbd "C-c m f") #'org-roam-find-file)
(define-key org-roam-mode-map (kbd "C-c m c") #'org-roam-capture)
(define-key org-roam-mode-map (kbd "C-c m b") #'org-roam-switch-to-buffer)

;; org-roam templates
(setq org-roam-capture-templates
      '(
        ("d" "default template" plain (function org-roam-capture--get-point)
         "%?"
         :file-name "inbox/%<%y%m%d>-${slug}"
         :head "#+title: ${title}\n#+roam_alias:\n#+roam_tags:\n\n"
         :unnarrowed t)
        ("l" "literature: book, blog, web..." plain (function org-roam-capture--get-point)
         "%?"
         :file-name "literature/%<%y%m%d>-${slug}"
         :head "#+title: ${title}\n#+roam_alias:\n#+roam_tags:\n\n- tags :: "
         :unnarrowed t)
        ("c" "concept" plain (function org-roam-capture--get-point)
         "%?"
         :file-name "concept/${slug}"
         :head "#+title: ${title}\n#+roam_alias:\n#+roam_tags:\n\n- tags :: "
         :unnarrowed t)
        ("t" "term" plain (function org-roam-capture--get-point)
         "- category: %^{related category:}\n- meaning: "
         :file-name "research/terms/${slug}"
         :head "#+title: ${title}\n#+roam_alias:\n#+roam_tags:\n\n- tags :: "
         :unnarrowed t)
        ("o" "outlines" plain (function org-roam-capture--get-point)
         "%?"
         :file-name "outlines/${slug}"
         :head "#+title: ${title}\n#+roam_alias:\n#+roam_tags:\n\n- tags :: "
         :unnarrowed t)
        )
      )
(setq org-roam-capture-ref-templates
      '(("r" "ref" plain (function org-roam-capture--get-point)
         "%?"
         :file-name "literature/${slug}"
         :head "#+title: ${title}
#+roam_key: ${ref}
#+roam_tags: website

- source :: ${ref}"
         :unnarrowed t)
        ("a" "Annotation" plain (function org-roam-capture--get-point)
         "%U ${body}\n"
         :file-name "literature/${slug}"
         :head "#+title: ${title}
#+roam_key: ${ref}
#+roam_tags: website

- source :: ${ref}"
         :immediate-finish t
         :unnarrowed t)))

;; org-roam-dailies
(setq org-roam-dailies-directory "dailies")

(setq org-roam-dailies-capture-templates
      '(("d" "daily" entry #'org-roam-capture--get-point
         "* %?\n")))

;;
;; from https://rgoswami.me/posts/org-note-workflow/#reference-management
;; in org-roam buffers, it procides completion for org-roam files using its title
;;
(prelude-require-package 'company-org-roam)
(push 'company-org-roam company-backends)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; deft part
;; help us to search notes much faster
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(prelude-require-package 'deft)
(require 'deft)
(setq deft-default-extension "org"
      deft-directory roam_notes
      ;; recursively research notes under the directory
      deft-recursive t
      ;; decouples file name and note title:
      deft-use-filename-as-title nil
      deft-use-filter-string-for-filename t
      ;; disable auto-save
      deft-auto-save-internal -1.0
      ;; converts the filter string into a readable file-name using kebab-case:
      deft-file-naming-rules
      '((noslash . "-")
        (nospace . "-")
        (case-fn . downcase))
      )
(global-set-key (kbd "C-c m d") 'deft)
(setq deft-auto-save-interval 20)

;; helm-bibtex
(prelude-require-package 'helm-bibtex)
(autoload 'helm-bibtex "helm-bibtex" "" t)
(setq bibtex-completion-bibliography zot_bib
      bibtex-completion-notes-path paper_notes
      bibtex-completion-library-path pdf_dir
      bibtex-completion-pdf-field "file"  ;; filed in bibtex to help find related pdf. optional
      bibtex-completion-notes-template-multiple-files
      (concat
       "#+title: ${title}\n"
       "#+roam_key: cite:${=key=}\n"
       "* todo notes\n"
       ":properties:\n"
       ":custom_id: ${=key=}\n"
       ":noter_document: %(orb-process-file-field \"${=key=}\")\n"
       ":author: ${author-abbrev}\n"
       ":journal: ${journaltitle}\n"
       ":date: ${date}\n"
       ":year: ${year}\n"
       ":doi: ${doi}\n"
       ":url: ${url}\n"
       ":end:\n\n"
       )
      )

;;(require 'helm-config)
;;(global-unset-key (kbd "<f11>"))  ;; f11 used to be toggle frame maximum
;;(define-key helm-command-map (kbd "<f11>") 'helm-bibtex)
(global-set-key (kbd "C-c h") 'helm-bibtex)

;; Set pdf viwer for different platform
(cond
 ((string-equal system-type "darwin")  ;; macOS
  (setq bibtex-completion-pdf-open-function
        (lambda (fpath)
          (call-process "open" nil 0 nil "-a" "/Applications/PDF Expert.app" fpath)))
  )
 ((string-equal system-type "gnu/linux")
  (setq bibtex-completion-pdf-open-function
        (lambda (fpath)
          (call-process "okular" nil 0 nil fpath))))
 )

;;
;; ORG-ROAM-BIBTEX
;; Another core package that binds org-roam, org-ref, helm-bibtex, and other
;; useful packages togeher.
;;
(prelude-require-package 'org-roam-bibtex)
(require 'org-roam-bibtex)
(add-hook 'after-init-hook #'org-roam-bibtex-mode)
(define-key org-roam-bibtex-mode-map (kbd "C-c m a") #'orb-note-actions)

;; This may let us get the true contents of these keywords from bibtex
(setq org-roam-bibtex-preformat-keywords
      '("=key=" "title" "url" "file" "author-or-editor" "keywords"))

(setq orb-templates
      '(
        ("r" "ref + note" plain (function org-roam-capture--get-point)
         ""
         :file-name "research/paper_notes/${slug}"
         :head "#+TITLE: ${=key=}: ${title}
#+ROAM_KEY: ${ref}

- tags ::
- keywords :: ${keywords}

* ${title}
:PROPERTIES:
:Custom_ID: ${=key=}
:URL: ${url}
:AUTHOR: ${author-or-editor}
:END:

** Short Summary

** Related Work

** Points

** Evaluation

** Conclusion

* Reading Notes
:PROPERTIES:
:NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")
:NOTER_PAGE:
:END:"

         :unnarrowed t)
        ("b" "book" plain (function org-roam-capture--get-point)
         ""
         :file-name "literature/${slug}"
         :head "#+TITLE: ${=key=}: ${title}
#+ROAM_KEY: ${ref}

- tags ::
- keywords :: ${keywords}

* ${title}
:PROPERTIES:
:Custom_ID: ${=key=}
:URL: ${url}
:AUTHOR: ${author-or-editor}
:END:

* Reading Notes
:PROPERTIES:
:NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")
:NOTER_PAGE:
:END:"

         :unnarrowed t)
        ))

;;
;; ORG-NOTER
;; This package help us read pdf and its related notes at the same time in Emacs;;
(prelude-require-package 'org-noter)
(require 'org-noter)
(setq
                                        ; The WM can handle splits
 ;; org-noter-notes-window-location 'other-frame
 ;; Please stop opening frames
 org-noter-always-create-frame nil
 ;; I want to see the whole file
 org-noter-hide-other nil
 ;; Everything is relative to the main notes file
 org-noter-notes-search-path (list roam_notes)
 org-noter-separate-notes-from-heading t
 )

;;
;; pdf-tools
;; Reading PDF in emacs
;;
;;(setenv "PKG_CONFIG_PATH" (concat (shell-command-to-string "printf %s \"$(brew --prefix libffi)\"") "/lib/pkgconfig/"))
(prelude-require-package 'pdf-tools)
(require 'pdf-tools)
(pdf-tools-install)
;;(setq pdf-annot-activate-created-annotations t)
(setq pdf-view-use-scaling t)
(define-key pdf-view-mode-map (kbd "h") #'pdf-annot-add-highlight-markup-annotation)
(define-key pdf-view-mode-map (kbd "u") #'pdf-annot-add-underline-markup-annotation)
(define-key pdf-view-mode-map (kbd "t") #'pdf-annot-add-text-annotation)
(define-key pdf-view-mode-map (kbd "d") #'pdf-annot-delete)

;;
;; org-pdftools
;; A package that help us to insert bind notes and pdf position.
                                        ; We need next two packages to
;;
;;(prelude-require-package 'org-pdftools)
;;(require 'org-pdftools)
;;(add-hook 'org-load-hook #'org-pdftools-setup-link)

;;(prelude-require-package 'org-noter-pdftools)
;; (add-to-list 'load-path "~/.emacs.d/elpa/org-noter-pdftools.local/")
;; (require 'org-noter-pdftools)  ;; should be loaded after ~org-noter~
;; (with-eval-after-load 'pdf-annot
;;   (add-hook 'pdf-annot-activate-handler-function #'org-noter-pdftools-jump-to-note))

(prelude-require-package 'org-download)
(require 'org-download)
(add-hook 'dired-mode-hook 'org-download-enable)
;; A help func to put imgs into a subdir that has the same name with the buffer
(defun zgy/org-download-method (link)
  (let* ((filename
          (file-name-nondirectory
           (car (url-path-and-query
                 (url-generic-parse-url link)))))
         ;; Create folder name with current buffer name, and place in root dir
         (dirname (concat "~/silverpath/images/"
                          (replace-regexp-in-string " " "_"
                                                    (downcase (file-name-base buffer-file-name)))))
         (filename-with-timestamp (format "%s%s.%s"
                                          (file-name-sans-extension filename)
                                          (format-time-string org-download-timestamp)
                                          (file-name-extension filename))))
    (make-directory dirname t)
    (expand-file-name filename-with-timestamp dirname)))

(setq org-download-screenshot-method
      (cond
       ;;((string-equal system-type "darwin") "screencapture -i %s")
       ((eq system-type 'darwin) "screencapture -i %s")
       ((eq system-type 'gnu/linux)
        (cond ((executable-find "maim")  "maim -u -s %s")
              ((executable-find "scrot") "scrot -s %s")))))
(setq org-download-method 'zgy/org-download-method)

;; end of ziggy.el
