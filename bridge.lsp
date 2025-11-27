;;; AutoCAD Command Line Bridge - LISP Component
;;; This monitors AutoCAD command line and sends to VS Code
;;; Works without needing .NET compilation

(vl-load-com)

;; Global variables
(setq *bridge-active* nil)
(setq *bridge-log-file* "C:\\temp\\autocad-bridge.log")
(setq *bridge-buffer* '())
(setq *bridge-last-error* nil)

;; Start the command bridge
(defun c:STARTBRIDGE ()
  (if *bridge-active*
    (princ "\nCommand Bridge is already running.")
    (progn
      ;; Create log file
      (setq *bridge-log-file* 
        (strcat (getenv "TEMP") "\\autocad-bridge-" 
                (menucmd "M=$(edtime,0,YYYYMODD-HHMMSS)") ".log"))
      
      ;; Install reactor callbacks
      (install-bridge-reactors)
      
      (setq *bridge-active* T)
      (bridge-log "CONNECTED" "Bridge started")
      (princ (strcat "\nCommand Bridge started. Logging to: " *bridge-log-file*))
    )
  )
  (princ)
)

;; Stop the command bridge  
(defun c:STOPBRIDGE ()
  (if (not *bridge-active*)
    (princ "\nCommand Bridge is not running.")
    (progn
      (remove-bridge-reactors)
      (bridge-log "DISCONNECTED" "Bridge stopped")
      (setq *bridge-active* nil)
      (princ "\nCommand Bridge stopped.")
    )
  )
  (princ)
)

;; Install reactor callbacks
(defun install-bridge-reactors ()
  ;; Command reactors
  (setq *bridge-cmd-reactor*
    (vlr-command-reactor nil
      '((:vlr-commandWillStart . bridge-cmd-start)
        (:vlr-commandEnded . bridge-cmd-end)
        (:vlr-commandCancelled . bridge-cmd-cancel)
        (:vlr-commandFailed . bridge-cmd-failed))))
  
  ;; LISP reactors
  (setq *bridge-lisp-reactor*
    (vlr-lisp-reactor nil
      '((:vlr-lispWillStart . bridge-lisp-start)
        (:vlr-lispEnded . bridge-lisp-end)
        (:vlr-lispCancelled . bridge-lisp-cancel))))
  
  ;; Editor reactor for errors
  (setq *bridge-editor-reactor*
    (vlr-editor-reactor nil
      '((:vlr-unknownCommand . bridge-unknown-cmd))))
  
  ;; Error handler
  (setq *error-original* *error*)
  (defun *error* (msg)
    (if *bridge-active*
      (bridge-log "ERROR" msg))
    (if *error-original*
      (*error-original* msg))
  )
)
;; Remove reactor callbacks
(defun remove-bridge-reactors ()
  (if *bridge-cmd-reactor*
    (vlr-remove *bridge-cmd-reactor*))
  (if *bridge-lisp-reactor*
    (vlr-remove *bridge-lisp-reactor*))
  (if *bridge-editor-reactor*
    (vlr-remove *bridge-editor-reactor*))
  
  ;; Restore original error handler
  (if *error-original*
    (setq *error* *error-original*))
)

;; Reactor callback functions
(defun bridge-cmd-start (reactor params)
  (bridge-log "CMD_START" (car params))
)

(defun bridge-cmd-end (reactor params)
  (bridge-log "CMD_END" (car params))
)

(defun bridge-cmd-cancel (reactor params)
  (bridge-log "CMD_CANCEL" (car params))
)

(defun bridge-cmd-failed (reactor params)
  (bridge-log "CMD_FAILED" (car params))
)

(defun bridge-lisp-start (reactor params)
  (bridge-log "LISP_START" (car params))
)

(defun bridge-lisp-end (reactor params)
  (bridge-log "LISP_END" "completed")
)

(defun bridge-lisp-cancel (reactor params)
  (bridge-log "LISP_CANCEL" "cancelled")
)

(defun bridge-unknown-cmd (reactor params)
  (bridge-log "UNKNOWN_CMD" (car params))
)
;; Log to file with JSON format for VS Code
(defun bridge-log (event-type message / file timestamp json)
  (setq timestamp (menucmd "M=$(edtime,0,YYYY-MM-DD HH:MM:SS)"))
  
  ;; Build JSON object
  (setq json (strcat 
    "{"
    "\"type\":\"" event-type "\","
    "\"message\":\"" (escape-json message) "\","
    "\"timestamp\":\"" timestamp "\","
    "\"drawing\":\"" (getvar "DWGNAME") "\""
    "}"))
  
  ;; Write to file
  (if (setq file (open *bridge-log-file* "a"))
    (progn
      (write-line json file)
      (close file)
    )
  )
  
  ;; Also print to command line if verbose
  (if (= (getvar "CMDECHO") 1)
    (princ (strcat "\n[BRIDGE] " event-type ": " message)))
)

;; Escape special characters for JSON
(defun escape-json (str / result i char)
  (setq result "")
  (setq i 1)
  (repeat (strlen str)
    (setq char (substr str i 1))
    (cond
      ((= char "\"") (setq result (strcat result "\\\"")))
      ((= char "\\") (setq result (strcat result "\\\\")))
      ((= char "\n") (setq result (strcat result "\\n")))
      ((= char "\r") (setq result (strcat result "\\r")))
      ((= char "\t") (setq result (strcat result "\\t")))
      (T (setq result (strcat result char)))
    )
    (setq i (1+ i))
  )
  result
)
;; Execute code and capture output
(defun c:BRIDGE-EXEC (/ code)
  (setq code (getstring T "\nEnter LISP expression: "))
  (if code
    (progn
      (bridge-log "EXEC" code)
      (vl-catch-all-apply 'eval (list (read code)))
    )
  )
  (princ)
)

;; Test the bridge connection
(defun c:TESTBRIDGE ()
  (if (not *bridge-active*)
    (princ "\nCommand Bridge is not running. Use STARTBRIDGE first.")
    (progn
      (bridge-log "TEST" "Test message from AutoCAD")
      (princ "\nTest message sent to log file.")
      (princ (strcat "\nLog file: " *bridge-log-file*))
    )
  )
  (princ)
)

;; Monitor specific system variables
(defun c:BRIDGE-MONITOR (/ vars)
  (setq vars '("CMDECHO" "DIMSCALE" "LTSCALE" "OSMODE" "ORTHOMODE"))
  (foreach var vars
    (bridge-log "SYSVAR" (strcat var "=" (vl-princ-to-string (getvar var))))
  )
  (princ "\nSystem variables logged.")
  (princ)
)

;; Clear the log file
(defun c:BRIDGE-CLEAR ()
  (if (findfile *bridge-log-file*)
    (progn
      (vl-file-delete *bridge-log-file*)
      (princ "\nLog file cleared.")
    )
    (princ "\nNo log file found.")
  )
  (princ)
)

;; Show bridge status
(defun c:BRIDGE-STATUS ()
  (princ "\n=== AutoCAD Command Bridge Status ===")
  (princ (strcat "\nActive: " (if *bridge-active* "YES" "NO")))
  (princ (strcat "\nLog file: " *bridge-log-file*))
  (if (findfile *bridge-log-file*)
    (princ (strcat "\nLog size: " 
      (itoa (vl-file-size *bridge-log-file*)) " bytes"))
    (princ "\nLog file not found")
  )
  (princ "\n=====================================")
  (princ)
)

(princ "\n=== AutoCAD Command Bridge Loaded ===")
(princ "\nCommands:")
(princ "\n  STARTBRIDGE   - Start monitoring")
(princ "\n  STOPBRIDGE    - Stop monitoring")
(princ "\n  TESTBRIDGE    - Test connection")
(princ "\n  BRIDGE-STATUS - Show status")
(princ "\n  BRIDGE-CLEAR  - Clear log file")
(princ "\n=====================================\n")