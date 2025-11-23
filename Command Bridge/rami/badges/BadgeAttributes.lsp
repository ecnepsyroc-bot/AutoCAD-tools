;;;=====================================================
;;; BadgeAttributes.lsp
;;; Badge attribute management and manipulation
;;;
;;; Load Order: After BadgeUtils.lsp
;;; Required by: InsertBadge, UpdateBadges, ExtractBadges
;;;=====================================================

;;;-----------------------------------------------------
;;; ATTRIBUTE TAGS DEFINITION
;;;-----------------------------------------------------

(defun get-badge-attribute-tags ()
  "Return list of standard badge attribute tags"
  '("BADGE_CODE" "CATEGORY" "DESCRIPTION" "MATERIAL" "SUPPLIER" "ISSUE_NOTES")
)

;;;-----------------------------------------------------
;;; ATTRIBUTE READING
;;;-----------------------------------------------------

(defun read-badge-attributes (ent / att-ent att-data att-list tag value)
  "Read all attributes from a badge block entity"
  (setq att-list '())
  
  ; Get first attribute
  (setq att-ent (entnext ent))
  
  ; Loop through all attributes
  (while (and att-ent 
              (= "ATTRIB" (cdr (assoc 0 (entget att-ent)))))
    (setq att-data (entget att-ent))
    (setq tag (cdr (assoc 2 att-data)))      ; Attribute tag
    (setq value (cdr (assoc 1 att-data)))    ; Attribute value
    
    ; Add to list as (tag . value) pair
    (setq att-list (append att-list (list (cons tag value))))
    
    ; Get next attribute
    (setq att-ent (entnext att-ent))
  )
  
  att-list
)

;;;-----------------------------------------------------
;;; ATTRIBUTE WRITING
;;;-----------------------------------------------------

(defun write-badge-attributes (ent att-list / att-ent att-data tag new-value)
  "Write attributes to a badge block entity"
  
  ; Get first attribute
  (setq att-ent (entnext ent))
  
  ; Loop through all attributes
  (while (and att-ent 
              (= "ATTRIB" (cdr (assoc 0 (entget att-ent)))))
    (setq att-data (entget att-ent))
    (setq tag (cdr (assoc 2 att-data)))
    
    ; Find new value for this tag
    (setq new-value (cdr (assoc tag att-list)))
    
    (if new-value
      (progn
        ; Update the attribute value
        (setq att-data (subst (cons 1 new-value) 
                             (assoc 1 att-data) 
                             att-data))
        (entmod att-data)
      )
    )
    
    ; Get next attribute
    (setq att-ent (entnext att-ent))
  )
  
  ; Update the block
  (entupd ent)
  
  T
)

;;;-----------------------------------------------------
;;; SINGLE ATTRIBUTE OPERATIONS
;;;-----------------------------------------------------

(defun get-badge-attribute (ent tag / att-ent att-data att-tag value found)
  "Get single attribute value from badge"
  (setq att-ent (entnext ent)
        found nil
        value nil)
  
  (while (and att-ent 
              (not found)
              (= "ATTRIB" (cdr (assoc 0 (entget att-ent)))))
    (setq att-data (entget att-ent))
    (setq att-tag (cdr (assoc 2 att-data)))
    
    (if (= (strcase att-tag) (strcase tag))
      (progn
        (setq value (cdr (assoc 1 att-data)))
        (setq found T)
      )
    )
    
    (if (not found)
      (setq att-ent (entnext att-ent))
    )
  )
  
  value
)

(defun set-badge-attribute (ent tag new-value / att-ent att-data att-tag updated)
  "Set single attribute value in badge"
  (setq att-ent (entnext ent)
        updated nil)
  
  (while (and att-ent 
              (not updated)
              (= "ATTRIB" (cdr (assoc 0 (entget att-ent)))))
    (setq att-data (entget att-ent))
    (setq att-tag (cdr (assoc 2 att-data)))
    
    (if (= (strcase att-tag) (strcase tag))
      (progn
        ; Update the attribute
        (setq att-data (subst (cons 1 new-value) 
                             (assoc 1 att-data) 
                             att-data))
        (entmod att-data)
        (setq updated T)
      )
    )
    
    (if (not updated)
      (setq att-ent (entnext att-ent))
    )
  )
  
  (if updated
    (entupd ent)
  )
  
  updated
)

;;;-----------------------------------------------------
;;; ATTRIBUTE VISIBILITY
;;;-----------------------------------------------------

(defun set-badge-attributes-visible (ent visible / att-ent att-data)
  "Set visibility of all attributes in badge"
  (setq att-ent (entnext ent))
  
  (while (and att-ent 
              (= "ATTRIB" (cdr (assoc 0 (entget att-ent)))))
    (setq att-data (entget att-ent))
    
    ; Set visibility (60 = invisible flag)
    (if visible
      ; Make visible - remove code 60
      (if (assoc 60 att-data)
        (setq att-data (vl-remove (assoc 60 att-data) att-data))
      )
      ; Make invisible - add code 60
      (if (not (assoc 60 att-data))
        (setq att-data (append att-data '((60 . 1))))
      )
    )
    
    (entmod att-data)
    (setq att-ent (entnext att-ent))
  )
  
  (entupd ent)
  T
)

;;;-----------------------------------------------------
;;; BADGE DATA MAPPING
;;;-----------------------------------------------------

(defun map-csv-to-attributes (csv-fields)
  "Map CSV fields to attribute list"
  ; CSV format: BADGE_CODE,CATEGORY,DESCRIPTION,MATERIAL,SUPPLIER,ISSUE_NOTES
  (list
    (cons "BADGE_CODE"   (nth 0 csv-fields))
    (cons "CATEGORY"     (nth 1 csv-fields))
    (cons "DESCRIPTION"  (nth 2 csv-fields))
    (cons "MATERIAL"     (nth 3 csv-fields))
    (cons "SUPPLIER"     (nth 4 csv-fields))
    (cons "ISSUE_NOTES"  (if (>= (length csv-fields) 6) (nth 5 csv-fields) ""))
  )
)

(defun map-attributes-to-csv (att-list)
  "Map attribute list to CSV fields"
  (list
    (cdr (assoc "BADGE_CODE" att-list))
    (cdr (assoc "CATEGORY" att-list))
    (cdr (assoc "DESCRIPTION" att-list))
    (cdr (assoc "MATERIAL" att-list))
    (cdr (assoc "SUPPLIER" att-list))
    (cdr (assoc "ISSUE_NOTES" att-list))
  )
)

;;;-----------------------------------------------------
;;; BADGE VALIDATION
;;;-----------------------------------------------------

(defun validate-badge-block (block-name / block-def att-def valid tags-found required-tags ent ent-data)
  "Validate that block has required badge attributes"
  (setq valid T)
  (setq tags-found '())
  (setq required-tags '("BADGE_CODE" "DESCRIPTION"))
  
  ; Check if block exists
  (if (not (tblsearch "BLOCK" block-name))
    (progn
      (princ (strcat "\n⚠ Block not found: " block-name))
      (setq valid nil)
    )
    (progn
      ; Get block definition
      (setq block-def (tblsearch "BLOCK" block-name))
      (setq ent (cdr (assoc -2 block-def)))
      
      ; Check for attribute definitions
      (while ent
        (setq ent-data (entget ent))
        (if (= "ATTDEF" (cdr (assoc 0 ent-data)))
          (setq tags-found (append tags-found 
                                  (list (cdr (assoc 2 ent-data)))))
        )
        (setq ent (entnext ent))
      )
      
      ; Check for required tags
      (foreach tag required-tags
        (if (not (member (strcase tag) (mapcar 'strcase tags-found)))
          (progn
            (princ (strcat "\n⚠ Missing required attribute: " tag))
            (setq valid nil)
          )
        )
      )
    )
  )
  
  valid
)

;;;-----------------------------------------------------
;;; ATTRIBUTE SYNCHRONIZATION
;;;-----------------------------------------------------

(defun sync-badge-attributes (ent badge-data / att-list)
  "Synchronize badge attributes with library data"
  
  ; Create attribute list from badge data
  (setq att-list (map-csv-to-attributes badge-data))
  
  ; Write attributes to badge
  (write-badge-attributes ent att-list)
  
  T
)

;;;-----------------------------------------------------
;;; BATCH ATTRIBUTE OPERATIONS
;;;-----------------------------------------------------

(defun C:FIXALLBADGES (/ ss i ent block-name count)
  "Fix attribute visibility for all badges"
  (princ "\nFixing all badge attributes...")
  
  (setq ss (ssget "X" '((0 . "INSERT")))
        count 0)
  
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq block-name (cdr (assoc 2 (entget ent))))
        
        ; Check if it's a badge block
        (if (and block-name
                 (not (wcmatch (strcase block-name) "BADGE_*"))
                 (get-badge-attribute ent "BADGE_CODE"))
          (progn
            (set-badge-attributes-visible ent T)
            (setq count (1+ count))
          )
        )
        (setq i (1+ i))
      )
      
      (princ (strcat "\n✓ Fixed " (itoa count) " badges"))
    )
    (princ "\n⚠ No blocks found")
  )
  (princ)
)

(defun C:CHECKBADGES (/ ss i ent badge-code att-list count missing)
  "Check badge attribute integrity"
  (princ "\nChecking badge integrity...")
  
  (setq ss (ssget "X" '((0 . "INSERT")))
        count 0
        missing 0)
  
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq badge-code (get-badge-attribute ent "BADGE_CODE"))
        
        (if badge-code
          (progn
            (setq count (1+ count))
            (setq att-list (read-badge-attributes ent))
            
            ; Check for empty description
            (if (= "" (cdr (assoc "DESCRIPTION" att-list)))
              (progn
                (princ (strcat "\n⚠ " badge-code " - Missing description"))
                (setq missing (1+ missing))
              )
            )
          )
        )
        (setq i (1+ i))
      )
      
      (princ (strcat "\n\n✓ Checked " (itoa count) " badges"))
      (if (> missing 0)
        (princ (strcat "\n⚠ " (itoa missing) " badges need data"))
      )
    )
    (princ "\n⚠ No blocks found")
  )
  (princ)
)

;;;-----------------------------------------------------
;;; ATTRIBUTE DISPLAY CONTROL
;;;-----------------------------------------------------

(defun C:FIXATTDISP (/)
  "Fix ATTDISP system variable"
  (setvar "ATTDISP" 1)
  (command "._REGEN")
  (princ "\n✓ ATTDISP set to ON - Attributes visible")
  (princ)
)

(princ "\nBadgeAttributes.lsp loaded.")
(princ "\nCommands: FIXALLBADGES | CHECKBADGES | FIXATTDISP")
(princ)
