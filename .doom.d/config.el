;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "João F. Miranda"
      user-mail-address "joao.francisco.doc@gmail.com")


;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
(set-frame-font "Source Code Pro 14" nil t)


;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; (setq doom-font (font-spec :family "Fira Code" :size 15 :weight 'semi-light)
     ;; doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; chande the width of the indentation
(setq-default tab-width 4)
(setq-default evil-shift-width tab-width)
;; set space over tabs for indentation
(setq-default indent-tabs-mode nil)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(after! org
  (setq org-directory "/home/hermitcat/Documents/Notes/")
  (setq org-agenda-files
        '(
          "/home/hermitcat/Documents/Notes/.agenda_files"
        )
  )
  ;; creat TODO categorys
  (setq org-todo-keywords
        '((sequence "TODO(t)" "REMINDER(r)" "EVENT(e)" "|" "DONE(!d)" "CANCELED(c)"))
  )
  (setq org-refile-targets
        '(
          ("archive.org" :maxlevel . 1)
          ("agenda.org" :maxlevel . 1)
        )
  )
  ;; save org buffers after refile
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  (setq org-log-done 'time)
  ;; easy creation of org file anyware
  (setq org-capture-templates
        '(
          ("t" "Tasks" entry (file+olp "~/Documents/Notes/.agenda_files/agenda.org" "Inbox")
                "* TODO %?\n %U\n %a\n %i" :empty-lines 1)
          ("r" "Reminder" entry (file+olp "~/Documents/Notes/.agenda_files/agenda.org" "Inbox")
                "* REMINDER %?\n %U\n %a\n %i" :empty-lines 1)
          ("e" "Event" entry (file+olp "~/Documents/Notes/.agenda_files/agenda.org" "Inbox")
                "* EVENT %?\n %U\n %a\n %i" :empty-lines 1)
        )
  )
  ;; change the colapsed trees simbol to sothing better
  (setq org-ellipsis " ↵" org-hide-emphasis-markers t)
  ;; create templates for criation of source code areas
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
)

;; month view for the buffer integrated with org-agenda
(require 'calfw)
(require 'calfw-org)

;; global notification for the org agenda
;; simple mode:
;;      org-agenda-to-appt add all agenda entries to notification tray.
;;      call org-agenda-to-appt to not have problem wen clean it the first time.
;;      create a function to clear the notifications tray before new entries come every
;;              time org-agenda-to-appt is caled.
;;      recall org-agenda-to-appt every 60 seconds to update entries
;; (org-agenda-to-appt)
;; (defadvice org-agenda-to-appt (before wickedcool activate)
;;   "Clear the appt-time-msg-list."
;;   (setq appt-time-msg-list nil))
;; (run-with-timer 2 60 (lambda() (org-agenda-to-appt t)))
;; the method i'm going to use is this other
(require 'appt)
(appt-activate t)

(setq appt-message-warning-time 5) ; Show notification 5 minutes before event
(setq appt-display-interval appt-message-warning-time) ; Disable multiple reminders
(setq appt-display-mode-line nil)

; Use appointment data from org-mode
(defun my-org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

;; Update alarms when...
; (1) ... Starting Emacs
(my-org-agenda-to-appt)
; (2) ... Everyday at 12:05am (useful in case you keep Emacs always on)
(run-at-time "12:05am" (* 24 3600) 'my-org-agenda-to-appt)
; (3) ... When agenda file is saved
(add-hook 'after-save-hook
          '(lambda ()
             (if (string= (buffer-file-name) (concat (getenv "HOME") "/Documents/Notes/.agenda_files/agenda.org"))
                 (my-org-agenda-to-appt))))

(defun djcb-popup (title msg &optional icon sound)
  "Show a popup if we're on X, or echo it otherwise; TITLE is the title
of the message, MSG is the context. Optionally, you can provide an ICON and
a sound to be played"
  (interactive)
  ;;verbal warning
  (shell-command
   (concat "espeak -vmb-fr4-en -k5 -s125 " "'" title  "'") ;; use local espeak
   ;; (concat "echo " "'" title "'" " " "'" msg "'" " |text-to-speech en-gb")  ;; use remote Google voices
   ;; text-to-speech is from https://github.com/taylorchu/speech-to-text-text-to-speech
  )
  (when sound (shell-command
                (concat "mplayer -really-quiet " sound " 2> /dev/null")))
  (if (eq window-system 'x)
    (shell-command (concat "notify-send --expire-time=30000 "
                     (if icon (concat "-i " icon) "")
                     " '" title "' '" msg "'"))
    ;; text only version
    (message (concat title ": " msg))))
;; (shell-command (concat "espeak" " 'rola'"))

(defun djcb-appt-display (min-to-app new-time msg)
    (djcb-popup (format "Appointment in %s minutes" min-to-app) msg
  ;;    "/usr/share/icons/gnome/32x32/status/appointment-soon.png"   ;; optional icon
  ;;    "/usr/share/sounds/ubuntu/stereo/phone-incoming-call.ogg"    ;; optional sound
))
(setq appt-disp-window-function (function djcb-appt-display))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys

;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; LSP configurations
;; function to activate breadcrumb in all buffers (navigation bar)
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))
;; more lsp configuration
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))


;; Tree-sitter configuration
(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))


;; Install and configuration lsp source pyright for python
(use-package! lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred


;; set nested snippets
(setq yas-triggers-in-field t)
(setq company-show-quick-access t)
(setq yas-inhibit-overlay-modification-protection t)


;; Exit insert mode easily with key-chord plugin
;; key-chord measure the timeframe between keystrokes
(require 'key-chord)
(key-chord-mode t)
(key-chord-define-global "ii" 'evil-normal-state)


;; configure ranger (file manager) to open only one parent tree
(setq ranger-parent-depth 0)


;; seting keys for calendar and ranger
(map! :leader
      :desc "open ranger" "e" #'ranger
      :desc "open calendar" "d" #'cfw:open-org-calendar)


;; ask witch buffer i want to open when i do a window split
(setq evil-vsplit-window-right t
      evil-split-window-below t)
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))


;; some usefull configuration
(setq-default delete-by-moving-to-trash t)        ; Delete files to trash
(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      auto-save-default t)                        ; Nobody likes to loose work, I certainly don't
