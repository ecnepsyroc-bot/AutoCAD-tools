;;;=====================================================
;;; BadgeLibrary.lsp
;;; Badge library data management and caching
;;;
;;; Load Order: After BadgeInit.lsp
;;; Required by: CreateBadgesForJob, UpdateBadges
;;;=====================================================

;;;-----------------------------------------------------
;;; LIBRARY CACHE MANAGEMENT
;;;-----------------------------------------------------

(defun load-badge-library (/ csv-path)
  "Load badge library into memory cache"
  (setq csv-path (get-badge-csv-path))
  
  (princ "\n")
  (princ "\nLoading Badge Library...")
  (princ (strcat "\nPath: " csv-path))
  
  ; Clear existing cache
  (setq *BADGE-LIBRARY-DATA* nil)
  
  ; Load data using utility function from BadgeUtils
  (if (findfile csv-path)
    (progn
      (setq *BADGE-LIBRARY-DATA* (read-badge-library csv-path))
      
      (if *BADGE-LIBRARY-DATA*
        (progn
          (princ (strcat "\n✓ Loaded " (itoa (length *BADGE-LIBRARY-DATA*)) " badge definitions"))
          T
        )
        (progn
          (princ "\n⚠ No badge data found in CSV")
          nil
        )
      )
    )
    (progn
      (princ "\n⚠ Badge library file not found!")
      (princ "\n")
      (princ "\n💡 Expected location:")
      (princ (strcat "\n  " csv-path))
      nil
    )
  )
)

(defun get-badge-library ()
  "Get cached badge library data"
  (if (not *BADGE-LIBRARY-DATA*)
    (load-badge-library)
  )
  *BADGE-LIBRARY-DATA*
)

(defun clear-badge-library ()
  "Clear badge library cache"
  (setq *BADGE-LIBRARY-DATA* nil)
  (princ "\n✓ Badge library cache cleared")
)

;;;-----------------------------------------------------
;;; BADGE LOOKUP FUNCTIONS
;;;-----------------------------------------------------

(defun find-badge-in-library (badge-code / library badge-data found)
  "Find badge data by code in library"
  (setq library (get-badge-library))
  (setq found nil)
  
  (if library
    (foreach badge library
      (if (and (not found)
               (= (strcase (car badge)) (strcase badge-code)))
        (setq found badge)
      )
    )
  )
  
  found
)

(defun get-badge-description (badge-code / badge-data)
  "Get description for a badge code"
  (setq badge-data (find-badge-in-library badge-code))
  
  (if badge-data
    (nth 2 badge-data)  ; Description is 3rd field
    "No description"
  )
)

(defun get-badge-material (badge-code / badge-data)
  "Get material for a badge code"
  (setq badge-data (find-badge-in-library badge-code))
  
  (if badge-data
    (nth 3 badge-data)  ; Material is 4th field
    "Not specified"
  )
)

(defun get-badge-supplier (badge-code / badge-data)
  "Get supplier for a badge code"
  (setq badge-data (find-badge-in-library badge-code))
  
  (if badge-data
    (if (>= (length badge-data) 5)
      (nth 4 badge-data)  ; Supplier is 5th field
      ""
    )
    ""
  )
)

;;;-----------------------------------------------------
;;; JOB-SPECIFIC BADGE FILTERING
;;;-----------------------------------------------------

