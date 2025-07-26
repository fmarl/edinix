(require 'package)
(package-initialize)

(setq custom-safe-themes t)

(use-package smart-mode-line)

(use-package smart-mode-line-powerline-theme
  :after smart-mode-line
  :config
  (sml/setup)
  (sml/apply-theme 'powerline))

(use-package smex
  :init (smex-initialize)
  :bind
  (:map global-map
	("M-x" . 'smex)
	("M-X" . 'smex-major-mode-commands)))

(use-package ace-window
  :bind
  (:map global-map
	("M-p" . 'ace-window)))
  
(use-package ace-jump-mode
  :bind
  (:map global-map
	("C-c SPC" . 'ace-jump-mode)))

(use-package monokai-pro-theme
  :config
  (load-theme 'monokai-pro t))

(use-package beacon
  :config
  (beacon-mode))

(use-package markdown-mode)

(set-frame-font "Source Code Pro:size=14")
(add-hook 'find-file-hook (lambda () (display-line-numbers-mode 1)))
(column-number-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode 1)
(electric-pair-mode 1)
(set-cursor-color "#ffffff")
(global-prettify-symbols-mode +1)
(ido-mode t)
(winner-mode 1)