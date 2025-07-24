(use-package clang-format)
(use-package clang-format+)
(use-package cmake-mode)
(use-package google-c-style
  :hook ((c-mode c++-mode) . google-set-c-style))

;; Default style
(setq c-default-style "cc-mode")
(add-hook 'c-mode-common-hook 'google-set-c-style)

;; Formating
(global-set-key [C-M-tab] 'clang-format-region)
(setq clang-format-style-option "~/.clang_format")
(add-hook 'c-mode-common-hook #'clang-format+-mode)
