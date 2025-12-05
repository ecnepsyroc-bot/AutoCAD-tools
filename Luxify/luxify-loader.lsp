;; Luxify mOS Auto-Loader
;; Automatically loads all Luxify .NET plugins

(defun c:LuxifyLoad ()
  (princ "\nLoading Luxify mOS...")
  
  ;; Define the root path - ADJUST THIS IF NEEDED
  (setq rootPath "c:\\Dev\\AutoCAD-tools\\Luxify\\")
  
  ;; List of DLLs to load (Order matters if dependencies exist, but usually Core first)
  (setq dlls '(
    "Luxify.Core\\bin\\Debug\\net8.0-windows\\Luxify.Core.dll"
    "Luxify.Badging\\bin\\Debug\\net8.0-windows\\Luxify.Badging.dll"
    "Luxify.Layout\\bin\\Debug\\net8.0-windows\\Luxify.Layout.dll"
    "Luxify.Legends\\bin\\Debug\\net8.0-windows\\Luxify.Legends.dll"
    "Luxify.Plotting\\bin\\Debug\\net8.0-windows\\Luxify.Plotting.dll"
    "Luxify.Labeling\\bin\\Debug\\net8.0-windows\\Luxify.Labeling.dll"
  ))

  (foreach dll dlls
    (setq fullPath (strcat rootPath dll))
    (if (findfile fullPath)
      (progn
        (command "NETLOAD" fullPath)
        (princ (strcat "\nLoaded: " dll))
      )
      (princ (strcat "\nERROR: Could not find " fullPath))
    )
  )
  
  (princ "\nLuxify mOS Loaded Successfully.")
  (princ)
)

;; Auto-run on load
(c:LuxifyLoad)
