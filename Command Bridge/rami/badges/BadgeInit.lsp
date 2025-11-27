;;;=====================================================
;;; BadgeInit.lsp
;;; Initialize AutoCAD Badge System configuration and globals
;;;
;;; Load Order: FIRST
;;; Required by: All badge system files
;;;=====================================================

(vl-load-com) ; Load Visual LISP extensions

;;;-----------------------------------------------------
;;; GLOBAL CONFIGURATION
;;;-----------------------------------------------------

(setq *BADGE-CSV-PATH* "G:\\My Drive\\_Feature\\_Millwork_Projects\\badge-reflex\\Badge_Library_MASTER.csv")
(setq *BADGE-SYSTEM-VERSION* "2.0")
(setq *BADGE-DEBUG-MODE* nil)
(setq *BADGE-JOB-NAME* nil)
(setq *BADGE-LIBRARY-DATA* nil)
(setq *BADGE-SCALE-DEFAULT* 1.0)
(setq *BADGE-LAYER-NAME* "BADGES")
(setq *BADGE-TEXT-HEIGHT* 0.125)

;;;-----------------------------------------------------
;;; BADGE TYPE DEFINITIONS
;;;-----------------------------------------------------

(setq *BADGE-TYPES*
  '(
    ("FINISH"    . ((PREFIX . ("PL" "PT")) (SHAPE . "ELLIPSE")))
    ("FIXTURE"   . ((PREFIX . ("SS" "ST")) (SHAPE . "RECTANGLE")))
    ("EQUIPMENT" . ((PREFIX . ("APPL" "EQ")) (SHAPE . "DIAMOND")))
  )
)

;;;-----------------------------------------------------
;;; SYSTEM INITIALIZATION
;;;-----------------------------------------------------

(defun badge-system-init (/ old-cmdecho)
  "Initialize badge system environment"
  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  
  ; Create badge layer if it doesn't exist
  (if (not (tblsearch "LAYER" *BADGE-LAYER-NAME*))
    (command "._LAYER" "_N" *BADGE-LAYER-NAME* "_C" "7" *BADGE-LAYER-NAME* "")
  )
  
  ; Set ATTDIA and ATTREQ for badge insertion
  (setvar "ATTDIA" 0)
  (setvar "ATTREQ" 1)
  
  (setvar "CMDECHO" old-cmdecho)
  
  (princ "\n✓ Badge System initialized")
  (princ (strcat "\n  Version: " *BADGE-SYSTEM-VERSION*))
  (princ (strcat "\n  CSV Path: " *BADGE-CSV-PATH*))
  (princ)
)

;;;-----------------------------------------------------
;;; PATH MANAGEMENT
;;;-----------------------------------------------------

(defun get-badge-csv-path ()
  "Return the badge library CSV path"
  *BADGE-CSV-PATH*
)

(defun set-badge-csv-path (new-path)
  "Set a new badge library CSV path"
  (if (findfile new-path)
    (progn
      (setq *BADGE-CSV-PATH* new-path)
      (princ (strcat "\n✓ CSV path updated: " new-path))
      T
    )
    (progn
      (princ (strcat "\n⚠ File not found: " new-path))
      nil
    )
  )
)

;;;-----------------------------------------------------
;;; JOB CONTEXT MANAGEMENT
;;;-----------------------------------------------------

(defun set-badge-job (job-name)
  "Set the current job context for badges"
  (setq *BADGE-JOB-NAME* (strcase job-name))
  (princ (strcat "\n✓ Badge job set to: " *BADGE-JOB-NAME*))
  *BADGE-JOB-NAME*
)

(defun get-badge-job ()
  "Get the current job context"
  *BADGE-JOB-NAME*
)

(defun clear-badge-job ()
  "Clear the job context"
  (setq *BADGE-JOB-NAME* nil)
  (princ "\n✓ Badge job context cleared")
)

;;;-----------------------------------------------------
;;; BADGE TYPE UTILITIES
;;;-----------------------------------------------------

(defun get-badge-shape (badge-code / prefix type-info shape)
  "Determine badge shape from badge code"
  (setq badge-code (strcase badge-code))
  
  ; Check each badge type
  (foreach type-pair *BADGE-TYPES*
    (setq type-info (cdr type-pair))
    (foreach prefix (cdr (assoc 'PREFIX type-info))
      (if (wcmatch badge-code (strcat prefix "*"))
        (setq shape (cdr (assoc 'SHAPE type-info)))
      )
    )
  )
  
  ; Default shape if not found
  (if (not shape)
    (setq shape "ELLIPSE")
  )
  
  shape
)

(defun get-badge-category (badge-code / prefix type-name category type-info)
  "Get badge category from code"
  (setq badge-code (strcase badge-code))
  
  (foreach type-pair *BADGE-TYPES*
    (setq type-name (car type-pair))
    (setq type-info (cdr type-pair))
    (foreach prefix (cdr (assoc 'PREFIX type-info))
      (if (wcmatch badge-code (strcat prefix "*"))
        (setq category type-name)
      )
    )
  )
  
  (if (not category)
    (setq category "FINISH")
  )
  
  category
)

;;;-----------------------------------------------------
;;; ERROR HANDLING
;;;-----------------------------------------------------

(defun badge-error-handler (msg)
  "Global error handler for badge system"
  (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
    (progn
      (princ "\n⚠ Badge System Error:")
      (princ (strcat "\n  " msg))
      (princ "\n")
      (princ "\n💡 Try: BADGEHELP for command reference")
    )
  )
  (setq *error* nil)
  (princ)
)

;;;-----------------------------------------------------
;;; STARTUP
;;;-----------------------------------------------------

(badge-system-init)

(princ "\nBadgeInit.lsp loaded.")
(princ)
