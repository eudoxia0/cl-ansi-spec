;;;; Process TeX comments, \input tags, etc.

(in-package :cl-ansi-spec)

(defparameter +input-tag-regexp+
  "\\input ([^ \\n]+)\\n")

(defun valid-input-p (file-name)
  (and (not (search "fig" file-name))
       (not (search ".tc" file-name))
       (not (equal file-name "index.idx"))))

(defun include-file (name)
  (let ((input-pathname
          (make-pathname :name name
                         :type "tex"
                         :defaults +tex-directory+)))
    ;; Ignore figures
    (if (valid-input-p name)
        (progn
          (log:info "Including path ~S" input-pathname)
          (uiop:read-file-string input-pathname))
        "")))

(defun include-inputs (string)
  "Replace all instances of '\input file-name' with the contents of 'file-name.tex'."
  (cl-ppcre:regex-replace-all +input-tag-regexp+
                              string
                              #'(lambda (match &rest regs)
                                  (declare (ignore match))
                                  (include-file (first regs)))
                              :simple-calls t))

(defun remove-comments (string)
  "Remove TeX comments from a string."
  (let ((lines (split-sequence:split-sequence #\Newline string)))
    (reduce #'(lambda (l r)
                (concatenate 'string l (string #\Newline) r))
            (remove-if #'(lambda (line)
                           (and (> (length line) 0)
                                (char= (elt line 0) #\%)))
                       lines))))