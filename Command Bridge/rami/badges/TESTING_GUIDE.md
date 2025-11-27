# AutoCAD Badge System - Testing Guide

**Complete walkthrough for testing the badge system**

---

## 📋 Prerequisites

Before testing, ensure you have:

1. ✅ **AutoCAD** open with a new or existing drawing
2. ✅ **CSV file** exists at the configured path:
   - Default: `G:\My Drive\_Feature\_Millwork_Projects\badge-reflex\Badge_Library_MASTER.csv`
   - Or check `*BADGE-CSV-PATH*` variable after loading
3. ✅ **CSV file is accessible** (not locked by Excel/Google Drive)
4. ✅ **Badge system files** in correct location:
   - `C:\Users\cory\OneDrive\_Feature_Millwork\AutoCAD Badge System\`

---

## 🚀 Step 1: Load the System

### In AutoCAD Command Line:

```lisp
(load "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD Badge System\\LoadBadgeSystem.lsp")
```

### Expected Output:

```
================================================
   AUTOCAD BADGE SYSTEM - LOADING
================================================

  Loading: BadgeInit.lsp ... ✓
  Loading: BadgeUtils.lsp ... ✓
  Loading: BadgeLibrary.lsp ... ✓
  Loading: BadgeAttributes.lsp ... ✓
  Loading: BadgeSelection.lsp ... ✓
  Loading: CreateBadgeBlocks.lsp ... ✓
  Loading: CreateBadgesForJob.lsp ... ✓
  Loading: InsertBadge.lsp ... ✓
  Loading: ExtractBadges.lsp ... ✓
  Loading: UpdateBadges.lsp ... ✓
  Loading: CONVERT_CircleToBadge.lsp ... ✓
  Loading: BadgeShortcuts.lsp ... ✓

================================================
✓ BADGE SYSTEM LOADED
  Files: 12/12
  Time: 0.XX seconds
================================================

Quick Start:
  CBJ  - Create badges for your job
  B    - Quick insert badge
  BL   - Create badge legend
  BH   - Show help

✅ Badge System Ready!
```

### ✅ Success Criteria:
- All files load without errors
- No "NOT FOUND" messages
- System reports "Ready!"

---

## 🔍 Step 2: System Health Check

### Run System Diagnostic:

**Command:** `CHECKBADGESYSTEM`

### Expected Output:

```
================================================
   BADGE SYSTEM HEALTH CHECK
================================================

System Status:
  Version: 2.0
  Status: ✓ OPERATIONAL

File Checks:
  CSV Path: G:\My Drive\_Feature\_Millwork_Projects\badge-reflex\Badge_Library_MASTER.csv
  CSV Status: ✓ FOUND
  CSV Accessible: ✓ YES

Library Status:
  Library Loaded: ✓ YES
  Badge Count: XX
  Categories: FINISH, FIXTURE, EQUIPMENT

Configuration:
  Badge Layer: BADGES
  ATTDISP: 1
  ATTDIA: 0
  ATTREQ: 1

================================================
✓ System is healthy and ready
```

### ✅ Success Criteria:
- All checks show ✓
- CSV file is found and accessible
- Library is loaded with badge count > 0
- No error messages

### ❌ If Issues:
- **CSV not found**: Check path in `BadgeInit.lsp`
- **CSV locked**: Close Excel/Google Drive, wait 30 seconds
- **Library not loaded**: Run `REFRESHBADGES`

---

## 📊 Step 3: Test Library Functions

### 3.1 View Library Statistics

**Command:** `BADGESTATS`

**Expected Output:**
```
================================================
   BADGE LIBRARY STATISTICS
================================================

Total Badges: 45
Categories:
  FINISH: 20 badges
  FIXTURE: 15 badges
  EQUIPMENT: 10 badges

Prefixes:
  PL: 10 badges
  PT: 10 badges
  SS: 8 badges
  ST: 7 badges
  APPL: 6 badges
  EQ: 4 badges
