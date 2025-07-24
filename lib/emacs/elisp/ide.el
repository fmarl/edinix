(use-package projectile
  :init (projectile-mode +1)
  :bind
  (:map global-map
	("C-c p" . 'projectile-command-map)))

(use-package yasnippet
  :config (yas-global-mode 1))

(use-package ivy
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t))

(defun rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))
(global-set-key (kbd "C-c R") 'rename-this-buffer-and-file)

(setq recentf-exclude '("^/var/folders\\.*"
                        "COMMIT_EDITMSG\\'"
                        ".*-autoloads\\.el\\'"
                        "[/\\]\\.emacs.d/"))

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "F8") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         30
          treemacs-workspace-switch-cleanup      nil)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after treemacs projectile)

(use-package lsp-mode
  :after (direnv)
  :commands lsp
  :hook (((c-mode c++-mode rustic-mode haskell-mode haskell-interactive-mode) . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration))
  :bind ("C-c C-c" . #'lsp-execute-code-action)
  :custom
  (lsp-diagnostics-modeline-scope :project)
  (lsp-file-watch-threshold 5000)
  (lsp-response-timeout 2)
  (lsp-ui-doc-mode nil)
  (lsp-enable-file-watchers nil)
  )

(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :bind (:map lsp-ui-mode-map
	      ("M-." . lsp-ui-peek-find-definitions)
	      ("M-," . lsp-ui-peek-find-references)))

(use-package lsp-ivy
  :after (ivy lsp-mode))

(use-package company-lsp
  :disabled
  :custom (company-lsp-enable-snippet t)
  :after (company lsp-mode))

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1
      lsp-ui-doc-enable t
      lsp-headerline-breadcrumb-enable t)
