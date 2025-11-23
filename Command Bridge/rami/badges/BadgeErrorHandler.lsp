;;;=====================================================
;;; BadgeErrorHandler.lsp
;;; Error handling and recovery for badge operations
;;;
;;; Load Order: Early (after BadgeInit.lsp)
;;; Used by: All badge operation files
;;;=====================================================

;;;-----------------------------------------------------
;;; ERROR CONTEXT TRACKING
;;;-----------------------------------------------------

(setq *BADGE-ERROR-STACK* nil)
(setq *BADGE-LAST-ERROR* nil)
(setq *BADGE-ERROR-COUNT* 0)

;;;-----------------------------------------------------
;;; ERROR WRAPPER FUNCTIONS
;;;-----------------------------------------------------

(defun badge-safe-execute (func-name func-args / old-error result error-msg)
  "Safely execute a function with error handling"
  
  ; Store current error handler
  (setq old-error *error*)
  
  ; Define local error handler
  (defun *error* (msg)
    (if (not (wcmatch (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (progn
        ; Log the error
        (setq *BADGE-LAST-ERROR* msg)
        (setq *BADGE-ERROR-COUNT* (1+ *BADGE-ERROR-COUNT*))
        (setq *BADGE-ERROR-STACK* 
              (append *BADGE-ERROR-STACK* 
                     (list (list func-name msg (getvar "DATE")))))
        
        ; Display error
        (princ "\n")
        (princ "\n⚠️ BADGE SYSTEM ERROR")
        (princ "\n------------------------")
        (princ (strcat "\n  Function: " func-name))
        (princ (strcat "\n  Error: " msg))
        (princ "\n")
        
        ; Attempt recovery
        (badge-error-recovery)
      )
    )
    
    ; Restore original error handler
    (setq *error* old-error)
  )
  
  ; Try to execute the function
  (setq result (vl-catch-all-apply func-name func-args))
  
  ; Check for errors
  (if (vl-catch-all-error-p result)
    (progn
      (setq error-msg (vl-catch-all-error-message result))
      (*error* error-msg)
      nil  ; Return nil on error
    )
    result  ; Return actual result
  )
  
  ; Restore error handler
  (setq *error* old-error)
  
  result
)

;;;-----------------------------------------------------
;;; ERROR RECOVERY
;;;-----------------------------------------------------

(defun badge-error-recovery (/ )
  "Attempt to recover from badge system error"
  
  (princ "\n🔧 Attempting recovery...")
  
  ; Reset system variables
  (setvar "CMDECHO" 0)
  (setvar "ATTDIA" 0)
  (setvar "ATTREQ" 1)
  
  ; Clear command
  (command)
  
  ; Regen if needed
  (if (> (getvar "DBMOD") 0)
    (command "._REGEN")
  )
  
  (princ "\n✓ Recovery complete")
  (princ "\n")
  (princ "\n💡 TIP: Use BADGEERRORS to view error log")
  (princ)
)

;;;-----------------------------------------------------
;;; ERROR LOGGING
;;;-----------------------------------------------------

(defun log-badge-error (operation details / log-entry timestamp)
  "Log an error to the stack"
  
  (setq timestamp (rtos (getvar "DATE") 2 6))
  (setq log-entry (list operation details timestamp))
  
  (setq *BADGE-ERROR-STACK* 
        (append *BADGE-ERROR-STACK* (list log-entry)))
  
  ; Keep only last 50 errors
  (if (> (length *BADGE-ERROR-STACK*) 50)
    (setq *BADGE-ERROR-STACK* (cdr *BADGE-ERROR-STACK*))
  )
)

;;;-----------------------------------------------------
;;; ERROR REPORTING
;;;-----------------------------------------------------

(defun C:BADGEERRORS (/ i error-entry)
  "Display badge system error log"
  
  (princ "\n")
  (princ "\n================================================")
  (princ "\n  BADGE SYSTEM ERROR LOG")
  (princ "\n================================================")
  
  (if *BADGE-ERROR-STACK*
    (progn
      (princ (strcat "\n  Total Errors: " (itoa *BADGE-ERROR-COUNT*)))
      (princ "\n")
      (princ "\n  Recent Errors:")
      (princ "\n  --------------")
      
      ; Show last 10 errors
      (setq i (max 0 (- (length *BADGE-ERROR-STACK*) 10)))
      (while (< i (length *BADGE-ERROR-STACK*))
        (setq error-entry (nth i *BADGE-ERROR-STACK*))
        (princ "\n")
        (princ (strcat "\n  " (itoa (1+ i)) ". " (car error-entry)))
        (princ (strcat "\n     " (cadr error-entry)))
        (setq i (1+ i))
      )
    )
    (progn
      (princ "\n  ✓ No errors logged")
    )
  )
  
  (princ "\n================================================")
  (princ)
)

(defun C:CLEARERRORS (/)
  "Clear badge system error log"
  (setq *BADGE-ERROR-STACK* nil)
  (setq *BADGE-LAST-ERROR* nil)
  (setq *BADGE-ERROR-COUNT* 0)
  (princ "\n✓ Error log cleared")
  (princ)
)

;;;-----------------------------------------------------
;;; VALIDATION FUNCTIONS
;;;-----------------------------------------------------

(defun validate-badge-operation (operation required-conditions / valid msg)
  "Validate conditions before badge operation"
  (setq valid T)
  (setq msg "")
  
  ; Check each condition
  (foreach condition required-conditions
    (cond
      ; Check for library data
      ((= condition "LIBRARY")
       (if (not *BADGE-LIBRARY-DATA*)
         (progn
           (setq valid nil)
           (setq msg "Badge library not loaded")
         )
       )
      )
      
      ; Check for job context
      ((= condition "JOB")
       (if (not *BADGE-JOB-NAME*)
         (progn
           (setq valid nil)
           (setq msg "No job selected")
         )
       )
      )
      
      ; Check for CSV file
      ((= condition "CSV")
       (if (not (findfile *BADGE-CSV-PATH*))
         (progn
           (setq valid nil)
           (setq msg "CSV file not found")
         )
       )
      )
      
      ; Check for selection
      ((= condition "SELECTION")
       (if (not (ssget "I"))
         (progn
           (setq valid nil)
           (setq msg "No objects selected")
         )
       )
      )
    )
  )
  
  ; Log if invalid
  (if (not valid)
    (log-badge-error operation msg)
  )
  
  (list valid msg)
)

;;;-----------------------------------------------------
;;; FILE OPERATION SAFETY
;;;-----------------------------------------------------

(defun safe-file-open (filepath mode / file retry-count max-retries delay)
  "Safely open file with retry logic"
  (setq retry-count 0)
  (setq max-retries 5)
  (setq delay 1.5)
  
  (while (and (< retry-count max-retries)
              (not file))
    (setq file (open filepath mode))
    
    (if (not file)
      (progn
        (if (= retry-count 0)
          (princ (strcat "\n⏳ File locked, retrying..."))
        )
        (command "._DELAY" (fix (* delay 1000)))
        (setq retry-count (1+ retry-count))
      )
    )
  )
  
  (if file
    (progn
      (if (> retry-count 0)
        (princ "\n✓ File opened successfully")
      )
      file
    )
    (progn
      (log-badge-error "FILE-OPEN" 
                      (strcat "Failed to open: " filepath))
      nil
    )
  )
)

(defun safe-file-close (file / )
  "Safely close file handle"
  (if file
    (vl-catch-all-apply 'close (list file))
  )
)

;;;-----------------------------------------------------
;;; BLOCK OPERATION SAFETY
;;;-----------------------------------------------------

(defun safe-block-insert (block-name point scale rotation / result)
  "Safely insert a block with error handling"
  
  ; Validate block exists
  (if (not (tblsearch "BLOCK" block-name))
    (progn
      (log-badge-error "BLOCK-INSERT" 
                      (strcat "Block not found: " block-name))
      nil
    )
    (progn
      ; Try to insert
      (setq result 
            (badge-safe-execute 
              'command 
              (list "._INSERT" block-name point scale scale rotation)))
      
      (if result
        (entlast)  ; Return the inserted entity
        nil
      )
    )
  )
)

;;;-----------------------------------------------------
;;; ATTRIBUTE OPERATION SAFETY
;;;-----------------------------------------------------

(defun safe-attribute-read (ent tag / result)
  "Safely read attribute value"
  
  ; Validate entity
  (if (not (and ent (entget ent)))
    (progn
      (log-badge-error "ATTRIBUTE-READ" "Invalid entity")
      nil
    )
    (progn
      ; Try to read attribute
      (setq result 
            (badge-safe-execute 
              'get-badge-attribute 
              (list ent tag)))
      result
    )
  )
)

(defun safe-attribute-write (ent tag value / result)
  "Safely write attribute value"
  
  ; Validate entity
  (if (not (and ent (entget ent)))
    (progn
      (log-badge-error "ATTRIBUTE-WRITE" "Invalid entity")
      nil
    )
    (progn
      ; Try to write attribute
      (setq result 
            (badge-safe-execute 
              'set-badge-attribute 
              (list ent tag value)))
      result
    )
  )
)

;;;-----------------------------------------------------
;;; SYSTEM STATE VALIDATION
;;;-----------------------------------------------------

(defun C:CHECKBADGESYSTEM (/ issues)
  "Check badge system health"
  
  (princ "\n")
  (princ "\n================================================")
  (princ "\n  BADGE SYSTEM HEALTH CHECK")
  (princ "\n================================================")
  (setq issues 0)
  
  ; Check CSV path
  (princ "\n\n📁 CSV File:")
  (if (findfile *BADGE-CSV-PATH*)
    (princ " ✓ Found")
    (progn
      (princ " ⚠ Not found")
      (setq issues (1+ issues))
    )
  )
  
  ; Check library data
  (princ "\n📚 Library Data:")
  (if *BADGE-LIBRARY-DATA*
    (princ (strcat " ✓ Loaded (" 
                  (itoa (length *BADGE-LIBRARY-DATA*)) 
                  " badges)"))
    (progn
      (princ " ⚠ Not loaded")
      (setq issues (1+ issues))
    )
  )
  
  ; Check job context
  (princ "\n🏢 Job Context:")
  (if *BADGE-JOB-NAME*
    (princ (strcat " ✓ " *BADGE-JOB-NAME*))
    (princ " ℹ None selected")
  )
  
  ; Check layer
  (princ "\n📐 Layer:")
  (if (tblsearch "LAYER" *BADGE-LAYER-NAME*)
    (princ " ✓ Badge layer exists")
    (progn
      (princ " ⚠ Badge layer missing")
      (setq issues (1+ issues))
    )
  )
  
  ; Check system variables
  (princ "\n⚙️ System Variables:")
  (if (and (= (getvar "ATTDIA") 0)
           (= (getvar "ATTREQ") 1))
    (princ " ✓ Configured")
    (progn
      (princ " ⚠ Need configuration")
      (setq issues (1+ issues))
    )
  )
  
  ; Check error state
  (princ "\n🔧 Error State:")
  (if (= *BADGE-ERROR-COUNT* 0)
    (princ " ✓ No errors")
    (princ (strcat " ⚠ " (itoa *BADGE-ERROR-COUNT*) " errors logged"))
  )
  
  ; Summary
  (princ "\n")
  (princ "\n================================================")
  (if (= issues 0)
    (princ "\n✅ SYSTEM HEALTHY")
    (progn
      (princ (strcat "\n⚠️ " (itoa issues) " ISSUES FOUND"))
      (princ "\n")
      (princ "\n💡 Run CBJ to initialize job context")
      (princ "\n💡 Run REFRESHBADGES to reload library")
    )
  )
  (princ "\n================================================")
  (princ)
)

(princ "\nBadgeErrorHandler.lsp loaded.")
(princ "\nCommands: BADGEERRORS | CLEARERRORS | CHECKBADGESYSTEM")
(princ)