```

### 3.2 List Badges by Prefix

**Command:** `LISTBADGES`

**Prompt:** Enter prefix (e.g., PL, PT, SS)

**Expected Output:**
```
Badges with prefix "PL":
  PL1 - White Melamine
  PL2 - Gray Melamine
  PL3 - Black Melamine
  ...
```

### 3.3 Validate Library

**Command:** `VALIDATELIBRARY`

**Expected Output:**
```
Validating library entries...
✓ All entries valid
✓ No duplicate codes found
✓ All required fields present
```

### ✅ Success Criteria:
- Statistics display correctly
- Badges can be listed by prefix
- Library validation passes

---

## 🎯 Step 4: Test Core Commands

### 4.1 Test Help Command

**Command:** `BH` or `BADGEHELP`

**Expected Output:**
```
================================================
   AUTOCAD BADGE SYSTEM - HELP
================================================

PRIMARY COMMANDS:
  CBJ  - Create badges for your job
  B    - Quick insert badge (B WP1)
  BL   - Create badge legend
  IBG  - Insert badge (legacy)
  XBG  - Extract badges
  UBG  - Update badges from CSV

UTILITY COMMANDS:
  BH   - Show this help
  BADGESTATS - Library statistics
  ...
```

### 4.2 Test Badge Creation for Job

**Command:** `CBJ` (Create Badges for Job)

**Steps:**
1. Command prompts: "Enter job name:"
2. Type a test job name (e.g., `TESTJOB`)
3. Press Enter

**Expected Output:**
```
Creating badges for job: TESTJOB
Reading badge library...
Processing badges...
✓ Created 45 badge blocks for TESTJOB
✓ Badge blocks ready for insertion
```

**Verify:**
- Check block definitions exist:
  - **Command:** `INSERT`
  - Look for blocks like `TESTJOB-PL1`, `TESTJOB-PT1`, etc.

### ✅ Success Criteria:
- Job badges created successfully
- Block definitions exist in drawing
- No error messages

---

## 📍 Step 5: Test Badge Insertion

### 5.1 Quick Insert (Recommended)

**Command:** `B WP1`

**Steps:**
1. Type `B WP1` (or any badge code)
2. Click in model space to place badge
3. Badge should appear at click location

**Expected Output:**
```
Inserting badge: WP1
Badge inserted at: (100.00, 200.00)
```

**Verify:**
- Badge block appears in drawing
- Badge is on "BADGES" layer
- Attributes are visible

### 5.2 Legacy Insert

**Command:** `IBG`

**Steps:**
1. Follow prompts:
   - "Enter badge code:" → Type `PL1`
   - "Specify insertion point:" → Click location
   - "Enter rotation:" → Press Enter (0 degrees)

**Expected Output:**
```
Inserting badge: PL1
Badge inserted successfully
```

### ✅ Success Criteria:
- Badge appears in drawing
- Attributes display correctly
- Badge is on correct layer

---

## 🔄 Step 6: Test Badge Updates

### 6.1 Update from CSV

**Prerequisites:**
- Have at least one badge inserted in drawing
- CSV file has been edited (if testing updates)

**Command:** `UBG`

**Expected Output:**
```
Updating badges from CSV...
Reading updated library...
Scanning drawing for badges...
Found 5 badges to update
Updating badge: PL1
Updating badge: PT1
...
✓ Updated 5 badges successfully
```

**Verify:**
- Badge attributes reflect CSV changes
- No badges were missed
- No errors occurred

### ✅ Success Criteria:
- All badges updated correctly
- Attributes match CSV data
- No error messages

---

## 📤 Step 7: Test Badge Extraction

### 7.1 Extract Badges

**Prerequisites:**
- Have badges inserted in drawing
- Have a viewport or layout (for extraction)

**Command:** `XBG`

**Steps:**
1. Command prompts: "Select viewport or press Enter for model space:"
2. Select viewport or press Enter
3. Command extracts badge data

**Expected Output:**
```
Extracting badges...
Scanning for badges...
Found 5 badges
Extracting data...
✓ Extracted 5 badges
✓ Data ready for CSV export
```

**Verify:**
- Badge data extracted correctly
- All badge codes captured
- Attributes preserved

### ✅ Success Criteria:
- Extraction completes successfully
- All badges found and extracted
- Data is accurate

---

## 🔧 Step 8: Test Utility Commands

### 8.1 Check Badge Integrity

**Command:** `CHECKBADGES`

**Expected Output:**
```
Checking badge integrity...
Scanning drawing...
Found 5 badges
Checking attributes...
✓ All badges have required attributes
✓ No orphaned badges found
✓ Badge integrity: OK
```

### 8.2 Count Badges

**Command:** `COUNTBADGES`

**Expected Output:**
```
Counting badges by code...
PL1: 2 badges
PT1: 1 badge
SS1: 1 badge
APPL1: 1 badge
Total: 5 badges
```

### 8.3 Analyze Badges

**Command:** `ANALYZEBADGES`

**Expected Output:**
```
Analyzing badge composition...
Categories:
  FINISH: 3 badges (60%)
  FIXTURE: 1 badge (20%)
  EQUIPMENT: 1 badge (20%)
