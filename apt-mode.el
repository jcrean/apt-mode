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

(defvar verbatim-header-regexp
  "^\\s-*\\(\\+?-+\\)\\([^-]*?\\)\\(\\+?\\)$"
  "Regular expression that matches the start of a verbatim
  section of text.")

(defvar verbatim-header-bol-regexp
  "^\\(\\+?-+\\)\\([^-]*?\\)\\(\\+?\\)$"
  "Regular expression that matches the start of a verbatim
  section of text at the beginning of a line.")

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
  (set (make-local-variable 'indent-line-function) 'apt-indent-line)
  (set (make-local-variable 'default-tab-width) 2)
  )

(defun capture-previous-line ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (forward-word -1)
    (buffer-substring (point-at-bol) (point-at-eol))))

(defun line-up-to-point ()
  (buffer-substring
   (line-beginning-position)
   (point)))

(defun calculate-apt-indent ()
  (let ((prev-line (capture-previous-line))
        (curr-line (line-up-to-point)))
    (cond ((string-match "^[-+]" curr-line) 0)
          ((string-match "[^*+ ]" prev-line) default-tab-width))))

(defun apt-indent-line ()
  (interactive)
  (let ((indent (calculate-apt-indent)))
    (if (> (current-column) (current-indentation))
        (save-excursion
          (indent-line-to indent))
      (indent-line-to indent))))

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

(defun apt-insert-asterisk ()
  (interactive)
  (insert "* "))

(defun apt-insert-verbatim-box (header &optional text)
  (let ((full-header
         (if (and
              (string-match "^\\+" header)
              (string-match "[^+]$" header))
             (concat header "+")
           header)))
    (insert full-header)
    (newline)
    (insert text)
    (save-excursion
      (newline)
      (insert full-header))))

(defun editing-verbatim-p ()
  (save-excursion
    (condition-case nil
        (search-backward-regexp verbatim-header-bol-regexp)
      (error nil))))

(defun apt-insert-newline ()
  (interactive)
  (let ((current-line (buffer-substring (line-beginning-position) (line-end-position))))
    (newline)
    (cond ((editing-verbatim-p) t)
          ((string-match verbatim-header-regexp current-line)
           (let ((header (concat (match-string 1 current-line)
                                 (match-string 3 current-line)))
                 (text (match-string 2 current-line)))
             (forward-line -1)
             (kill-line 2)
             (apt-insert-verbatim-box header text)))
          ((string-match "^\\S-" current-line)
           (newline-and-indent))
          ((string-match "^\\s-+\\*" current-line)
           (newline-and-indent)
           (apt-insert-asterisk))
          (t (indent-relative)))))



(provide 'apt-mode)