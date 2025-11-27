;;;; TestExcelReader.lsp
;;;; Test and benchmark Excel reader functions
;;;; Version: 1.0
;;;; Created: November 22, 2025

;;; =============================================================================
;;; TEST CONFIGURATION
;;; =============================================================================

(setq *TEST-EXCEL-PATH* 
  "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD tools\\01_SSOT_EXCEL_TEMPLATE\\Feature_Millwork_Test.xlsx")

;;; =============================================================================
;;; TEST FUNCTIONS
;;; =============================================================================

(defun test-excel-basic ()
  "Basic test - Read Excel file and display results"
  
  (princ "\n============================================")
  (princ "\nTEST 1: Basic Excel Read")
  (princ "\n============================================\n")
  
  (if (not (findfile *TEST-EXCEL-PATH*))
    (progn
      (princ (strcat "\n❌ FAILED: Test file not found: " *TEST-EXCEL-PATH* "\n"))
      nil
    )
    (progn
      (princ (strcat "\n📁 Reading: " *TEST-EXCEL-PATH* "\n"))
      
      ;; Time the operation
      (setq start-time (getvar "MILLISECS"))
      (setq badges (excel:read-badge-library *TEST-EXCEL-PATH*))
      (setq end-time (getvar "MILLISECS"))
      (setq duration (- end-time start-time))
      
      (if (null badges)
        (progn
          (princ "\n❌ FAILED: No badges loaded\n")
          nil
        )
        (progn
          (princ (strcat "\n✅ SUCCESS: " (itoa (length badges)) " badges loaded"))
          (princ (strcat "\n⏱️  Duration: " (itoa duration) " ms\n"))
          
          ;; Display first badge
          (if (> (length badges) 0)
            (progn
              (princ "\n📋 First badge:")
              (excel:print-badge (car badges))
            )
          )
          
          t
        )
      )
    )
  )
)