```

### 8.4 Fix Attribute Display

**Command:** `FIXATTDISP`

**Expected Output:**
```
Fixing attribute display...
Setting ATTDISP = 1
✓ Attribute display fixed
```

### ✅ Success Criteria:
- All utility commands work correctly
- No errors reported
- Results are accurate

---

## 🛠️ Step 9: Test Error Handling

### 9.1 View Error Log

**Command:** `BADGEERRORS`

**Expected Output:**
```
Error Log:
  [Empty] - No errors recorded
```

Or if errors exist:
```
Error Log:
  [2025-11-15 13:00:00] Failed to read CSV: file locked
  [2025-11-15 13:05:00] Badge code not found: INVALID
```

### 9.2 Test Error Recovery

**Scenario:** Try to insert invalid badge code

**Command:** `B INVALID`

**Expected Output:**
```
Error: Badge code "INVALID" not found in library
Run LISTBADGES to see available codes
```

**Verify:**
- Error message is clear
- System doesn't crash
- Error logged (check with `BADGEERRORS`)

### 9.3 Clear Errors

**Command:** `CLEARERRORS`

**Expected Output:**
```
Error log cleared
```

### ✅ Success Criteria:
- Errors are caught and logged
- System recovers gracefully
- Error messages are helpful

---

## 🔄 Step 10: Test Refresh and Reload

### 10.1 Refresh Library

**Command:** `REFRESHBADGES`

**Expected Output:**
```
Refreshing badge library from CSV...
Reading CSV file...
Processing entries...
✓ Library refreshed
✓ XX badges loaded
```

### 10.2 Reload System

**Command:** `RELOADBADGES`

**Expected Output:**
```
Reloading Badge System...
[System reloads all files]
✓ Badge System reloaded successfully
```

### ✅ Success Criteria:
- Library refreshes correctly
- System reloads without errors
- All commands still work after reload

---

## 🎨 Step 11: Test Badge Legend

### 11.1 Create Badge Legend

**Command:** `BL`

**Steps:**
1. Command prompts: "Specify legend location:"
2. Click in model space where legend should appear
3. Legend table is created

**Expected Output:**
```
Creating badge legend...
Compiling badge list...
Found 5 unique badges
Creating legend table...
✓ Legend created at: (100.00, 200.00)
```

**Verify:**
- Legend table appears
- All badges in drawing are listed
- Table is formatted correctly

### ✅ Success Criteria:
- Legend created successfully
- All badges included
- Table is readable

---

## 🔄 Step 12: Test Circle Conversion

### 12.1 Convert Circle to Badge

**Prerequisites:**
- Have at least one circle in drawing

**Command:** `CONVERT_CircleToBadge` (or check actual command name)

**Steps:**
1. Command prompts: "Select circles to convert:"
2. Select one or more circles
3. Command prompts: "Enter badge code:"
4. Type badge code (e.g., `PL1`)
5. Press Enter

**Expected Output:**
```
Converting circles to badges...
Selected: 3 circles
Converting to badge: PL1
✓ Converted 3 circles to badges
```

**Verify:**
- Circles replaced with badge blocks
- Badge attributes are correct
- Original circles removed

### ✅ Success Criteria:
- Conversion works correctly
- Badges have correct attributes
- No errors

---

## 📝 Step 13: Complete Workflow Test

### Full Workflow:

1. **Load System**
   ```lisp
   (load "LoadBadgeSystem.lsp")
   ```

2. **Check System Health**
   ```
   CHECKBADGESYSTEM
   ```

3. **Create Badges for Job**
   ```
   CBJ → Enter: TESTJOB
   ```

4. **Insert Multiple Badges**
   ```
   B PL1 → Click location
   B PT1 → Click location
   B SS1 → Click location
   ```

5. **Check Badge Count**
   ```
   COUNTBADGES
   ```

6. **Create Legend**
   ```
   BL → Click location
   ```

7. **Update Badges** (if CSV changed)
   ```
   UBG
   ```

8. **Extract Badges**
   ```
   XBG → Press Enter (model space)
   ```

9. **Final Check**
   ```
   CHECKBADGES
   ANALYZEBADGES
   ```

### ✅ Success Criteria:
- All steps complete without errors
- Badges appear correctly
- Data flows properly through system

---

## 🚨 Troubleshooting

### Issue: System Won't Load

**Symptoms:**
- Files show "NOT FOUND"
- Load count < 12

**Solutions:**
1. Check file path in `LoadBadgeSystem.lsp`
2. Verify all files exist in directory
3. Check file permissions

### Issue: CSV Not Found

**Symptoms:**
- `CHECKBADGESYSTEM` shows CSV not found
- Library won't load

**Solutions:**
1. Verify CSV path in `BadgeInit.lsp`
2. Check file exists at path
3. Ensure file is not locked by Excel

### Issue: Badges Not Visible

**Symptoms:**
- Badges inserted but not visible
- Attributes not showing

**Solutions:**
1. Run `FIXATTDISP`
2. Check layer "BADGES" is not frozen
3. Run `FIXALLBADGES`
4. Check `ATTDISP` variable = 1

### Issue: Update Fails

**Symptoms:**
- `UBG` command fails
- Badges not updating

**Solutions:**
1. Wait 30 seconds after editing CSV (Google Drive sync)
2. Close Excel before updating
3. Check CSV file is not locked
4. Run `REFRESHBADGES` first

---

## ✅ Testing Checklist

Use this checklist to verify complete system functionality:

- [ ] System loads without errors
- [ ] `CHECKBADGESYSTEM` passes all checks
- [ ] `BADGESTATS` displays library statistics
- [ ] `LISTBADGES` works for each prefix
- [ ] `CBJ` creates job badges successfully
- [ ] `B [code]` inserts badges correctly
- [ ] `IBG` legacy insert works
- [ ] `UBG` updates badges from CSV
- [ ] `XBG` extracts badges correctly
- [ ] `BL` creates legend
- [ ] `CHECKBADGES` validates integrity
- [ ] `COUNTBADGES` counts correctly
- [ ] `ANALYZEBADGES` analyzes composition
- [ ] `BADGEERRORS` shows error log
- [ ] `REFRESHBADGES` refreshes library
- [ ] `RELOADBADGES` reloads system
- [ ] Error handling works correctly
- [ ] All utility commands function

---

## 📊 Expected Test Results

After completing all tests, you should have:

- ✅ System fully operational
- ✅ Library loaded with badges
- ✅ Job badges created
- ✅ Badges inserted in drawing
- ✅ Legend created
- ✅ All commands functional
- ✅ No critical errors

---

*Last updated: 2025-11-15*

