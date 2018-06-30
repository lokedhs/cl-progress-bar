(in-package #:cl-progress-bar)

(defvar *progress-bar* nil)
(defparameter *progress-bar-enabled* nil)

(defun update-progress (unit-count &optional (progress-bar *progress-bar*))
  (unless (null progress-bar)
    (bt:with-lock-held ((cl-progress-bar.progress:mutex progress-bar))
      (cl-progress-bar.progress:update-progress progress-bar unit-count))))

(defun make-progress-bar (total)
  (if (or (not total) (zerop total))
      (make-instance 'cl-progress-bar.progress:uncertain-size-progress-bar)
      (make-instance 'cl-progress-bar.progress:progress-bar
                     :total total)))

(defmacro with-progress-bar ((total-size description &rest desc-args) &body body)
  `(let ((*progress-bar* (when (and (not *progress-bar*)
                                    *progress-bar-enabled*)
                           (make-progress-bar ,total-size))))
     (when *progress-bar*
       (fresh-line)
       (format t ,description ,@desc-args)
       (cl-progress-bar.progress:start-display *progress-bar*))
     (prog1 (progn ,@body)
       (when *progress-bar*
         (cl-progress-bar.progress:finish-display *progress-bar*)))))
