;;; ============================================
;;; AutoCAD Command Bridge - Test Suite
;;; ============================================
;;; Tests the command bridge monitoring capabilities
;;; Run with Ctrl+Shift+E in VS Code

(vl-load-com)

;;; Test 1: Basic command execution tracking
(defun c:TEST1 ()
  (princ "\n=== Test 1: Basic Command Tracking ===")
  (command "LINE" "0,0" "100,100" "")
  (command "CIRCLE" "50,50" "25")
  (princ "\nCheck monitor panel for command timings")
  (princ)
)

;;; Test 2: Error generation for pattern detection
(defun c:TEST2 ()
  (princ "\n=== Test 2: Error Pattern Detection ===")
  ;; This will generate various errors
  (vl-catch-all-apply 'non-existent-function nil)
  (vl-catch-all-apply 'strcat '(123 456)) ; bad argument type
  (vl-catch-all-apply 'car '()) ; null list
  (princ "\nCheck monitor panel for error patterns")
  (princ)
)

;;; Test 3: Performance testing
(defun c:TEST3 ()
  (princ "\n=== Test 3: Performance Metrics ===")
  (setq start-time (getvar "MILLISECS"))
  
  ;; Create 100 lines quickly
  (repeat 100
    (command "LINE" 
      (list (* (random 1000) 1.0) (* (random 1000) 1.0))
      (list (* (random 1000) 1.0) (* (random 1000) 1.0))
      "")
  )
  
  (setq elapsed (- (getvar "MILLISECS") start-time))
  (princ (strcat "\nCreated 100 lines in " (itoa elapsed) "ms"))
  (princ "\nCheck monitor panel for commands/minute rate")
  (princ)
)
;;; Test 4: Badge system simulation
(defun c:TEST4 ()
  (princ "\n=== Test 4: Badge System Simulation ===")
  
  ;; Simulate badge detection patterns
  (defun detect-badge-type (entity-name)
    (cond
      ((wcmatch entity-name "*CIRCLE*") "PL")   ; Plastic Laminate
      ((wcmatch entity-name "*RECT*") "MV")     ; Veneer
      ((wcmatch entity-name "*DIAMOND*") "PT")  ; Paint
      ((wcmatch entity-name "*STAR*") "MW")     ; Millwork
      (t "UNKNOWN")
    ))
  
  ;; Test badge detection with timing
  (setq badges '("CIRCLE-001" "RECT-002" "DIAMOND-003" "STAR-004" "HEXAGON-005"))
  
  (foreach badge badges
    (setq badge-type (detect-badge-type badge))
    (princ (strcat "\nBadge " badge " detected as: " badge-type))
  )
  
  (princ "\nMonitor shows badge processing performance")
  (princ)
)

;;; Test 5: System variable monitoring
(defun c:TEST5 ()
  (princ "\n=== Test 5: System Variable Tracking ===")
  
  ;; Get and set various system variables
  (setq vars '("OSMODE" "ORTHOMODE" "GRIDMODE" "SNAPMODE"))
  
  (foreach var vars
    (setq current-val (getvar var))
    (princ (strcat "\n" var " = " (itoa current-val)))
    
    ;; Toggle the value
    (setvar var (if (= current-val 0) 1 0))
    (princ " → toggled")
    
    ;; Restore
    (setvar var current-val)
  )
  
  (princ "\nCheck VS Code output for sysvar messages")
  (princ)
)
;;; Test 6: Stress test for monitoring
(defun c:STRESS ()
  (princ "\n=== Stress Testing Monitor ===")
  (princ "\nThis will generate 1000 commands rapidly...")
  
  (setq start-time (getvar "MILLISECS"))
  (setq error-count 0)
  
  (repeat 1000
    ;; Mix of successful and failing commands
    (if (> (random 10) 7)
      ;; Generate an error occasionally
      (progn
        (vl-catch-all-apply 'bad-function nil)
        (setq error-count (1+ error-count))
      )
      ;; Normal command
      (command "POINT" (list (random 100) (random 100)))
    )
  )
  
  (setq elapsed (- (getvar "MILLISECS") start-time))
  (princ (strcat "\n1000 operations in " (itoa elapsed) "ms"))
  (princ (strcat "\nErrors generated: " (itoa error-count)))
  (princ "\nCheck monitor panel for statistics!")
  (princ)
)

;;; Main test runner
(defun c:TESTALL ()
  (princ "\n========================================")
  (princ "\n  AUTOCAD COMMAND BRIDGE TEST SUITE")
  (princ "\n========================================")
  (princ "\nMake sure VS Code monitor panel is open!")
  (princ "\nPress Ctrl+Shift+M in VS Code\n")
  
  (getstring "\nPress Enter to start tests...")
  
  (c:TEST1) (getstring "\nPress Enter for next test...")
  (c:TEST2) (getstring "\nPress Enter for next test...")
  (c:TEST3) (getstring "\nPress Enter for next test...")
  (c:TEST4) (getstring "\nPress Enter for next test...")
  (c:TEST5) (getstring "\nPress Enter for stress test...")
  (c:STRESS)
  
  (princ "\n\n=== All tests complete! ===")
  (princ "\nCheck the VS Code monitor panel for:")
  (princ "\n- Command execution times")
  (princ "\n- Error patterns and frequencies")
  (princ "\n- Performance metrics")
  (princ "\n- Session statistics")
  (princ)
)

(princ "\n=== Command Bridge Test Suite Loaded ===")
(princ "\nCommands available:")
(princ "\n  TEST1 - Basic command tracking")
(princ "\n  TEST2 - Error pattern detection")
(princ "\n  TEST3 - Performance metrics")
(princ "\n  TEST4 - Badge system simulation")
(princ "\n  TEST5 - System variable tracking")
(princ "\n  STRESS - Stress test (1000 operations)")
(princ "\n  TESTALL - Run all tests")
(princ "\n")
(princ)