;;; COMMAND BRIDGE FOR FEATURE MILLWORK
;;; Real-time monitoring via file output
;;; Location: C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\
;;; Ramus: rami/autocad/

(vl-load-com)

;;; Load SAP (file safety) - with error handling
;;; Note: Path relative to Command Bridge root
(setq sap-path "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\Command Bridge\\sap\\file-safety.lsp")
(if (findfile sap-path)
  (progn
    (load sap-path)
    (princ "\n✓ SAP loaded")
  )
  (progn
    (princ "\n⚠️ SAP file not found - using basic file operations")
    ;; Define basic fallback functions if SAP fails to load
    (defun sap-safe-file-open-append (filepath)
      (open filepath "a")
    )
    (defun sap-safe-file-open-write (filepath)
      (open filepath "w")
    )
    (defun sap-safe-file-close (file)
      (if file (close file))
      T
    )
  )
)

;;; Configuration - OneDrive location
(setq *bridge-file* "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\Command Bridge\\Logs\\autocad_bridge.txt")
(setq *bridge-enabled* t)

;;; Write message to bridge file
(defun bridge-write (message)
  "Write a message to the bridge file for monitoring"
  (if *bridge-enabled*
    (progn
      ;; Use SAP for safe file operations
      (setq file (sap-safe-file-open-append *bridge-file*))
      (if file
        (progn
          ;; Write message
          (write-line message file)
          (sap-safe-file-close file)
          ;; Also show in AutoCAD
          (princ (strcat "\n→ " message))
        )
        (princ (strcat "\n⚠️ Cannot write to bridge file"))
      )
    )
  )
)

;;; Clear the bridge file (start fresh)
(defun bridge-clear ()
  "Clear the bridge file for new session"
  ;; Use SAP for safe file operations
  (setq file (sap-safe-file-open-write *bridge-file*))
  (if file
    (progn
      (write-line "=== AUTOCAD SESSION STARTED ===" file)
      (write-line (strcat "Time: " (menucmd "M=$(edtime,$(getvar,date),YYYY-MON-DD HH:MM:SS)")) file)
      (write-line (strcat "Drawing: " (getvar "DWGNAME")) file)
      (sap-safe-file-close file)
      (princ "\n✅ Bridge file cleared")
    )
  )
)

;;; Test the bridge connection
(defun c:TEST ()
  "Test the Command Bridge connection"
  (princ "\n✅ Command Bridge is active")
  (princ "\n→ Type MONITOR-ON to enable command tracking")
  (princ "\n→ Then run any AutoCAD command to see it in the monitor")
  ;; Write test messages to bridge file
  (bridge-write "TEST: Command Bridge connection test")
  (bridge-write "TEST: If you see this, monitoring is working!")
  (bridge-write "SUCCESS: Test complete")
  (princ)
)

