;;;; ExcelReader.lsp
;;;; Excel SSOT Ramus - Core COM Automation Functions
;;;; Version: 1.0
;;;; Created: November 22, 2025
;;;; Purpose: Read Excel workbooks for Badge Library SSOT

;;; =============================================================================
;;; CONFIGURATION
;;; =============================================================================

(setq *EXCEL-SSOT-PATH* 
  "G:\\My Drive\\_Feature\\_Millwork_Projects\\AutoCAD-Tools\\data\\Feature_Millwork_Master.xlsx")

(setq *EXCEL-CACHE-TIMEOUT* 300) ; 5 minutes
(setq *EXCEL-MAX-ROWS* 1000)
(setq *EXCEL-BADGE-CACHE* nil)   ; Global cache variable
(setq *EXCEL-CACHE-TIMESTAMP* nil)

;;; =============================================================================
;;; PUBLIC API FUNCTIONS
;;; =============================================================================

(defun excel:read-badge-library (excel-path / excel workbook sheet range data badges)
  "Read Badge_Library_MASTER sheet from Excel workbook.
   Returns list of badge records (association lists).
   Uses COM automation - requires Visual LISP extensions."
  
  (vl-load-com) ; Ensure COM loaded
  
  (setq excel nil
        workbook nil
        sheet nil
        data nil
        badges nil)
  
  (if (not (findfile excel-path))
    (progn
      (alert (strcat "Excel file not found: " excel-path))
      nil
    )
    (progn
      ;; Try to read Excel file with error handling
      (setq read-result 
        (vl-catch-all-apply 
          'excel:read-badge-library-internal 
          (list excel-path)))
      
      (if (vl-catch-all-error-p read-result)
        (progn
          (alert (strcat "Error reading Excel: " 
                         (vl-catch-all-error-message read-result)))
          nil
        )
        read-result
      )
    )
  )
)

(defun excel:get-badge-by-code (code / badge)
  "Get single badge record by Badge_Code from cache.
   Must call excel:read-badge-library first to populate cache."
  
  (if (null *EXCEL-BADGE-CACHE*)
    (progn
      (alert "Badge cache not loaded. Call (excel:read-badge-library path) first.")
      nil
    )
    (progn
      (setq badge 
        (car 
          (vl-remove-if-not 
            '(lambda (b) 
               (equal (cdr (assoc "CODE" b)) code))
            *EXCEL-BADGE-CACHE*)))
      badge
    )
  )
)

(defun excel:refresh-cache (/ result)
  "Force reload data from Excel file into cache.
   Returns t if successful, nil if failed."
  
  (setq result (excel:read-badge-library *EXCEL-SSOT-PATH*))
  
  (if result
    (progn
      (setq *EXCEL-BADGE-CACHE* result)
      (setq *EXCEL-CACHE-TIMESTAMP* (getvar "CDATE"))
      (princ (strcat "\nCache refreshed: " 
                     (itoa (length result)) 
                     " badges loaded.\n"))
      t
    )
    nil
  )
)

(defun excel:get-cache-stats ()
  "Get current cache statistics.
   Returns (row-count . timestamp) or nil if no cache."
  
  (if *EXCEL-BADGE-CACHE*
    (cons (length *EXCEL-BADGE-CACHE*) *EXCEL-CACHE-TIMESTAMP*)
    nil
  )
)

(defun excel:is-cached? ()
  "Check if badge data is currently cached.
   Returns t if cached, nil otherwise."
  
  (if *EXCEL-BADGE-CACHE* t nil)
)

(defun excel:clear-cache ()
  "Clear all cached badge data.
   Returns t."
  
  (setq *EXCEL-BADGE-CACHE* nil
        *EXCEL-CACHE-TIMESTAMP* nil)
  (princ "\nExcel cache cleared.\n")
  t
)

(defun excel:get-excel-path ()
  "Get configured default Excel file path."
  *EXCEL-SSOT-PATH*
)

;;; =============================================================================
;;; INTERNAL FUNCTIONS
;;; =============================================================================

