;;; Load Command Bridge .NET Plugin
;;; Location: rami/autocad/

(defun C:LOADBRIDGE ()
  "Load the Command Bridge .NET plugin"
  (setq plugin-path "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\Command Bridge\\rami\\autocad\\CommandBridgePlugin\\bin\\Release\\net8.0\\FeatureMillwork.CommandBridge.dll")
  
  (if (findfile plugin-path)
    (progn
      (command "NETLOAD" plugin-path)
      (princ "\n✅ Command Bridge Plugin loaded!")
      (princ "\n→ Use TESTBRIDGE to test")
      (princ "\n→ Use BRIDGE-ON / BRIDGE-OFF to control")
    )
    (progn
      (princ "\n⚠️ Plugin DLL not found!")
      (princ (strcat "\nExpected: " plugin-path))
      (princ "\n→ Build the plugin first: dotnet build -c Release")
    )
  )
  (princ)
)

(princ "\n→ Type LOADBRIDGE to load the Command Bridge plugin\n")





