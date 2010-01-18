;;
;; TODO: Need to add docs
;;

(defvar apt-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Define special keybindings here
    map)
  "Keymap for 'apt-mode'.")

(defvar apt-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?~ ". 12")
    (modify-syntax-entry ?\n ">")
    st)
  "Syntax table for 'apt-mode'.")

(define-derived-mode apt-mode fundamental-mode "APT"
  "A major mode for editing AlmostPlainText (.apt) files."
  :syntax-table apt-mode-syntax-table
  (set (make-local-variable 'comment-start) "~~ ")
  (set (make-local-variable 'comment-start-skip) "~~+\\s+"))


(provide 'apt)