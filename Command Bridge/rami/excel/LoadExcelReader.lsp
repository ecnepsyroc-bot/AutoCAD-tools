;;;; LoadExcelReader.lsp
;;;; Loader script for Excel SSOT Ramus
;;;; Load this file in AutoCAD to test Excel reader functionality

(defun C:LOAD-EXCEL-READER ()
  "Load Excel reader and test suite"
  
  (setq script-dir (getvar "DWGPREFIX"))
  (setq project-root "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD tools\\")
  (setq excel-ramus-path (strcat project-root "Command Bridge\\rami\\excel\\"))
  
  (princ "\n============================================")
  (princ "\nLoading Excel SSOT Ramus...")
  (princ "\n============================================\n")
  
  ;; Load ExcelReader.lsp
  (princ "\n📦 Loading ExcelReader.lsp...")
  (if (findfile (strcat excel-ramus-path "ExcelReader.lsp"))
    (progn
      (load (strcat excel-ramus-path "ExcelReader.lsp"))
      (princ " ✅")
    )
    (princ " ❌ FILE NOT FOUND")
  )
  
  ;; Load TestExcelReader.lsp
  (princ "\n📦 Loading TestExcelReader.lsp...")
  (if (findfile (strcat excel-ramus-path "TestExcelReader.lsp"))
    (progn
      (load (strcat excel-ramus-path "TestExcelReader.lsp"))
      (princ " ✅")
    )
    (princ " ❌ FILE NOT FOUND")
  )
  
  (princ "\n\n============================================")
  (princ "\n✅ Excel Reader Loaded Successfully!")
  (princ "\n============================================")
  (princ "\n\nNext steps:")
  (princ "\n  1. Type: TEST-EXCEL")
  (princ "\n  2. Review test results")
  (princ "\n  3. Check performance benchmarks")
  (princ "\n\n============================================\n")
  (princ)
)

;; Auto-run on load
(C:LOAD-EXCEL-READER)

;;; EOF
