# Excel SSOT Ramus

**Version:** 1.0  
**Created:** November 22, 2025  
**Purpose:** Isolated Excel data access layer for Single Source of Truth (SSOT)

---

## Responsibilities

### Primary
- Read Excel workbooks via COM automation (Visual LISP)
- Cache badge library data in memory for performance
- Provide query interface for badge records
- Handle Excel version compatibility (2016+)
- Manage read-only access to prevent file locking

### Secondary
- Refresh cache on demand
- Validate Excel file structure
- Report data statistics (row count, last modified)

---

## Non-Responsibilities

❌ **Badge creation or rendering** - Handled by `badges` ramus  
❌ **AutoCAD drawing operations** - Handled by `autocad` ramus  
❌ **Data validation logic** - Handled by `sap/excel-safety.lsp`  
❌ **UI presentation** - Handled by `leaves`  
❌ **Excel file creation or modification** - Read-only access only  

---

## Public API

### Core Functions

```lisp
(excel:read-badge-library excel-path)
;; Read entire Badge_Library_MASTER sheet
;; Returns: List of badge records
;; Example: (setq badges (excel:read-badge-library "C:\\path\\to\\file.xlsx"))

(excel:get-badge-by-code code)
;; Get single badge record by Badge_Code
;; Returns: Badge record or nil if not found
;; Example: (setq badge (excel:get-badge-by-code "PL1"))

(excel:refresh-cache)
;; Force reload data from Excel file
;; Returns: t if successful, nil if failed
;; Example: (excel:refresh-cache)

(excel:get-projects excel-path)
;; Read Projects_List sheet
;; Returns: List of project records
;; Example: (setq projects (excel:get-projects "C:\\path\\to\\file.xlsx"))

(excel:get-cache-stats)
;; Get current cache statistics
;; Returns: (row-count . last-refreshed-timestamp)
;; Example: (setq stats (excel:get-cache-stats))
```

### Utility Functions

```lisp
(excel:is-cached?)
;; Check if data is currently cached
;; Returns: t if cached, nil otherwise

(excel:clear-cache)
;; Clear all cached data
;; Returns: t

(excel:get-excel-path)
;; Get configured default Excel file path
;; Returns: String path
```

---

## Data Structures

### Badge Record

```lisp
;; Association list format
(
  ("CODE" . "PL1")
  ("DESCRIPTION" . "Plastic Laminate - Fenix NTA (1/2\" MDF Core)")
  ("MATERIAL_TYPE" . "PLASTIC_LAMINATE_FENIX")
  ("VENDOR" . "Pacific Plywood / 3-Form")
  ("LEAD_TIME" . 6)
  ("COST_UNIT" . 175.00)
  ("ALERT_STATUS" . "YES")
  ("PROJECTS_USING" . "A Project,Another Project")
  ;; ... additional fields
)
```

### Project Record

```lisp
;; Association list format
(
  ("NAME" . "Sample Project")
  ("CLIENT" . "Sample Client")
  ("STATUS" . "Active")
  ("PM" . "John Doe")
  ("DRAFTER" . "Steve Smith")
)
```

---

## Dependencies

### Required
- **Visual LISP Extensions** - `(vl-load-com)` must be called
- **Excel 2016+** - Must be installed on workstation
- **Read access** - To Excel workbook file

### Optional
- **Network drive access** - If Excel file on network location
- **File locking** - Handles Excel already open scenarios

---

## Configuration

### Default Paths

```lisp
;; Primary SSOT location
(setq *EXCEL-SSOT-PATH* 
  "G:\\My Drive\\_Feature\\_Millwork_Projects\\AutoCAD-Tools\\data\\Feature_Millwork_Master.xlsx")

;; Backup/fallback location
(setq *EXCEL-BACKUP-PATH*
  "C:\\Temp\\Feature_Millwork_Master_Backup.xlsx")
```

### Performance Settings

```lisp
;; Cache refresh interval (seconds)
(setq *EXCEL-CACHE-TIMEOUT* 300) ; 5 minutes

;; Maximum rows to read
(setq *EXCEL-MAX-ROWS* 1000)

;; Read timeout (milliseconds)
(setq *EXCEL-READ-TIMEOUT* 5000) ; 5 seconds
```

---

## Error Handling

### Error Codes

| Code | Meaning | Recovery Action |
|------|---------|-----------------|
| `EXCEL-FILE-NOT-FOUND` | Excel file doesn't exist | Prompt user for path |
| `EXCEL-LOCKED` | File is locked by another process | Open as read-only |
| `EXCEL-INVALID-FORMAT` | File is not .xlsx/.xlsm | Reject file |
| `EXCEL-MISSING-SHEET` | Required sheet not found | Report specific sheet name |
| `EXCEL-COM-ERROR` | COM automation failed | Fall back to cached data |
| `EXCEL-VERSION-ERROR` | Excel version too old | Require Excel 2016+ |

### Error Recovery

```lisp
;; If Excel read fails, use cached data
(if (not (excel:refresh-cache))
  (progn
    (alert "Excel read failed - using cached data")
    (excel:get-cached-badges))
)
```

---

## Performance Characteristics

### Benchmarks (Target)

