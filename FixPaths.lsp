(defun c:FixPaths (/ acadObj prefObj filesObj currentSupportPath newSupportPath currentTrustedPath newTrustedPath vaultPath iconPath trustedVaultPath)
  (vl-load-com)
  (setq acadObj (vlax-get-acad-object))
  (setq prefObj (vla-get-preferences acadObj))
  (setq filesObj (vla-get-files prefObj))

  ;; Define paths
  (setq vaultPath "C:\\Users\\cory\\OneDrive\\DWG AIDS\\vault")
  (setq iconPath "C:\\Users\\cory\\OneDrive\\DWG AIDS\\vault\\Icons")
  (setq trustedVaultPath "C:\\Users\\cory\\OneDrive\\DWG AIDS\\vault\\...")

  ;; --- Support Paths ---
  ;; Using vlax-get-property to avoid wrapper function issues
  (setq currentSupportPath (vlax-get-property filesObj 'SupportPath))
  
  ;; Append vaultPath if missing
  (if (not (vl-string-search (strcase vaultPath) (strcase currentSupportPath)))
    (setq currentSupportPath (strcat currentSupportPath ";" vaultPath))
  )
  
  ;; Append iconPath if missing
  (if (not (vl-string-search (strcase iconPath) (strcase currentSupportPath)))
    (setq currentSupportPath (strcat currentSupportPath ";" iconPath))
  )
  
  (vlax-put-property filesObj 'SupportPath currentSupportPath)

  ;; --- Trusted Paths ---
  ;; Check availability first to avoid errors if the property is missing or wrapper failed
  (if (vlax-property-available-p filesObj 'TrustedPaths)
    (progn
      (setq currentTrustedPath (vlax-get-property filesObj 'TrustedPaths))
      
      ;; Append trustedVaultPath if missing
      (if (not (vl-string-search (strcase trustedVaultPath) (strcase currentTrustedPath)))
        (if (= currentTrustedPath "")
            (setq currentTrustedPath trustedVaultPath)
            (setq currentTrustedPath (strcat currentTrustedPath ";" trustedVaultPath))
        )
      )
      
      (vlax-put-property filesObj 'TrustedPaths currentTrustedPath)
    )
    (princ "\nWARNING: TrustedPaths property not available. Skipping.")
  )

  (princ "\nSUCCESS: Legacy paths and Icons have been registered. Please Restart AutoCAD.")
  (princ)
)

;; Execute immediately upon loading
(c:FixPaths)
