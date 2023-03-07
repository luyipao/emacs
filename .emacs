;; ---------------------------------------------------------------------------
;; Package settings
;; Set the URL to search for packages. References:http://elpa.emacs-china.org/.
;; You could try to install some by "M-x package-list-packages"
;; and delete them by "M-x package-delete".
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)
;;			 '("melpa-stable" . "https://stable.melpa.org/#/") t)
;; If you want to add a package to emacs installed by yourself, you need to append
;; the package's (*.el's) directory to the "load-path" and add a commond like
;; "require 'PackageName" or others provided by the package.

;; update init file 
;; sudo emacs
;; M-x load-file, don't reboot emacs to reload .emacs


;;doxymacs
(add-to-list 'load-path "~/.emacs.d/elpa/doxymacs-1.8.0/lisp")
(require 'doxymacs)

;;markdown-mode

;;company
(add-to-list 'load-path "~/.emacs.d/elpa/company-0.9.12")
(require 'company)
;;(add-hook 'after-init-hook #'global-company-mode)
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)
(add-hook 'prog-mode-hook 'company-mode)
(add-hook 'cmake-mode-hook 'company-mode)

;;flychecks
(add-hook 'after-init-hook 'global-flycheck-mode)
(setq flycheck-clang-args "-std=c++11")
(add-hook 'flycheck-mode-hook
          (lambda ()
            (when (display-graphic-p)
              (setq-local flycheck-indication-mode nil))))
;;(setq flycheck-global-modes '(not LaTeX-mode latex-mode))
;;(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))

;;helm


;; C-c h m man or woman

;;flyspell
;;(add-to-list 'load-path "~/.emacs.d/elpa/flyspell/flyspell-1.7q.el")
;;(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." t)
;;(autoload 'flyspell-delay-command "flyspell" "Delay on command." t) (autoload 'tex-mode-flyspell-verify "flyspell" "" t)
;;(add-hook 'LaTeX-mode-hook 'flyspell-mode)

;;display time
(display-time-mode 1) ;; 常显
(setq display-time-24hr-format t) ;;格式
(setq display-time-day-and-date t) ;;显示时间、星期、日期

;;dumb-jump function
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)


;;solarized
;;(add-to-list 'load-path "~/.emacs.d/elpa/solarized-emacs-2.0.0")
;;(load-theme 'solarized-dark t)

;; Make .h & .tpp files be C++ mode
(setq auto-mode-alist(cons '("\\.h\\'" . c++-mode)  auto-mode-alist))
(add-to-list 'auto-mode-alist '("\\.tpp\\'" . c++-mode))

;; cursor-mode
(setq-default cursor-type '(bar . 4))
(set-cursor-color "red")

;; paste while overwrite selected content
(delete-selection-mode 1)

;; line-mode
(global-display-line-numbers-mode)

;;set windows numbering
(require 'window-numbering)
(window-numbering-mode 1)

;;comments
(defun qiang-comment-dwim-line (&optional arg)
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'qiang-comment-dwim-line)

;; set open multi shell
(defun wcy-shell-mode-auto-rename-buffer (text)
  (if (eq major-mode 'shell-mode)
      (rename-buffer  (concat "shell:" default-directory) t)))
(add-hook 'comint-output-filter-functions'wcy-shell-mode-auto-rename-buffer)

;; auctex->latex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;; auto-save buffer on switch buffers
(defadvice switch-to-buffer (before save-buffer-now activate)
  (when buffer-file-name (save-buffer)))
(defadvice other-window (before other-window-now activate)
  (when buffer-file-name (save-buffer)))
(defadvice other-frame (before other-frame-now activate)
  (when buffer-file-name (save-buffer)))

(add-hook 'handle-switch-frame (lambda () (interactive) (save-some-buffers t)))

;;expand-region 选择单词
(require 'expand-region)
(global-set-key (kbd "M-m") 'er/expand-region)

;;ctrl-a移动到句首而不是行首
(defun prelude-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.
Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.
If ARG is not nil or 1, move forward ARG - 1 lines first. If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))
  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))
(global-set-key (kbd "C-a") 'prelude-move-beginning-of-line)

;;WSL2 copy to windows
(defun wsl-copy-region-to-clipboard (start end)
  "Copy region to Windows clipboard."
  (interactive "r")
  (call-process-region start end "clip.exe" nil 0))

(defun wsl-cut-region-to-clipboard (start end)
  (interactive "r")
  (call-process-region start end "clip.exe" nil 0)
  (kill-region start end))

(defun wsl-clipboard-to-string ()
  "Return Windows clipboard as string."
  (let ((coding-system-for-read 'dos))
(substring; remove added trailing \n
 (shell-command-to-string
  "powershell.exe -Command Get-Clipboard") 0 -1)))

(defun wsl-paste-from-clipboard (arg)
  "Insert Windows clipboard at point. With prefix ARG, also add to kill-ring"
  (interactive "P")
  (let ((clip (wsl-clipboard-to-string)))
(insert clip)
(if arg (kill-new clip))))

(define-key global-map (kbd "C-x C-y") 'wsl-paste-from-clipboard)
(define-key global-map (kbd "C-x M-w") 'wsl-copy-region-to-clipboard)
(define-key global-map (kbd "C-x C-w") 'wsl-cut-region-to-clipboard)


;;-------------------------------------------------------------------------------
;;代码参考线
;;(add-to-list 'load-path "~/.emacs.d/elpa/fill-column-indicator")
;;(require 'fill-column-indicator)
;;(setq fci-rule-color "#333") ;; 参考线颜色，我的配色是暗色的, 所以 #333 看着舒服一点
;;(setq fci-rule-column 80)    ;; 宽度设置为 80 
;;(define-globalized-minor-mode
;;  global-fci-mode fci-mode (lambda () (fci-mode 1)))
;;(global-fci-mode 1)

;; avoid outdated byte-compiled elisp files
(setq load-prefer-newer t)

;;----------------------------------code style-------------------------------
;; c mode
;; A function to run before entering the c mode.
;;
;; YASnippet (Yet Another Snippet) is a template system for Emacs,
;; "yas-minor-mode" will start up it.
;; You could get more information in http://wikemacs.org/wiki/Yasnippet.
(defun dorainm-c-mode()
  (c-set-style "cc-mode")
;;  (c-toggle-auto-state t)
  (c-toggle-hungry-state t)
  (electric-pair-local-mode t)
  (doxymacs-mode t)
  ;;(yas-minor-mode t)
  (setq c-basic-offset 4)
  )

;; c++ mode
;; A function to run before entering the c++ mode.
(defun dorainm-c++-mode()
  (c-set-style "stroustrup")
;;  (c-toggle-auto-state t)
  (c-toggle-hungry-state t)
  (electric-pair-local-mode t)
  (doxymacs-mode t)
  ;;(yas-minor-mode t)
  (setq c-basic-offset 4)
)
(add-hook 'c-mode-hook 'dorainm-c-mode)
(add-hook 'c++-mode-hook 'dorainm-c++-mode)


;; ---------------------------------------------------------------------------
;; Language settings

;; Set the Unicode Transformation Format.
(set-language-environment 'Chinese-GB)
;; (set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system 'utf-8)
(setq-default pathname-coding-system 'utf-8)

;; ---------------------------------------------------------------------------
;; Indentation and completion settings.

;; Define a function to indent or complete. (from Teacher WangHeYu)
(defun my-indent-or-complete ()
  (interactive)
  (if (looking-at "\\>")
      (hippie-expand nil)
    (indent-for-tab-command)))

;; Set the priority of completion.
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-line
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol
        try-expand-whole-kill
        ))
;; ---------------------------------------------------------------------------
;; Key binding settings.

;; Set key bindings globally. You could also define
;; key bindings locally by "local-set-key" or "define-key" functions.
;;(global-set-key (kbd "C-<tab>") 'undo-only)
;;(global-set-key "\t" 'my-indent-or-complete)
;;(global-set-key [f12] 'other-window)



;; ---------------------------------------------------------------------------
;; Custom settings.
;;
;; These settings are added using an interactive interface,
;; you could enter it by "M-x customize".

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-electric-math (quote ("$" . "$")))
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-enabled-themes nil)
 '(fci-rule-color "#383838")
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (dumb-jump helm expand-region window-numbering markdown-mode flycheck solarized-theme doom company yasnippet auctex gnu-elpa-keyring-update)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(safe-local-variable-values (quote ((flycheck-clang++-language-standard . "c++11"))))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(line-number ((t (:background "color-235" :foreground "#6F6F6F")))))

;;--------------------------------------------------------------------------------------
;;#color-theme settings
;;color-theme_zenburn
(add-to-list 'custom-theme-load-path "~/.emacs.d/elpa/zenburn-emacs-2.7.0/")
(load-theme 'zenburn t)
(setq zenburn-override-colors-alist
      '(("zenburn-red+5" . "#ff8080")))
(with-eval-after-load "zenburn-theme"
  (zenburn-with-color-variables
    (custom-theme-set-faces
     'zenburn
     ;; original `(default ((t (:foreground ,zenburn-fg :background ,zenburn-bg))))
     `(default ((t (:foreground ,zenburn-fg :background ,zenburn-bg-1)))))))
     (set-face-attribute 'region nil :background "#666")