| Operation | Target Time | Notes |
|-----------|-------------|-------|
| Initial read (500 rows) | < 2 seconds | Cold start with COM init |
| Cache lookup | < 0.1 seconds | In-memory access |
| Refresh cache | < 1 second | Warm COM object |
| File validation | < 0.5 seconds | Check existence & format |

### Memory Usage

- **Cache size:** ~50 KB per 100 badge records
- **COM objects:** ~5 MB Excel instance overhead
- **Total:** < 10 MB for typical usage

---

## Testing Requirements

### Unit Tests

```lisp
;; Test Excel file reading
(defun test-excel-read ()
  (setq badges (excel:read-badge-library *EXCEL-SSOT-PATH*))
  (assert (> (length badges) 0) "Should read at least one badge")
)

;; Test badge lookup
(defun test-badge-lookup ()
  (setq badge (excel:get-badge-by-code "PL1"))
  (assert (not (null badge)) "Should find PL1 badge")
  (assert (equal (cdr (assoc "CODE" badge)) "PL1") "Code should match")
)

;; Test cache refresh
(defun test-cache-refresh ()
  (assert (excel:refresh-cache) "Cache refresh should succeed")
  (setq stats (excel:get-cache-stats))
  (assert (> (car stats) 0) "Should have cached rows")
)
```

### Integration Tests

- Read from actual Excel file on network drive
- Handle file locked by Excel scenario
- Benchmark performance with 500+ rows
- Test with Excel 2016, 2019, 365

---

## Grafts Connected

### excel-badge (Outbound)

**File:** `grafts/excel-badge/excel-badge.graft.md`  
**Direction:** excel → badges  
**Purpose:** Translate Excel rows to Badge data structures  
**See:** `grafts/excel-badge/ExcelBadgeMapper.lsp`

---

## Water Events

### Produced

```json
{
  "excel.data.loaded": {
    "file_path": "string",
    "row_count": "number",
    "timestamp": "datetime"
  },
  "excel.cache.refreshed": {
    "row_count": "number",
    "duration_ms": "number"
  },
  "excel.read.failed": {
    "file_path": "string",
    "error_code": "string",
    "error_message": "string"
  }
}
```

### Consumed

None - Excel ramus is a pure data source.

---

## Sap Protection

**File:** `sap/excel-safety.lsp`

Validates:
- File existence and accessibility
- Excel file format (.xlsx, .xlsm)
- Sheet presence (Badge_Library_MASTER, Projects_List)
- File not corrupted
- Read permissions

---

## Implementation Notes

### COM Automation Pattern

```lisp
(vl-load-com) ; Load COM extensions

(defun safe-excel-read (path / excel workbook sheet data)
  "Read Excel with proper cleanup"
  (setq excel (vlax-get-or-create-object "Excel.Application"))
  (vlax-put-property excel 'Visible :vlax-false)
  (vlax-put-property excel 'DisplayAlerts :vlax-false)
  
  (setq workbook (vlax-invoke-method 
                   (vlax-get-property excel 'Workbooks) 
                   'Open path :vlax-true)) ; ReadOnly = True
  
  (setq sheet (vlax-get-property 
                (vlax-get-property workbook 'Sheets) 
                'Item "Badge_Library_MASTER"))
  
  (setq data (parse-excel-sheet sheet))
  
  ; CRITICAL: Always cleanup COM objects
  (vlax-invoke-method workbook 'Close :vlax-false)
  (vlax-invoke-method excel 'Quit)
  (vlax-release-object workbook)
  (vlax-release-object excel)
  
  data
)
```

### Read-Only Best Practice

Always open Excel files as read-only to:
- Prevent file locking issues
- Allow multiple AutoCAD instances to access
- Avoid accidental data modification
- Enable concurrent access with Excel

---

## Migration from CSV

### Before (CSV)

```lisp
(setq badges (read-badge-library "path/to/Badge_Library_MASTER.csv"))
```

### After (Excel)

```lisp
(setq badges (excel:read-badge-library "path/to/Feature_Millwork_Master.xlsx"))
```

### Key Differences

| Aspect | CSV | Excel |
|--------|-----|-------|
| Parsing | Simple text split | COM automation |
| Performance | Faster (~0.5s) | Slower (~2s) but cached |
| Multi-user | File locking issues | Read-only handles well |
| Features | None | Formulas, validation |
| Complexity | Low | Medium |

---

## Future Enhancements

### Planned

- [ ] ADO/ODBC database-style queries (alternative to COM)
- [ ] Write capability (update badge status from AutoCAD)
- [ ] Multi-sheet caching (all 13 sheets)
- [ ] Background refresh (don't block AutoCAD)
- [ ] Change detection (only refresh if Excel modified)

### Maybe

- [ ] Export to CSV backup on read
- [ ] Excel formula evaluation from LISP
- [ ] Direct table access (bypass COM)

---

## Version History

**1.0** (November 22, 2025)
- Initial specification
- COM automation approach defined
- Read-only access pattern
- Cache-first architecture

---

**Maintained by:** Feature Millwork Development Team  
**Contact:** AutoCAD Tools Project  
**Last Updated:** November 22, 2025
