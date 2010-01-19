;;
;; TODO: Need to add docs
;;

(defvar apt-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\M-H" 'insert-apt-header)
    (define-key map (kbd "*") 'apt-insert-asterisk)
    (define-key map (kbd "RET") 'apt-insert-newline)
    map)
  "Keymap for 'apt-mode'.")

(defvar apt-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?~ ". 12")
    (modify-syntax-entry ?\n ">")
    st)
  "Syntax table for 'apt-mode'.")

;;
;; Currently no font lock keywords, but can hook into this
;; later to do some syntax highlighting. 
;;
;; Setting font-lock-defaults below enables comment highlighting
;; (based on syntax-table defintion)
;;
(defvar apt-font-lock-keywords '())

(define-derived-mode apt-mode fundamental-mode "APT"
  "A major mode for editing AlmostPlainText (.apt) files."
  :syntax-table apt-mode-syntax-table
  (set (make-local-variable 'comment-start) "~~")
  (set (make-local-variable 'comment-start-skip) "~~+\\s*")
  (set (make-local-variable 'font-lock-defaults) '(apt-font-lock-keywords))
  )

(defun insert-apt-header ()
  (interactive)
  (beginning-of-buffer)
  (let ((start (point)))
    (insert "-----------------------\n\n")
    (insert "-----------------------\n")
    (insert "-----------------------\n")
    (insert (format-time-string "%Y-%m-%d\n" (current-time)))
    (insert "-----------------------\n\n")
    (center-region start (point)))
  (forward-line -6)
  (indent-for-tab-command))

(defun line-up-to-point ()
  (buffer-substring
   (line-beginning-position)
   (point)))

(defun apt-insert-asterisk ()
  (interactive)
  (insert "* "))

(defun apt-insert-newline ()
  (interactive)
  (let ((current-line (line-up-to-point)))
    (newline)
    (cond ((string-match "^\\S-" current-line)
           (newline-and-indent))
          ((string-match "^\\s-+\\*" current-line)
           (newline-and-indent)
           (apt-insert-asterisk))
          (t (indent-relative)))))


(provide 'apt-mode)