(defun excel:read-badge-library-internal (excel-path / excel workbook sheet range data badges row-count)
  "Internal function - Read Excel with COM automation.
   DO NOT CALL DIRECTLY - Use excel:read-badge-library instead."
  
  (vl-load-com)
  
  ;; Create Excel application object
  (setq excel (vlax-get-or-create-object "Excel.Application"))
  
  (if (null excel)
    (progn
      (alert "Failed to create Excel COM object. Is Excel installed?")
      nil
    )
    (progn
      ;; Configure Excel instance
      (vlax-put-property excel 'Visible :vlax-false)
      (vlax-put-property excel 'DisplayAlerts :vlax-false)
      (vlax-put-property excel 'ScreenUpdating :vlax-false)
      
      ;; Open workbook (read-only)
      (setq workbook 
        (vlax-invoke-method 
          (vlax-get-property excel 'Workbooks) 
          'Open 
          excel-path 
          :vlax-true ; UpdateLinks = True
          :vlax-true ; ReadOnly = True
        ))
      
      (if (null workbook)
        (progn
          (vlax-invoke-method excel 'Quit)
          (vlax-release-object excel)
          (alert "Failed to open Excel workbook.")
          nil
        )
        (progn
          ;; Get Badge_Library_MASTER sheet
          (setq sheet 
            (vlax-get-property 
              (vlax-get-property workbook 'Sheets) 
              'Item 
              "Badge_Library_MASTER"))
          
          (if (null sheet)
            (progn
              (vlax-invoke-method workbook 'Close :vlax-false)
              (vlax-invoke-method excel 'Quit)
              (vlax-release-object workbook)
              (vlax-release-object excel)
              (alert "Sheet 'Badge_Library_MASTER' not found in workbook.")
              nil
            )
            (progn
              ;; Read used range (all data)
              (setq range (vlax-get-property sheet 'UsedRange))
              (setq data (vlax-get-property range 'Value))
              
              ;; Convert to list of badge records
              (setq badges (excel:parse-range-to-badges data))
              
              ;; Cleanup COM objects
              (vlax-invoke-method workbook 'Close :vlax-false)
              (vlax-invoke-method excel 'Quit)
              (vlax-release-object range)
              (vlax-release-object sheet)
              (vlax-release-object workbook)
              (vlax-release-object excel)
              
              ;; Update cache
              (setq *EXCEL-BADGE-CACHE* badges)
              (setq *EXCEL-CACHE-TIMESTAMP* (getvar "CDATE"))
              
              (princ (strcat "\nExcel read complete: " 
                             (itoa (length badges)) 
                             " badges loaded.\n"))
              
              badges
            )
          )
        )
      )
    )
  )
)

(defun excel:parse-range-to-badges (data / rows cols headers badge-list row-data badge i j)
  "Convert Excel range data to list of badge records.
   Assumes first row is headers, remaining rows are data.
   Returns list of association lists."
  
  (if (null data)
    nil
    (progn
      ;; Get dimensions
      (setq rows (vlax-safearray-get-u-bound data 1)
            cols (vlax-safearray-get-u-bound data 2))
      
      ;; Read header row (row 1)
      (setq headers '())
      (setq j 1)
      (while (<= j cols)
        (setq header-val (vlax-safearray-get-element data 1 j))
        (if (not (null header-val))
          (setq headers (append headers (list (vl-string-trim " " (vl-princ-to-string header-val)))))
          (setq headers (append headers (list (strcat "COLUMN_" (itoa j)))))
        )
        (setq j (1+ j))
      )
      
      ;; Read data rows (starting from row 2)
      (setq badge-list '())
      (setq i 2)
      
      (while (<= i rows)
        (setq row-data '())
        (setq j 1)
        
        ;; Read each column
        (while (<= j cols)
          (setq cell-val (vlax-safearray-get-element data i j))
          
          ;; Convert to string and clean
          (if (null cell-val)
            (setq cell-val "")
            (setq cell-val (vl-string-trim " " (vl-princ-to-string cell-val)))
          )
          
          (setq row-data (append row-data (list cell-val)))
          (setq j (1+ j))
        )
        
        ;; Create association list (header . value pairs)
        (setq badge (excel:zip-lists headers row-data))
        
        ;; Only add if Badge_Code is not empty
        (if (and badge (not (equal (cdr (assoc "Badge_Code" badge)) "")))
          (setq badge-list (append badge-list (list badge)))
        )
        
        (setq i (1+ i))
      )
      
      badge-list
    )
  )
)

(defun excel:zip-lists (keys values / result i)
  "Combine two lists into association list.
   (excel:zip-lists '(\"A\" \"B\" \"C\") '(1 2 3)) -> ((\"A\" . 1) (\"B\" . 2) (\"C\" . 3))"
  
  (setq result '()
        i 0)
  
  (while (and (< i (length keys)) (< i (length values)))
    (setq result 
      (append result 
        (list (cons (nth i keys) (nth i values)))))
    (setq i (1+ i))
  )
  
  result
)

;;; =============================================================================
;;; UTILITY FUNCTIONS
;;; =============================================================================

(defun excel:print-badge (badge)
  "Pretty-print a badge record for debugging."
  
  (princ "\n====== BADGE RECORD ======")
  (foreach pair badge
    (princ (strcat "\n" (car pair) ": " (cdr pair)))
  )
  (princ "\n==========================\n")
  (princ)
)

(defun excel:validate-file (path)
  "Validate Excel file exists and has correct format.
   Returns t if valid, nil otherwise."
  
  (if (not (findfile path))
    (progn
      (princ (strcat "\nFile not found: " path "\n"))
      nil
    )
    (if (not (wcmatch (strcase path) "*.XLSX,*.XLSM"))
      (progn
        (princ (strcat "\nInvalid file format (must be .xlsx or .xlsm): " path "\n"))
        nil
      )
      t
    )
  )
)

;;; =============================================================================
;;; INITIALIZATION
;;; =============================================================================

(princ "\n")
(princ "============================================\n")
(princ "Excel SSOT Ramus Loaded - Version 1.0\n")
(princ "============================================\n")
(princ "Commands:\n")
(princ "  (excel:read-badge-library \"path\")  - Read Excel file\n")
(princ "  (excel:get-badge-by-code \"PL1\")    - Get badge by code\n")
(princ "  (excel:refresh-cache)               - Reload from Excel\n")
(princ "  (excel:get-cache-stats)             - View cache info\n")
(princ "  (excel:clear-cache)                 - Clear cache\n")
(princ "\n")
(princ "Default Excel path:\n")
(princ (strcat "  " *EXCEL-SSOT-PATH* "\n"))
(princ "============================================\n")
(princ)

;;; EOF
