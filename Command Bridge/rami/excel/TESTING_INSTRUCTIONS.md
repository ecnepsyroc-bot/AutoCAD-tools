# Testing the Excel Reader in AutoCAD

## Quick Start

### 1. Open AutoCAD
- Launch AutoCAD 2026 (or your installed version)
- Open any drawing or create a new one

### 2. Load the Excel Reader

**Method A: Using APPLOAD**
1. Type `APPLOAD` in AutoCAD command line
2. Navigate to: `C:\Users\cory\OneDrive\_Feature_Millwork\AutoCAD tools\Command Bridge\rami\excel\`
3. Select `LoadExcelReader.lsp`
4. Click "Load"

**Method B: Drag and Drop**
1. Open File Explorer
2. Navigate to the excel folder
3. Drag `LoadExcelReader.lsp` into AutoCAD window

### 3. Run Tests

Type in AutoCAD command line:
```
TEST-EXCEL
```

This will run the complete test suite and display results in the command window.

---

## What the Tests Do

### Test 1: Basic Excel Read
- Loads the test Excel workbook
- Times the read operation
- Displays first badge record
- **Expected**: ~1-3 seconds, 10 badges loaded

### Test 2: Badge Lookup
- Tests `excel:get-badge-by-code` function
- Looks up: PL1, WP1, NONEXISTENT, SL1
- **Expected**: PL1, WP1, SL1 found; NONEXISTENT not found

### Test 3: Cache Operations
- Tests cache refresh
- Benchmarks cache lookup speed
- **Expected**: 100 lookups in <100ms (sub-millisecond average)

### Test 4: Display All Badges
- Shows formatted table of all badges
- **Expected**: Nice ASCII table with 10 rows

### Test 5: File Validation
- Tests file existence and format checks
- **Expected**: Valid .xlsx files pass, others fail

### Benchmark: Performance
- 5 Excel reads averaged
- 100 cache lookups averaged
- **Expected**: Cache 100-1000x faster than Excel read

---

## Manual Testing Commands

After loading, you can test individual functions:

```lisp
;; Read Excel file
(setq badges (excel:read-badge-library 
  "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD tools\\01_SSOT_EXCEL_TEMPLATE\\Feature_Millwork_Test.xlsx"))

;; Get specific badge
(setq badge (excel:get-badge-by-code "PL1"))

;; Print badge details
(excel:print-badge badge)

;; Refresh cache
(excel:refresh-cache)

;; Get cache stats
(excel:get-cache-stats)

;; Check if cached
(excel:is-cached?)

;; Clear cache
(excel:clear-cache)
```

---

## Expected Results

### Performance Benchmarks

| Operation | Target | Acceptable |
|-----------|--------|------------|
| Excel read (cold) | < 2s | < 5s |
| Excel read (warm) | < 1s | < 3s |
| Cache lookup | < 1ms | < 10ms |
| Cache refresh | < 1s | < 3s |

### Success Criteria

✅ **PASS** if:
- All 10 badges load correctly
- Badge lookups find correct records
- Cache operations work without errors
- Performance within acceptable range
- No COM errors or crashes

❌ **FAIL** if:
- Excel COM object creation fails
- File not found errors
- Incorrect data returned
- Performance > 5 seconds for read
- AutoCAD crashes or hangs

---

## Troubleshooting

### "Excel COM object creation failed"
**Cause:** Excel not installed or COM registration issue  
**Fix:** 
- Verify Excel 2016+ is installed
- Run AutoCAD as Administrator
- Restart AutoCAD

### "File not found"
**Cause:** Wrong path or file doesn't exist  
**Fix:**
- Verify file exists at: `01_SSOT_EXCEL_TEMPLATE\Feature_Millwork_Test.xlsx`
- Check path in `*TEST-EXCEL-PATH*` variable
- Update path if needed: `(setq *TEST-EXCEL-PATH* "your\\path\\here.xlsx")`

### "Sheet not found"
**Cause:** Excel file doesn't have expected sheet name  
**Fix:**
- Open Excel file
- Verify sheet named "Badge_Library_MASTER" exists
- Check spelling/capitalization

### Very slow performance (>10 seconds)
**Cause:** Network drive, antivirus scanning, or large file  
**Fix:**
- Copy Excel file to local drive (C:\Temp\)
- Add Excel folder to antivirus exclusions
- Close Excel if file is open

### "Visual LISP not loaded"
**Cause:** `(vl-load-com)` failed  
**Fix:**
- Ensure using full AutoCAD (not LT)
- Restart AutoCAD
- Type `(vl-load-com)` manually

---

## Next Steps After Testing

### If Tests Pass ✅
1. Proceed to create Excel-Badge graft
2. Build sap/excel-safety.lsp validation layer
3. Update existing badge commands to use Excel

### If Tests Fail ❌
1. Review error messages
2. Check troubleshooting section
3. Verify Excel file structure matches spec
4. Test with simplified Excel file (fewer rows)

---

## Test File Details

**Location:** `01_SSOT_EXCEL_TEMPLATE\Feature_Millwork_Test.xlsx`

**Contents:**
- Sheet: Badge_Library_MASTER
- Records: 10 sample badges
- Format: Excel Table (tblBadgeLibrary)
- Features: Headers, conditional formatting, frozen panes

**Sample Badges:**
- PL1, PL2 (Plastic Laminate)
- WP1, WP2, WP3 (Wood Veneer)
- PP1, PP2 (Paint Grade)
- SL1, SL2 (Solid Surface)
- GL1 (Glass)

---

**Created:** November 22, 2025  
**Version:** 1.0  
**For:** AutoCAD Tools - Excel SSOT Integration
