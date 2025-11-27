;;;=====================================================
;;; BadgeSelection.lsp
;;; Badge selection and filtering utilities
;;;
;;; Load Order: After BadgeAttributes.lsp
;;; Required by: ExtractBadges, UpdateBadges
;;;=====================================================

;;;-----------------------------------------------------
;;; SELECTION FILTERS
;;;-----------------------------------------------------

(defun select-all-badges (/ ss)
  "Select all badge blocks in drawing"
  (setq ss (ssget "X" '((0 . "INSERT"))))
  
  ; Filter for actual badge blocks
  (if ss
    (setq ss (filter-badge-blocks ss))
  )
  
  ss
)

(defun select-badges-by-code (badge-code / ss filtered i ent block-name)
  "Select badges with specific code"
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (setq filtered (ssadd))
  
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq block-name (cdr (assoc 2 (entget ent))))
        
        (if (= (strcase block-name) (strcase badge-code))
          (ssadd ent filtered)
        )
        (setq i (1+ i))
      )
    )
  )
  
  (if (> (sslength filtered) 0)
    filtered
    nil
  )
)

(defun select-badges-by-prefix (prefix / ss filtered i ent block-name)
  "Select badges with specific prefix"
  (setq ss (ssget "X" '((0 . "INSERT"))))
  (setq filtered (ssadd))
  (setq prefix (strcase prefix))
  
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq block-name (strcase (cdr (assoc 2 (entget ent)))))
        
        (if (wcmatch block-name (strcat prefix "*"))
          (ssadd ent filtered)
        )
        (setq i (1+ i))
      )
    )
  )
  
  (if (> (sslength filtered) 0)
    filtered
    nil
  )
)

(defun select-badges-in-viewport (/ ll ur ss)
  "Select badges visible in current viewport"
  
  ; Get viewport boundaries
  (if (= (getvar "TILEMODE") 0)  ; In paper space
    (progn
      ; For now, use current view extents
      (setq ll (getvar "VSMIN"))
      (setq ur (getvar "VSMAX"))
    )
    (progn
      ; In model space - use view extents
      (setq ll (getvar "EXTMIN"))
      (setq ur (getvar "EXTMAX"))
    )
  )
  
  ; Select badges within bounds
  (setq ss (ssget "_W" ll ur '((0 . "INSERT"))))
  
  ; Filter for badge blocks
  (if ss
    (setq ss (filter-badge-blocks ss))
  )
  
  ss
)

;;;-----------------------------------------------------
;;; SELECTION FILTERING
;;;-----------------------------------------------------

(defun filter-badge-blocks (ss / filtered i ent)
  "Filter selection set for actual badge blocks"
  (setq filtered (ssadd))
  
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    
    ; Check if it has badge attributes
    (if (is-badge-block ent)
      (ssadd ent filtered)
    )
    
    (setq i (1+ i))
  )
  
  (if (> (sslength filtered) 0)
    filtered
    nil
  )
)

(defun is-badge-block (ent / block-name)
  "Check if entity is a badge block"
  (setq block-name (cdr (assoc 2 (entget ent))))
  
  ; Exclude generic badge template blocks
  (if (wcmatch (strcase block-name) "BADGE_*")
    nil
    ; Check for BADGE_CODE attribute
    (if (get-badge-attribute ent "BADGE_CODE")
      T
      nil
    )
  )
)

;;;-----------------------------------------------------
;;; INTERACTIVE SELECTION
;;;-----------------------------------------------------

(defun C:SELECTBADGES (/ option ss prefix code)
  "Interactive badge selection"
  (princ "\n")
  (princ "\nSelect badges by:")
  (princ "\n  1 - All badges")
  (princ "\n  2 - Badge code")
  (princ "\n  3 - Badge prefix")
  (princ "\n  4 - Window selection")
  (princ "\n  5 - Current viewport")
  
  (setq option (getstring "\n\nChoice (1-5): "))
  
  (cond
    ; All badges
    ((= option "1")
     (setq ss (select-all-badges))
    )
    
    ; By code
    ((= option "2")
     (setq code (getstring "\nBadge code: "))
     (setq ss (select-badges-by-code code))
    )
    
    ; By prefix
    ((= option "3")
     (setq prefix (getstring "\nBadge prefix (PL/PT/SS/ST/APPL/EQ): "))
     (setq ss (select-badges-by-prefix prefix))
    )
    
    ; Window selection
    ((= option "4")
     (princ "\nSelect badges with window...")
     (setq ss (ssget '((0 . "INSERT"))))
     (if ss
       (setq ss (filter-badge-blocks ss))
     )
    )
    
    ; Viewport
    ((= option "5")
     (setq ss (select-badges-in-viewport))
    )
  )
  
  ; Report results
  (if ss
    (progn
      (princ (strcat "\n✓ Selected " (itoa (sslength ss)) " badges"))
      (sssetfirst nil ss)  ; Highlight selection
    )
    (princ "\n⚠ No badges found")
  )
  
  (princ)
)

;;;-----------------------------------------------------
;;; SELECTION ANALYSIS
;;;-----------------------------------------------------

(defun analyze-selection (ss / i ent badge-code badge-list summary cat count)
  "Analyze badge selection and return summary"
  (setq badge-list '())
  (setq summary '())
  
  ; Collect all badge codes
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq badge-code (get-badge-attribute ent "BADGE_CODE"))
    
    (if badge-code
      (setq badge-list (append badge-list (list badge-code)))
    )
    
    (setq i (1+ i))
  )
  
  ; Count by category
  (foreach code badge-list
    (setq cat (get-badge-category code))
    
    (if (setq count (assoc cat summary))
      (setq summary (subst (cons cat (1+ (cdr count))) count summary))
      (setq summary (append summary (list (cons cat 1))))
    )
  )
  
  summary
)

(defun C:ANALYZEBADGES (/ ss summary)
  "Analyze badge composition in drawing"
  (princ "\nAnalyzing badges...")
  
  (setq ss (select-all-badges))
  
  (if ss
    (progn
      (setq summary (analyze-selection ss))
      
      (princ "\n")
      (princ "\n================================================")
      (princ "\n  BADGE ANALYSIS")
      (princ "\n================================================")
      (princ (strcat "\n  Total Badges: " (itoa (sslength ss))))
      (princ "\n")
      (princ "\n  By Category:")
      
      (foreach cat-count summary
        (princ (strcat "\n    " (car cat-count) ": " (itoa (cdr cat-count))))
      )
      
      (princ "\n================================================")
    )
    (princ "\n⚠ No badges found in drawing")
  )
  (princ)
)

;;;-----------------------------------------------------
;;; BATCH SELECTION OPERATIONS  
;;;-----------------------------------------------------

(defun move-selected-badges (ss displacement / i ent)
  "Move all selected badges by displacement"
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (command "._MOVE" ent "" "0,0,0" displacement)
        (setq i (1+ i))
      )
      T
    )
    nil
  )
)