(defun get-job-badges (job-name / library job-badges)
  "Get badges for a specific job"
  (setq library (get-badge-library))
  (setq job-badges '())
  (setq job-name (strcase job-name))
  
  ; For now, return all badges
  ; In future, could filter based on job-specific criteria
  (setq job-badges library)
  
  job-badges
)

(defun get-badges-by-category (category / library filtered badge-cat)
  "Get all badges of a specific category"
  (setq library (get-badge-library))
  (setq filtered '())
  (setq category (strcase category))
  
  (foreach badge library
    (setq badge-cat (strcase (nth 1 badge)))  ; Category is 2nd field
    (if (= badge-cat category)
      (setq filtered (append filtered (list badge)))
    )
  )
  
  filtered
)

(defun get-badges-by-prefix (prefix / library filtered badge-code)
  "Get all badges with a specific prefix"
  (setq library (get-badge-library))
  (setq filtered '())
  (setq prefix (strcase prefix))
  
  (foreach badge library
    (setq badge-code (strcase (car badge)))
    (if (wcmatch badge-code (strcat prefix "*"))
      (setq filtered (append filtered (list badge)))
    )
  )
  
  filtered
)

;;;-----------------------------------------------------
;;; LIBRARY STATISTICS
;;;-----------------------------------------------------

(defun get-library-stats (/ library stats categories count)
  "Get statistics about the badge library"
  (setq library (get-badge-library))
  (setq stats '())
  
  (if library
    (progn
      ; Count total badges
      (setq stats (append stats (list (cons "TOTAL" (length library)))))
      
      ; Count by category
      (setq categories '("FINISH" "FIXTURE" "EQUIPMENT"))
      (foreach cat categories
        (setq count (length (get-badges-by-category cat)))
        (setq stats (append stats (list (cons cat count))))
      )
    )
  )
  
  stats
)

;;;-----------------------------------------------------
;;; LIBRARY REPORTING
;;;-----------------------------------------------------

(defun C:BADGESTATS (/ stats)
  "Display badge library statistics"
  (princ "\n")
  (princ "\n================================================")
  (princ "\n  BADGE LIBRARY STATISTICS")
  (princ "\n================================================")
  
  (setq stats (get-library-stats))
  
  (if stats
    (progn
      (princ (strcat "\n  Total Badges: " (itoa (cdr (assoc "TOTAL" stats)))))
      (princ "\n")
      (princ "\n  By Category:")
      (princ (strcat "\n    Finish:    " (itoa (cdr (assoc "FINISH" stats)))))
      (princ (strcat "\n    Fixture:   " (itoa (cdr (assoc "FIXTURE" stats)))))
      (princ (strcat "\n    Equipment: " (itoa (cdr (assoc "EQUIPMENT" stats)))))
    )
    (princ "\n  No library data loaded")
  )
  
  (princ "\n================================================")
  (princ)
)

(defun C:LISTBADGES (/ prefix badges)
  "List badges by prefix"
  (setq prefix (getstring "\nEnter badge prefix (PL/PT/SS/ST/APPL/EQ) or ENTER for all: "))
  
  (if (= prefix "")
    (setq badges (get-badge-library))
    (setq badges (get-badges-by-prefix prefix))
  )
  
  (if badges
    (progn
      (princ (strcat "\n\nFound " (itoa (length badges)) " badges:"))
      (princ "\n------------------------------------------------")
      (foreach badge badges
        (princ (strcat "\n" (nth 0 badge) " - " (nth 2 badge)))
      )
      (princ "\n------------------------------------------------")
    )
    (princ "\n⚠ No badges found")
  )
  (princ)
)

;;;-----------------------------------------------------
;;; LIBRARY REFRESH
;;;-----------------------------------------------------

(defun C:REFRESHBADGES (/)
  "Refresh badge library from CSV"
  (clear-badge-library)
  (if (load-badge-library)
    (princ "\n✓ Badge library refreshed successfully")
    (princ "\n⚠ Failed to refresh badge library")
  )
  (princ)
)

;;;-----------------------------------------------------
;;; LIBRARY VALIDATION
;;;-----------------------------------------------------

(defun validate-library-entry (badge-data / valid badge-code)
  "Validate a single library entry"
  (setq valid T)
  
  ; Check field count (now 6 without ALERT field)
  (if (< (length badge-data) 5)
    (progn
      (princ "\n⚠ Insufficient fields in badge data")
      (setq valid nil)
    )
  )
  
  ; Check badge code
  (setq badge-code (car badge-data))
  (if (or (not badge-code) (= badge-code ""))
    (progn
      (princ "\n⚠ Missing badge code")
      (setq valid nil)
    )
  )
  
  valid
)

(defun C:VALIDATELIBRARY (/ library invalid-count badge)
  "Validate entire badge library"
  (princ "\nValidating badge library...")
  
  (setq library (get-badge-library))
  (setq invalid-count 0)
  
  (if library
    (progn
      (foreach badge library
        (if (not (validate-library-entry badge))
          (progn
            (princ (strcat "\n  Invalid: " (car badge)))
            (setq invalid-count (1+ invalid-count))
          )
        )
      )
      
      (princ "\n")
      (princ (strcat "\n✓ Validated " (itoa (length library)) " entries"))
      (if (> invalid-count 0)
        (princ (strcat "\n⚠ Found " (itoa invalid-count) " invalid entries"))
        (princ "\n✓ All entries valid")
      )
    )
    (princ "\n⚠ No library data to validate")
  )
  (princ)
)

(princ "\nBadgeLibrary.lsp loaded.")
(princ "\nCommands: BADGESTATS | LISTBADGES | REFRESHBADGES | VALIDATELIBRARY")
(princ)