(defun test-excel-lookup ()
  "Test badge lookup by code"
  
  (princ "\n============================================")
  (princ "\nTEST 2: Badge Lookup by Code")
  (princ "\n============================================\n")
  
  (setq test-codes '("PL1" "WP1" "NONEXISTENT" "SL1"))
  
  (foreach code test-codes
    (princ (strcat "\n🔍 Looking up: " code))
    (setq badge (excel:get-badge-by-code code))
    
    (if (null badge)
      (princ " ❌ NOT FOUND")
      (progn
        (princ " ✅ FOUND")
        (princ (strcat "\n   Description: " (cdr (assoc "Full_Description" badge))))
      )
    )
  )
  
  (princ "\n")
  t
)

(defun test-excel-cache ()
  "Test cache refresh functionality"
  
  (princ "\n============================================")
  (princ "\nTEST 3: Cache Operations")
  (princ "\n============================================\n")
  
  ;; Check cache status
  (princ "\n📊 Cache status before refresh:")
  (setq stats (excel:get-cache-stats))
  (if stats
    (princ (strcat "\n   Cached rows: " (itoa (car stats))))
    (princ "\n   Cache empty")
  )
  
  ;; Refresh cache
  (princ "\n\n🔄 Refreshing cache...")
  (setq start-time (getvar "MILLISECS"))
  (setq result (excel:refresh-cache))
  (setq end-time (getvar "MILLISECS"))
  (setq duration (- end-time start-time))
  
  (if result
    (progn
      (princ (strcat "\n✅ Cache refreshed in " (itoa duration) " ms"))
      (setq stats (excel:get-cache-stats))
      (princ (strcat "\n   Cached rows: " (itoa (car stats))))
    )
    (princ "\n❌ Cache refresh failed")
  )
  
  ;; Test cache lookup speed
  (princ "\n\n⚡ Testing cache lookup speed...")
  (setq start-time (getvar "MILLISECS"))
  (repeat 100
    (excel:get-badge-by-code "PL1")
  )
  (setq end-time (getvar "MILLISECS"))
  (setq duration (- end-time start-time))
  
  (princ (strcat "\n   100 lookups in " (itoa duration) " ms"))
  (princ (strcat "\n   Average: " (rtos (/ duration 100.0) 2 2) " ms per lookup\n"))
  
  t
)

(defun test-excel-all-badges ()
  "Display all badges in cache"
  
  (princ "\n============================================")
  (princ "\nTEST 4: Display All Badges")
  (princ "\n============================================\n")
  
  (if (not (excel:is-cached?))
    (progn
      (princ "\n⚠️  Cache not loaded. Loading...")
      (excel:refresh-cache)
    )
  )
  
  (setq badges *EXCEL-BADGE-CACHE*)
  
  (if (null badges)
    (princ "\n❌ No badges in cache\n")
    (progn
      (princ (strcat "\n📋 Total badges: " (itoa (length badges)) "\n"))
      (princ "\n┌────────────┬────────────────────────────────────────────┬──────────────┐")
      (princ "\n│ Badge Code │ Description                                │ Alert Status │")
      (princ "\n├────────────┼────────────────────────────────────────────┼──────────────┤")
      
      (foreach badge badges
        (setq code (cdr (assoc "Badge_Code" badge)))
        (setq desc (cdr (assoc "Full_Description" badge)))
        (setq alert (cdr (assoc "Alert_Status" badge)))
        
        ;; Truncate description if too long
        (if (> (strlen desc) 40)
          (setq desc (strcat (substr desc 1 37) "..."))
        )
        
        ;; Pad strings
        (setq code-padded (strcat code (substr "          " 1 (- 10 (strlen code)))))
        (setq desc-padded (strcat desc (substr "                                        " 1 (- 40 (strlen desc)))))
        (setq alert-padded (strcat alert (substr "            " 1 (- 12 (strlen alert)))))
        
        (princ (strcat "\n│ " code-padded " │ " desc-padded " │ " alert-padded " │"))
      )
      
      (princ "\n└────────────┴────────────────────────────────────────────┴──────────────┘\n")
    )
  )
  
  t
)

(defun test-excel-validation ()
  "Test file validation functions"
  
  (princ "\n============================================")
  (princ "\nTEST 5: File Validation")
  (princ "\n============================================\n")
  
  (setq test-paths 
    (list
      *TEST-EXCEL-PATH*
      "C:\\NonExistent\\File.xlsx"
      "C:\\Users\\test.txt"
      "C:\\Users\\test.xlsm"
    )
  )
  
  (foreach path test-paths
    (princ (strcat "\n🔍 Validating: " path))
    (setq result (excel:validate-file path))
    
    (if result
      (princ " ✅ VALID")
      (princ " ❌ INVALID")
    )
  )
  
  (princ "\n")
  t
)

(defun benchmark-excel-vs-csv ()
  "Benchmark Excel read vs CSV read (if CSV exists)"
  
  (princ "\n============================================")
  (princ "\nBENCHMARK: Excel vs CSV Performance")
  (princ "\n============================================\n")
  
  ;; Excel read
  (princ "\n⏱️  Testing Excel read performance...")
  (setq excel-times '())
  
  (repeat 5
    (setq start-time (getvar "MILLISECS"))
    (excel:read-badge-library *TEST-EXCEL-PATH*)
    (setq end-time (getvar "MILLISECS"))
    (setq excel-times (cons (- end-time start-time) excel-times))
  )
  
  (setq excel-avg (/ (apply '+ excel-times) (length excel-times)))
  (princ (strcat "\n   Excel avg (5 runs): " (itoa excel-avg) " ms"))
  (princ (strcat "\n   Range: " (itoa (apply 'min excel-times)) " - " (itoa (apply 'max excel-times)) " ms"))
  
  ;; Cache read
  (princ "\n\n⏱️  Testing cache read performance...")
  (excel:refresh-cache)
  
  (setq cache-times '())
  (repeat 100
    (setq start-time (getvar "MILLISECS"))
    (excel:get-badge-by-code "PL1")
    (setq end-time (getvar "MILLISECS"))
    (setq cache-times (cons (- end-time start-time) cache-times))
  )
  
  (setq cache-avg (/ (apply '+ cache-times) (length cache-times)))
  (princ (strcat "\n   Cache avg (100 runs): " (rtos cache-avg 2 3) " ms"))
  
  (princ "\n\n📊 Performance Summary:")
  (princ (strcat "\n   Excel read: " (itoa excel-avg) " ms"))
  (princ (strcat "\n   Cache lookup: " (rtos cache-avg 2 3) " ms"))
  (princ (strcat "\n   Speedup: " (rtos (/ excel-avg cache-avg) 2 0) "x faster\n"))
  
  t
)

;;; =============================================================================
;;; TEST SUITE RUNNER
;;; =============================================================================

(defun run-all-tests ()
  "Run all Excel reader tests"
  
  (princ "\n")
  (princ "════════════════════════════════════════════\n")
  (princ "  EXCEL READER TEST SUITE\n")
  (princ "════════════════════════════════════════════\n")
  (princ (strcat "  Test File: " *TEST-EXCEL-PATH* "\n"))
  (princ "════════════════════════════════════════════\n")
  
  (setq all-passed t)
  
  ;; Run tests
  (if (not (test-excel-basic)) (setq all-passed nil))
  (if (not (test-excel-lookup)) (setq all-passed nil))
  (if (not (test-excel-cache)) (setq all-passed nil))
  (if (not (test-excel-validation)) (setq all-passed nil))
  (test-excel-all-badges)
  (benchmark-excel-vs-csv)
  
  ;; Summary
  (princ "\n")
  (princ "════════════════════════════════════════════\n")
  (if all-passed
    (princ "  ✅ ALL TESTS PASSED\n")
    (princ "  ❌ SOME TESTS FAILED\n")
  )
  (princ "════════════════════════════════════════════\n")
  (princ)
)

;;; =============================================================================
;;; QUICK TEST COMMAND
;;; =============================================================================

(defun c:TEST-EXCEL ()
  "Command to run Excel reader tests"
  (run-all-tests)
  (princ)
)

;;; =============================================================================
;;; INITIALIZATION
;;; =============================================================================

(princ "\n")
(princ "============================================\n")
(princ "Excel Reader Test Suite Loaded\n")
(princ "============================================\n")
(princ "Commands:\n")
(princ "  TEST-EXCEL                - Run all tests\n")
(princ "  (test-excel-basic)        - Basic read test\n")
(princ "  (test-excel-lookup)       - Lookup test\n")
(princ "  (test-excel-cache)        - Cache test\n")
(princ "  (test-excel-all-badges)   - Display all\n")
(princ "  (benchmark-excel-vs-csv)  - Performance\n")
(princ "============================================\n")
(princ)

;;; EOF
