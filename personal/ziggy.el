(setq default-frame-alist '((font . "Sarasa Mono SC 14")))

;; Pinyin Input
(prelude-require-package 'pyim)
(require 'pyim)
(require 'pyim-basedict)
(pyim-basedict-enable)
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

(cond
 ((string-equal system-type "darwin")
  (setq mac-option-modifier 'super
        mac-command-modifier 'meta)
  )
 )

;;;;;;;;;;;;;;;;;;;;;
;; Some self-defined variable to simplify future modifications:
(setq roam_notes (concat (getenv "HOME") "/silverpath/org-roam-db/")
      other_notes (concat (getenv "HOME") "/silverpath/org-roam-db/other_notes/")
      paper_notes (concat (getenv "HOME") "/silverpath/org-roam-db/paper_notes/")
      zot_bib (concat (getenv "HOME") "/silverpath/org-roam-db/total_bib.bib")
      pdf_dir (concat (getenv "HOME") "/silverpath/papers/")
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
(setq org-roam-directory roam_notes)
(add-hook 'after-init-hook 'org-roam-mode)
;; Hide the mode line in the org-roam buffer since it has no meaning
(add-hook 'org-roam-buffer-prepare-hook #'hide-mode-line-mode)

;; ORG-ROAM Templates
(setq org-roam-capture-templates
      '(
        ("d" "Default template" plain (function org-roam-capture--get-point)
         "%?"
         :file-name "%<%Y%m%d%H%M>-${slug}"
         :head "#+title: ${title}\n#+roam_alias: \n#+roam_tags: \n\n"
         :unnarrowed t))
      )

;;
;; From https://rgoswami.me/posts/org-note-workflow/#reference-management
;; In org-roam buffers, it procides completion for org-roam files using its title
;;
(prelude-require-package 'company-org-roam)
(push 'company-org-roam company-backends)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEFT PART
;; Help us to search notes much faster
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

;; helm-bibtex
(prelude-require-package 'helm-bibtex)
(autoload 'helm-bibtex "helm-bibtex" "" t)
(setq bibtex-completion-bibliography zot_bib
      bibtex-completion-notes-path paper_notes
      bibtex-completion-library-path pdf_dir
      bibtex-completion-pdf-field "file"  ;; filed in bibtex to help find related pdf. optional
      bibtex-completion-notes-template-multiple-files
      (concat
       "#+TITLE: ${title}\n"
       "#+ROAM_KEY: cite:${=key=}\n"
       "* TODO Notes\n"
       ":PROPERTIES:\n"
       ":Custom_ID: ${=key=}\n"
       ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
       ":AUTHOR: ${author-abbrev}\n"
       ":JOURNAL: ${journaltitle}\n"
       ":DATE: ${date}\n"
       ":YEAR: ${year}\n"
       ":DOI: ${doi}\n"
       ":URL: ${url}\n"
       ":END:\n\n"
       )
      )

(require 'helm-config)
(global-unset-key (kbd "<f11>"))  ;; f11 used to be toggle frame maximum
;;(define-key helm-command-map (kbd "<f11>") 'helm-bibtex)
(global-set-key (kbd "<f11>") 'helm-bibtex)

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
(define-key org-roam-bibtex-mode-map (kbd "C-c n a") #'orb-note-actions)

;; This may let us get the true contents of these keywords from bibtex
(setq org-roam-bibtex-preformat-keywords
      '("=key=" "title" "url" "file" "author-or-editor" "keywords"))

(setq orb-templates
      '(("r" "ref" plain (function org-roam-capture--get-point)
         ""
         :file-name "${slug}"
         :head "#+TITLE: ${=key=}: ${title}\n#+ROAM_KEY: ${ref}

- tags ::
- keywords :: ${keywords}

* ${title}
:PROPERTIES:
:Custom_ID: ${=key=}
:URL: ${url}
:AUTHOR: ${author-or-editor}
:NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")
:NOTER_PAGE:
:END:\n"

         :unnarrowed t))

      ;;\n* ${title}\n  :PROPERTIES:\n  :Custom_ID: ${=key=}\n  :URL: ${url}\n  :AUTHOR: ${author-or-editor}\n  :NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n  :NOTER_PAGE: \n  :END:\n\n"

      ;;
      ;; ORG-NOTER
;; This package help us read pdf and its related notes at the same time in Emacs;;
(prelude-require-package 'org-noter)
(setq
    ; The WM can handle splits
    org-noter-notes-window-location 'other-frame
    ;; Please stop opening frames
    org-noter-always-create-frame nil
    ;; I want to see the whole file
    org-noter-hide-other nil
    ;; Everything is relative to the main notes file
    org-noter-notes-search-path (list roam_notes)
 )
