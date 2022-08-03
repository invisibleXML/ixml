;;; ixml-mode.el:  a very very simple mode for editing ixml grammars.
;;;
;;; Revisions:
;;; 2019-01-09 : CMSMcQ : currently not very good, but it's something.
;;;                       Colors are ugly; adjust font-lock?
;;;                       Tried generic-ixml-mode.el, too, not much better.
;;; 2019-01-09 : CMSMcQ : start sketching this mode under the guidance
;;;                       of https://www.emacswiki.org/emacs/ModeTutorial
;;;                       and https://www.emacswiki.org/emacs/SampleMode
;;;                       and https://www.emacswiki.org/emacs/GenericMode

;;; This is my first attempt at a language mode, so I don't know what
;;; I'm going. Cut me some slack, OK?

;;; Mode hook (standard idiom)
(defvar ixml-mode-hook nil)

;;; Make return and ^J do newline-and-indent (or, in Aquamacs, maybe
;;; better electric-newline-and-maybe-indent?)
(defvar ixml-mode-map
  (let ((map (make-keymap)))
    ; (define-key-map "\C-j" 'newline-and-indent)
    ; (define-key-map "RET" 'newline-and-indent)
    map)
  "Keymap for ixml major mode.")

;;; Add this mode to auto-mode-alist
(add-to-list 'auto-mode-alist '("\\.ixml\\'" . ixml-mode))

;;; If ixml had keywords, we would probably want to specify a
;;; variable like ixml-font-lock-keywords-l, but ixml has no
;;; keywords, only magic punctuation.
;;;
;;; Ah, but our guide tells us you can use this to highlight
;;; identifiers as well.  OK, here goes.
;;; Q for later:  can we distinguish defined from undefined
;;; identifiers?
;;;
;;; A mode for REx would benefit from highlighting the TOKENS
;;; keyword, and the ws explicit comment.
;;;
;;; Font-lock face names include: font-lock-${KW}-face, for
;;; $KW in comment-delimiter, string, doc, keyword, builtin,
;;; function-name, variable-name, type, constant, warning,
;;; negation-char, preprocessor


(defconst ixml-font-lock-keywords
  (list
   '("\\[.*\\]" . font-lock-constant-face)
   '("#[0-9a-fA-F]+" . font-lock-constant-face)
   ;;; marks:  negation-char-face
   '("[@^-]" . font-lock-keyword-face)
   ;;; actual negation:  negation-char-face
   '("~" . font-lock-negation-char-face)
   ;;; = and : 
   '("[:=]" . font-lock-keyword-face)
   ;;; , ; |
   '("[,;|]" . font-lock-keyword-face)
   '("\\(\\w*[:=]\\)" . font-lock-function-name-face)
   '("\\(\\w*\\)" . font-lock-variable-name-face)
   )
  "Minimal highlighting expression for ixml mode:  identifiers")

;;; (regexp-opt '("^" "@" "-"))
;;; (regexp-opt '("=" ":" ))

;;; Modifying syntax entries.
;;; We want quotation marks to signal literals.
;;; We want braces to signal comments.
;;; We want colon, equals sign, semicolon, bar, comma, and full stop
;;; to be color coded.

(defvar ixml-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; syntax categories '<' and '>' mean comment-start and -end.
    (modify-syntax-entry ?{ "<}" st)
    (modify-syntax-entry ?} ">{" st)
    ;; _ and " are usually already set, but we set them just in case.
    ;; ' is apparently not already set
    (modify-syntax-entry ?_ "_ " st)
    (modify-syntax-entry ?\042 "\"\"" st) ; 042 = double quote
    (modify-syntax-entry ?' "\"\'" st) ; 
    st)
  "Syntax table for ixml mode")

(string= "\"\"" "\042\042")
;;; Entry point
(defun ixml-mode ()
  "Major mode for editing ixml grammars"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ixml-mode-syntax-table)
  (use-local-map ixml-mode-map)
  
  ;; do syntax coloring
  (set (make-local-variable 'font-lock-defaults) '(ixml-font-lock-keywords))

  ;; housekeeping
  (setq major-mode 'ixml-mode)
  (setq mode-name "iXML")
  (run-hooks 'ixml-mode-hook))

(provide 'ixml-mode)
