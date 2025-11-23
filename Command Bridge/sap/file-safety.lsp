;;;=====================================================
;;; file-safety.lsp
;;; Safe file operations with retry logic
;;; Location: sap/
;;;
;;; This is SAP (protective guardrails) for file operations
;;; Used by: rami/autocad/command_bridge.lsp
;;;=====================================================

;;;-----------------------------------------------------
;;; CONFIGURATION
;;;-----------------------------------------------------

;;; Note: Retry logic removed to prevent AutoCAD freezing
;;; Simple file operations are sufficient for this use case

;;;-----------------------------------------------------
;;; SAFE FILE OPEN (APPEND MODE)
;;;-----------------------------------------------------

(defun sap-safe-file-open-append (filepath / file)
  "Safely open file in append mode"
  (setq file (open filepath "a"))
  (if file
    file
    (progn
      (princ (strcat "\n⚠️ Cannot open file: " filepath))
      nil
    )
  )
)

;;;-----------------------------------------------------
;;; SAFE FILE OPEN (WRITE MODE)
;;;-----------------------------------------------------

(defun sap-safe-file-open-write (filepath / file)
  "Safely open file in write mode"
  (setq file (open filepath "w"))
  (if file
    file
    (progn
      (princ (strcat "\n⚠️ Cannot open file: " filepath))
      nil
    )
  )
)

;;;-----------------------------------------------------
;;; SAFE FILE CLOSE
;;;-----------------------------------------------------

(defun sap-safe-file-close (file / )
  "Safely close file handle"
  (if file
    (progn
      (close file)
      T
    )
    nil
  )
)

;;;-----------------------------------------------------
;;; PATH VALIDATION
;;;-----------------------------------------------------

(defun sap-validate-path (filepath / dir-path)
  "Validate file path and ensure directory exists"
  (setq dir-path (vl-filename-directory filepath))
  
  ; Check if directory exists
  (if (not (vl-file-directory-p dir-path))
    (progn
      (princ (strcat "\n⚠️ Directory does not exist: " dir-path))
      nil
    )
    T
  )
)

(princ "\nSAP: file-safety.lsp loaded.")
(princ)

