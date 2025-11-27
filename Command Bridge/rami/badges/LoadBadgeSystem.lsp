;;;=====================================================
;;; LoadBadgeSystem.lsp
;;; Master loader for AutoCAD Badge System
;;;
;;; This is the ONLY file that needs to be loaded
;;; to initialize the complete badge system.
;;;
;;; Usage: (load "LoadBadgeSystem.lsp")
;;;=====================================================

(defun load-badge-system (/ base-path file-list file-path file-name load-count start-time elapsed)
  "Load all badge system components in correct order"
  
  (setq start-time (getvar "MILLISECS"))
  
  (princ "\n")
  (princ "\n================================================")
  (princ "\n   AUTOCAD BADGE SYSTEM - LOADING")
  (princ "\n================================================")
  (princ "\n")
  
  ; Define base path (update this to match your installation)
  (setq base-path "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD Badge System\\")
  
  ; Define load order - CRITICAL for dependencies
  ; NOTE: Following Luxify Tree branch architecture
  ; Removed monolithic files - now using clean branch structure
  (setq file-list
    '(
      ; 1. Core initialization (BRANCH: badges/init)
      "BadgeInit.lsp"           ; System globals and config
      
      ; 2. Data management (BRANCH: badges/data)
      "BadgeLibrary.lsp"         ; Library cache and lookup
      "BadgeAttributes.lsp"      ; Attribute manipulation
      
      ; 3. Selection utilities (BRANCH: badges/selection)
      "BadgeSelection.lsp"       ; Selection and filtering
      
      ; 4. Error handling (BRANCH: badges/sap)
      "BadgeErrorHandler.lsp"    ; Error handling and recovery
      
      ; NOTE: Removed monolithic files:
      ; - BadgeUtils.lsp (functionality distributed to branches)
      ; - CreateBadgeBlocks.lsp (to be recreated in branch structure)
      ; - CreateBadgesForJob.lsp (to be recreated in branch structure)
      ; - InsertBadge.lsp (to be recreated in branch structure)
      ; - ExtractBadges.lsp (to be recreated in branch structure)
      ; - UpdateBadges.lsp (to be recreated in branch structure)
      ; - CONVERT_CircleToBadge.lsp (to be recreated in branch structure)
      ; - BadgeShortcuts.lsp (to be recreated in branch structure)
      ; - TEST_ListBlocks.lsp (testing utilities in separate branch)
    )
  )
  
  ; Load each file
  (setq load-count 0)
  (foreach file-name file-list
    (setq file-path (strcat base-path file-name))
    
    (princ (strcat "\n  Loading: " file-name))
    
    (if (findfile file-path)
      (progn
        (load file-path)
        (setq load-count (1+ load-count))
        (princ " ... ✓")
      )
      (progn
        (princ " ... ⚠ NOT FOUND")
        ; Try current directory as fallback
        (if (findfile file-name)
          (progn
            (load file-name)
            (setq load-count (1+ load-count))
            (princ " (from current dir)")
          )
        )
      )
    )
  )
  
  ; Calculate load time
  (setq elapsed (- (getvar "MILLISECS") start-time))
  
  ; Report results
  (princ "\n")
  (princ "\n================================================")
  (princ (strcat "\n✓ BADGE SYSTEM LOADED"))
  (princ (strcat "\n  Files: " (itoa load-count) "/" (itoa (length file-list))))
  (princ (strcat "\n  Time: " (rtos (/ elapsed 1000.0) 2 2) " seconds"))
  (princ "\n================================================")
  (princ "\n")
  (princ "\nQuick Start:")
  (princ "\n  CBJ  - Create badges for your job")
  (princ "\n  B    - Quick insert badge")
  (princ "\n  BL   - Create badge legend")
  (princ "\n  BH   - Show help")
  (princ "\n")
  
  ; Return success flag
  (= load-count (length file-list))
)

;;;-----------------------------------------------------
;;; AUTO-EXECUTE ON LOAD
;;;-----------------------------------------------------

(if (load-badge-system)
  (princ "\n✅ Badge System Ready!")
  (progn
    (princ "\n⚠️ Badge System partially loaded")
    (princ "\n  Some files may be missing")
    (princ "\n  Check the base path in LoadBadgeSystem.lsp")
  )
)

;;;-----------------------------------------------------
;;; RELOAD COMMAND
;;;-----------------------------------------------------

(defun C:RELOADBADGES (/)
  "Reload the entire badge system"
  (princ "\nReloading Badge System...")
  
  ; Clear existing data
  (setq *BADGE-LIBRARY-DATA* nil)
  (setq *BADGE-JOB-NAME* nil)
  
  ; Reload
  (if (load-badge-system)
    (princ "\n✓ Badge System reloaded successfully")
    (princ "\n⚠ Reload encountered errors")
  )
  (princ)
)

(princ)