(defun scale-selected-badges (ss scale-factor / i ent ins-pt)
  "Scale all selected badges"
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq ins-pt (cdr (assoc 10 (entget ent))))
        (command "._SCALE" ent "" ins-pt scale-factor)
        (setq i (1+ i))
      )
      T
    )
    nil
  )
)

(defun C:MOVEBADGES (/ ss disp)
  "Move selected badges"
  (princ "\nSelect badges to move...")
  (setq ss (ssget '((0 . "INSERT"))))
  
  (if ss
    (progn
      (setq ss (filter-badge-blocks ss))
      (if ss
        (progn
          (setq disp (getpoint "\nDisplacement: "))
          (if disp
            (progn
              (move-selected-badges ss disp)
              (princ (strcat "\n✓ Moved " (itoa (sslength ss)) " badges"))
            )
          )
        )
        (princ "\n⚠ No badges in selection")
      )
    )
  )
  (princ)
)

(defun C:SCALEBADGES (/ ss scale)
  "Scale selected badges"
  (princ "\nSelect badges to scale...")
  (setq ss (ssget '((0 . "INSERT"))))
  
  (if ss
    (progn
      (setq ss (filter-badge-blocks ss))
      (if ss
        (progn
          (setq scale (getreal "\nScale factor: "))
          (if scale
            (progn
              (scale-selected-badges ss scale)
              (princ (strcat "\n✓ Scaled " (itoa (sslength ss)) " badges"))
            )
          )
        )
        (princ "\n⚠ No badges in selection")
      )
    )
  )
  (princ)
)

;;;-----------------------------------------------------
;;; BADGE COUNTING
;;;-----------------------------------------------------

(defun C:COUNTBADGES (/ ss count-by-code code count)
  "Count badges in drawing"
  (princ "\nCounting badges...")
  
  (setq ss (select-all-badges))
  (setq count-by-code '())
  
  (if ss
    (progn
      ; Count each badge code
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq code (get-badge-attribute ent "BADGE_CODE"))
        
        (if code
          (if (setq count (assoc code count-by-code))
            (setq count-by-code 
                  (subst (cons code (1+ (cdr count))) count count-by-code))
            (setq count-by-code 
                  (append count-by-code (list (cons code 1))))
          )
        )
        (setq i (1+ i))
      )
      
      ; Display results
      (princ "\n")
      (princ "\n================================================")
      (princ "\n  BADGE COUNT")
      (princ "\n================================================")
      (princ (strcat "\n  Total: " (itoa (sslength ss))))
      (princ "\n")
      
      ; Sort and display
      (setq count-by-code 
            (vl-sort count-by-code 
                    '(lambda (a b) (< (car a) (car b)))))
      
      (foreach item count-by-code
        (princ (strcat "\n  " (car item) ": " (itoa (cdr item))))
      )
      
      (princ "\n================================================")
    )
    (princ "\n⚠ No badges found")
  )
  (princ)
)

(princ "\nBadgeSelection.lsp loaded.")
(princ "\nCommands: SELECTBADGES | ANALYZEBADGES | MOVEBADGES | SCALEBADGES | COUNTBADGES")
(princ)
