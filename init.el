
;; Configure window, fonts, tab width etc
(setq package-enable-at-startup nil)
(setq inhibit-startup-screen t)
(when window-system (set-frame-size (selected-frame) 120 45))
(setq initial-scratch-message nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(global-display-line-numbers-mode)
(set-frame-font "JetBrains Mono 12" nil t)
(setq-default tab-width 4)
(setq make-backup-files nil)

;; Electric pair mode everywere but in minibuffer
(electric-pair-mode)
(defun inhibit-electric-pair-mode (char)
  (minibufferp))
(setq electric-pair-inhibit-predicate #'inhibit-electric-pair-mode)

;; Configure Straight package manager
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package use-package)
;; Configure use-package to use straight.el by default
(use-package straight
  :custom
  (straight-use-package-by-default t))

;; Icons
(use-package all-the-icons)
(use-package all-the-icons-dired)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

;; Theme
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-palenight t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Project management
(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

;; Which key
(use-package which-key
  :config
  (setq which-key-idle-delay 0.1)
  (which-key-mode))

;; Magit
(use-package magit)

;; LSP
(add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))

(use-package go-mode)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (
	 (go-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))

(use-package lsp-ui :commands lsp-ui-mode)
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; Debugging
(use-package dap-mode
  :init (require 'dap-dlv-go))

;; Snippet engine used by lsp for parameter completion
(use-package yasnippet
  :config
  (yas-global-mode))

;; Snippets used by yasnippet for almost every language
(use-package yasnippet-snippets)

;; Completion
(use-package company
  :config
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1))

(add-hook 'after-init-hook 'global-company-mode)

;; Syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;; Syntax hl
(use-package tree-sitter)
(use-package tree-sitter-langs)
(tree-sitter-require 'go)

;; Markdown
(use-package markdown-mode
  :mode ("README\\.md'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
			  ("C-c C-e" . markdown-do)))

(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

;; Enable vertico
(use-package vertico
  :init (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Further vertico config
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Allow searches in vertico from anywhere in strings
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Add more information to menus controlled by Vertico
(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))
