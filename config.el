;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; Persist last selected theme
(defvar mqdd-theme-file
  (expand-file-name ".last-theme" doom-user-dir))

(defun mqdd-read-last-theme ()
  (when (file-readable-p mqdd-theme-file)
    (with-temp-buffer
      (insert-file-contents mqdd-theme-file)
      (read (current-buffer)))))

(defun mqdd-save-current-theme (&rest _)
  (when-let ((theme (car custom-enabled-themes)))
    (with-temp-file mqdd-theme-file
      (prin1 theme (current-buffer)))))

(setq doom-theme
      (or (mqdd-read-last-theme)
          'doom-one))

(with-eval-after-load 'consult
  (advice-add 'consult-theme :after #'mqdd-save-current-theme))

;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq gptel-backend
      (gptel-make-openai "9router"
        :host "ai.mqdd.my.id"
        :endpoint "/v1/chat/completions"
        :stream t
        :key (getenv "NINEROUTER_API_KEY")
        :models '(Com)))

;; set timeout on ssh
(setq tramp-connection-timeout 30)

;; =========================================
;; EPUB reader
;; =========================================
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;; nov.el renders text to a fixed window width; zooming doesn't reflow it,
;; so text gets cut off until a manual `g' (nov-render-document). Auto-reflow instead.
(defun mqdd/nov-reflow-after-zoom (&rest _)
  (when (derived-mode-p 'nov-mode)
    (nov-render-document)))
(advice-add 'text-scale-adjust :after #'mqdd/nov-reflow-after-zoom)

;; =========================================
;; Buffer zen/fullscreen toggle (like Zed's Shift+Escape)
;; =========================================
(map! "S-<escape>" #'+zen/toggle)

;; =========================================
;; Copilot (AI autocomplete)
;; =========================================
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
         ("<tab>" . copilot-accept-completion)
         ("C-TAB" . copilot-accept-completion-by-word)
         ("C-n"   . copilot-next-completion)
         ("C-p"   . copilot-previous-completion)))


;; =========================================
;; toggle webmode for blade.php files
;; =========================================
(use-package! web-mode
  :mode ("\\.blade\\.php\\'" . web-mode))
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;

;; they are implemented.

;; Bindings

;; Open Dashboard
(map! :leader
      :desc "Open Doom Dashboard"
      "d s" #'+dashboard/open)


(defun mqdd/open-ideas ()
  (interactive)
  (find-file "~/.config/doom/ideas.org"))

(defun mqdd/open-books ()
  (interactive)
  (dired "~/Library/Mobile Documents/com~apple~CloudDocs/Books"))

;; Dashboard
(add-to-list '+dashboard-menu-sections
             '("Ideas"
               :icon (nerd-icons-octicon "nf-oct-light_bulb"
                                         :face '+dashboard-menu-title)
               :key "i"
               :action mqdd/open-ideas))

(add-to-list '+dashboard-menu-sections
             '("Books"
               :icon (nerd-icons-octicon "nf-oct-book"
                                         :face '+dashboard-menu-title)
               :key "b"
               :action mqdd/open-books))

;; SPC i i / SPC i b
(map! :leader
      (:prefix ("i" . "ideas")
       :desc "Open ideas.org" "i" #'mqdd/open-ideas
       :desc "Open Books folder" "b" #'mqdd/open-books))



;; =========================================
;; Email / mu4e
;; =========================================

(setq user-full-name "Ahmad Miqdad"
      user-mail-address "ahmadmiqdad27@gmail.com")

(after! mu4e

  ;; Lokasi Maildir
  (setq mu4e-maildir "~/Mail/gmail")

  ;; Sync Gmail menggunakan mbsync
  (setq mu4e-get-mail-command "mbsync gmail")

  ;; Auto sync setiap 5 menit
  (setq mu4e-update-interval 300)

  ;; Dibutuhkan supaya mbsync tetap sinkron ketika file dipindahkan
  (setq mu4e-change-filenames-when-moving t)

  ;; Optimasi Gmail
  (setq mu4e-index-cleanup nil
        mu4e-index-lazy-check t)

  ;; Gmail sudah menyimpan email terkirim sendiri
  (setq mu4e-sent-messages-behavior 'delete)

  ;; Folder Gmail
  (set-email-account! "gmail"
    '((mu4e-sent-folder   . "/[Gmail]/Sent Mail")
      (mu4e-drafts-folder . "/[Gmail]/Drafts")
      (mu4e-trash-folder  . "/[Gmail]/Trash")
      (mu4e-refile-folder . "/[Gmail]/All Mail")
      (user-mail-address  . "ahmadmiqdad27@gmail.com"))
    t)

  ;; Kirim email lewat msmtp
  (setq sendmail-program (executable-find "msmtp")
        message-send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")))