;;; Monitor all commands - capture command names and results
(defun log-command-start (reactor params)
  "Log when command starts"
  (setq cmd (car params))
  (if (and *bridge-enabled* cmd)
    (progn
      ;; Only log non-internal commands
      (if (not (member cmd '("'ZOOM" "'PAN" "'REDRAW" "TEXTSCR" "GRAPHSCR")))
        (bridge-write (strcat "→ Command: " (strcase cmd)))
      )
    )
  )
)

(defun log-command-end (reactor params)
  "Log when command ends successfully"
  (setq cmd (car params))
  (if (and *bridge-enabled* cmd)
    (bridge-write (strcat "✓ Command completed: " (strcase cmd)))
  )
)

(defun log-command-cancelled (reactor params)
  "Log when command is cancelled"
  (setq cmd (car params))
  (if (and *bridge-enabled* cmd)
    (bridge-write (strcat "→ Command cancelled: " (strcase cmd)))
  )
)

(defun log-command-failed (reactor params)
  "Log when command fails"
  (setq cmd (car params))
  (if (and *bridge-enabled* cmd)
    (bridge-write (strcat "⚠ Command failed: " (strcase cmd)))
  )
)

;;; Enable command monitoring
(defun c:MONITOR-ON ()
  "Enable command monitoring - captures all command activity"
  (if (not *command-reactor*)
    (progn
      (setq *command-reactor*
        (vlr-command-reactor nil
          '((:vlr-commandWillStart . log-command-start)
            (:vlr-commandEnded . log-command-end)
            (:vlr-commandCancelled . log-command-cancelled)
            (:vlr-commandFailed . log-command-failed))))
      (setq *bridge-enabled* t)
      (princ "\n✅ Command monitoring enabled")
      (princ "\n→ All commands will now be logged to monitor")
      (bridge-write "MONITOR: Command monitoring ENABLED - all commands will be logged")
    )
    (princ "\n⚠️ Monitoring already active")
  )
  (princ)
)

;;; Disable monitoring
(defun c:MONITOR-OFF ()
  "Disable command monitoring"
  (if *command-reactor*
    (progn
      (vlr-remove *command-reactor*)
      (setq *command-reactor* nil)
      (setq *bridge-enabled* nil)
      (bridge-write "MONITOR: Command monitoring DISABLED")
      (princ "\n✅ Command monitoring disabled")
    )
    (princ "\n⚠️ Monitoring not active")
  )
  (princ)
)


;;; Capture command line output using a text reactor
;;; Note: AutoLISP cannot directly capture command line text, but we can
;;; use a reactor to capture princ output and format STATUS manually
(defun capture-status-output ()
  "Capture and format STATUS command output"
  (setq ss (ssget "_X"))
  (setq obj-count (if ss (sslength ss) 0))
  
  (bridge-write (strcat "STATUS: " (itoa obj-count) " objects in " (getvar "DWGNAME")))
  (bridge-write (strcat "STATUS: Undo file size: " (rtos (getvar "UNDOCTL") 2 0) " Bytes"))
  
  (setq limmin (getvar "LIMMIN"))
  (setq limmax (getvar "LIMMAX"))
  (bridge-write (strcat "STATUS: Model space limits are X: " (rtos (car limmin) 2 4) " Y: " (rtos (cadr limmin) 2 4) " (Off)"))
  (bridge-write (strcat "STATUS:                        X: " (rtos (car limmax) 2 4) " Y: " (rtos (cadr limmax) 2 4)))
  
  (setq extmin (getvar "EXTMIN"))
  (setq extmax (getvar "EXTMAX"))
  (if (and extmin extmax)
    (progn
      (bridge-write (strcat "STATUS: Model space uses       X: " (rtos (car extmin) 2 4) " Y: " (rtos (cadr extmin) 2 4)))
      (bridge-write (strcat "STATUS:                         X: " (rtos (car extmax) 2 4) " Y: " (rtos (cadr extmax) 2 4)))
    )
    (bridge-write "STATUS: Model space uses       *Nothing*")
  )
  
  (setq viewctr (getvar "VIEWCTR"))
  (setq viewsize (getvar "VIEWSIZE"))
  (bridge-write (strcat "STATUS: Display shows          X: " (rtos (- (car viewctr) (/ viewsize 2.0)) 2 4) " Y: " (rtos (- (cadr viewctr) (/ viewsize 2.0)) 2 4)))
  (bridge-write (strcat "STATUS:                         X: " (rtos (+ (car viewctr) (/ viewsize 2.0)) 2 4) " Y: " (rtos (+ (cadr viewctr) (/ viewsize 2.0)) 2 4)))
  
  (setq insbase (getvar "INSBASE"))
  (bridge-write (strcat "STATUS: Insertion base is      X: " (rtos (car insbase) 2 4) " Y: " (rtos (cadr insbase) 2 4) " Z: " (rtos (caddr insbase) 2 4)))
  
  (setq snapunit (getvar "SNAPUNIT"))
  (bridge-write (strcat "STATUS: Snap resolution is     X: " (rtos (car snapunit) 2 4) " Y: " (rtos (cadr snapunit) 2 4)))
  
  (setq gridunit (getvar "GRIDUNIT"))
  (bridge-write (strcat "STATUS: Grid spacing is         X: " (rtos (car gridunit) 2 4) " Y: " (rtos (cadr gridunit) 2 4)))
  
  (bridge-write (strcat "STATUS: Current space:        " (if (= (getvar "TILEMODE") 1) "Model space" "Paper space")))
  (bridge-write (strcat "STATUS: Current layout:       " (getvar "CTAB")))
  (bridge-write (strcat "STATUS: Current layer:        \"" (getvar "CLAYER") "\""))
  (bridge-write (strcat "STATUS: Current color:        " (if (= (getvar "CECOLOR") "BYLAYER") "BYLAYER" (getvar "CECOLOR"))))
  (bridge-write (strcat "STATUS: Current linetype:     BYLAYER -- \"" (getvar "CELTYPE") "\""))
  (bridge-write (strcat "STATUS: Current lineweight:   BYLAYER"))
  (bridge-write (strcat "STATUS: Current elevation:    " (rtos (getvar "ELEVATION") 2 4) " thickness: " (rtos (getvar "THICKNESS") 2 4)))
  
  (setq fillmode (if (= (getvar "FILLMODE") 1) "on" "off"))
  (setq gridmode (if (= (getvar "GRIDMODE") 1) "on" "off"))
  (setq orthomode (if (= (getvar "ORTHOMODE") 1) "on" "off"))
  (setq qtextmode (if (= (getvar "TEXTFILL") 1) "off" "on"))
  (setq snapmode (if (= (getvar "SNAPMODE") 1) "on" "off"))
  (bridge-write (strcat "STATUS: Fill " fillmode "  Grid " gridmode "  Ortho " orthomode "  Qtext " qtextmode "  Snap " snapmode "  Tablet off"))
  
  (setq osmode (getvar "OSMODE"))
  (if (= osmode 0)
    (bridge-write "STATUS: Object snap modes:    None")
    (bridge-write (strcat "STATUS: Object snap modes:    " (itoa osmode)))
  )
  
  (bridge-write "STATUS: Press ENTER to continue:")
  
  (setq free-disk (getvar "DISKUSAGE"))
  (bridge-write (strcat "STATUS: Free dwg disk (C:) space: " (rtos (/ free-disk 1024.0 1024.0 1024.0) 2 1) " GBytes"))
  (bridge-write (strcat "STATUS: Free temp disk (C:) space: " (rtos (/ free-disk 1024.0 1024.0 1024.0) 2 1) " GBytes"))
  
  (setq memused (getvar "MEMUSED"))
  (setq memtotal (getvar "MEMTOTAL"))
  (bridge-write (strcat "STATUS: Free physical memory: " (rtos (/ memused 1024.0 1024.0) 2 1) " GBytes (out of " (rtos (/ memtotal 1024.0 1024.0) 2 1) " GBytes)."))
  
  (bridge-write "STATUS: Automatic save to ...")
)

;;; Show status - capture AutoCAD STATUS output
(defun c:STATUS ()
  "Show Command Bridge status and capture AutoCAD STATUS output"
  (princ "\n\n========== COMMAND BRIDGE STATUS ==========")
  (princ (strcat "\n  Bridge File: " *bridge-file*))
  (princ (strcat "\n  Monitoring: " (if *bridge-enabled* "ENABLED" "DISABLED")))
  (princ (strcat "\n  Reactor: " (if *command-reactor* "INSTALLED" "NOT INSTALLED")))
  
  ;; Check if file exists
  (if (findfile *bridge-file*)
    (princ "\n  File Status: EXISTS")
    (princ "\n  File Status: NOT FOUND - Will be created")
  )
  
  (princ "\n============================================")
  (bridge-write "STATUS: Command Bridge status checked")
  
  ;; Capture STATUS output to bridge
  (bridge-write "STATUS: === AutoCAD STATUS Command Output ===")
  (capture-status-output)
  
  ;; Also run AutoCAD's built-in STATUS to show in AutoCAD
  (princ "\n\nRunning AutoCAD STATUS command...\n")
  (command "._STATUS")
  
  (bridge-write "STATUS: === End of STATUS output ===")
  (princ)
)

;;; Initialize - enable monitoring by default
(bridge-clear)
(bridge-write "=== COMMAND BRIDGE LOADED ===")

;;; Auto-enable command monitoring on load
(if (not *command-reactor*)
  (progn
    (setq *command-reactor*
      (vlr-command-reactor nil
        '((:vlr-commandWillStart . log-command-start)
          (:vlr-commandEnded . log-command-end)
          (:vlr-commandCancelled . log-command-cancelled)
          (:vlr-commandFailed . log-command-failed))))
    (setq *bridge-enabled* t)
  )
)

(princ "\n\n")
(princ "╔════════════════════════════════════════════╗\n")
(princ "║   COMMAND BRIDGE - FEATURE MILLWORK       ║\n")
(princ "╠════════════════════════════════════════════╣\n")
(princ "║  TEST         - Test connection           ║\n")
(princ "║                                            ║\n")
(princ "║  MONITOR-ON   - Track all commands        ║\n")
(princ "║  MONITOR-OFF  - Stop tracking             ║\n")
(princ "║  STATUS       - Check bridge status       ║\n")
(princ "╚════════════════════════════════════════════╝\n")
(princ "\n")
(princ)
