# Badges Ramus

**Ramus Type:** Core Module  
**Location:** `rami/badges/`  
**Source:** `C:\Users\cory\OneDrive\_Feature_Millwork\AutoCAD Badge System\`

---

## Purpose

The Badges ramus provides a complete, standalone AutoCAD badge management system for millwork/cabinetry environments. It handles the full lifecycle of badge blocks: creation, insertion, extraction, and updating from CSV/Excel data.

**Key Principle:** This ramus is **completely self-contained** and operates independently from the Command Bridge system. It can function without any bridge or monitoring components.

---

## Responsibilities

* ✅ Badge block creation and management
* ✅ CSV/Excel data integration
* ✅ Badge insertion, extraction, and updating
* ✅ Badge library caching and lookup
* ✅ Attribute manipulation
* ✅ Selection and filtering operations
* ✅ Error handling and recovery
* ✅ Circle-to-badge conversion

---

## Non-Responsibilities

* ❌ Command Bridge communication (separate ramus)
* ❌ Debug/telemetry systems (separate ramus)
* ❌ External monitoring (separate ramus)
* ❌ Network communication
* ❌ File watching (monitor ramus handles this)

---

## Public API

### Primary Commands

| Command | Description | Water Format |
|---------|-------------|--------------|
| `CBJ` | Create Badges for Job | `{ command: "CBJ", jobName: string }` |
| `B` | Quick badge insert | `{ command: "B", badgeCode: string, point: [x, y] }` |
| `BL` | Compile badge legend | `{ command: "BL", point: [x, y] }` |
| `IBG` | Insert badge (legacy) | `{ command: "IBG" }` |
| `XBG` | Extract badges | `{ command: "XBG", viewport: string }` |
| `UBG` | Update badges from CSV | `{ command: "UBG" }` |

### Utility Commands

| Command | Description |
|---------|-------------|
| `BADGEHELP` / `BH` | Display help |
| `BADGESTATS` | Library statistics |
| `LISTBADGES` | List badges by prefix |
| `CHECKBADGES` | Check badge integrity |
| `FIXALLBADGES` | Fix attribute visibility |
| `FIXATTDISP` | Fix ATTDISP setting |
| `BADGEERRORS` | View error log |
| `CLEARERRORS` | Clear error log |
| `CHECKBADGESYSTEM` | System health check |

---

## File Structure

### Core System Files

**Following Luxify Tree Architecture - Monolithic files removed**

| File | Purpose | Load Order |
|------|---------|------------|
| `BadgeInit.lsp` | System initialization and globals | 1 |
| `BadgeLibrary.lsp` | Library cache and lookup | 2 |
| `BadgeAttributes.lsp` | Attribute manipulation | 3 |
| `BadgeSelection.lsp` | Selection and filtering | 4 |
| `BadgeErrorHandler.lsp` | Error handling and recovery | 5 |

**Master Loader:**
* `LoadBadgeSystem.lsp` - Loads entire system in correct order

---

## Water Interface

### Input Data

**CSV Format:**
```csv
BADGE_CODE,CATEGORY,DESCRIPTION,MATERIAL,SUPPLIER,ISSUE_NOTES
PL1,FINISH,White Melamine,Melamine,Uniboard,
PT1,FINISH,Satin Black,Paint,Benjamin Moore,Back ordered
```

**Internal Structure:**
```lisp
{
  BADGE_CODE: string,
  CATEGORY: "FINISH" | "FIXTURE" | "EQUIPMENT",
  DESCRIPTION: string,
  MATERIAL: string,
  SUPPLIER: string,
  ISSUE_NOTES: string
}
```

### Output Data

**Badge Block Attributes:**
- BADGE_CODE
- CATEGORY
- DESCRIPTION
- MATERIAL
- SUPPLIER
- ISSUE_NOTES

---

## Grafts

### `grafts/badges-command-bridge/`

**Connection:** Badges ramus → Command Bridge (optional)

**Status:** NOT IMPLEMENTED (optional future integration)

**Purpose:** Optional integration for monitoring badge operations through Command Bridge.

See `grafts/badges-command-bridge/badges-command-bridge.graft.md` for details.

---

## Dependencies

**None** - This ramus is completely self-contained:
- Uses only AutoCAD LISP (built-in)
- No external libraries
- No network dependencies
- No Command Bridge dependencies

---

## Configuration

### Global Variables

```lisp
*BADGE-CSV-PATH*        ; Path to Badge_Library_MASTER.csv
*BADGE-SYSTEM-VERSION*  ; Current version (2.0)
*BADGE-JOB-NAME*       ; Current job context
*BADGE-LIBRARY-DATA*   ; Cached library data
*BADGE-LAYER-NAME*     ; Layer for badges ("BADGES")
```

### Default Paths

```
CSV: G:\My Drive\_Feature\_Millwork_Projects\badge-reflex\Badge_Library_MASTER.csv
System: C:\Users\cory\OneDrive\_Feature_Millwork\AutoCAD Badge System\
```

---

## Error Handling (Sap)

The ramus includes comprehensive error handling:

* **Automatic Recovery**: System attempts to recover from errors
* **Error Logging**: All errors logged with context
* **File Locking**: 5 retry attempts with 1.5 sec delays
* **Validation**: Pre-flight checks before operations

**Note:** Error handling is currently embedded in the ramus. Future refactoring could extract to `sap/` for shared validation logic.

---

## Usage

### Loading the Ramus

```lisp
(load "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\AutoCAD Badge System\\LoadBadgeSystem.lsp")
```

### Basic Workflow

1. **CBJ** - Create badges for your job
2. **B WP1** - Quick insert badge WP1
3. **BL** - Create badge legend
4. **BH** - Show help

---

## Architecture Rules

1. **Luxify Tree Ramus Structure**
   - Following ramus-based architecture
   - Monolithic files removed and refactored
   - Clear separation of concerns by ramus
   - Each ramus has single responsibility

2. **Standalone Operation**
   - Must work without Command Bridge
   - No external dependencies
   - Self-contained error handling

3. **Modular Structure**
   - One file, one purpose
   - Clear load order
   - No circular dependencies
   - Ramus boundaries respected

4. **CSV-Driven**
   - All data flows through CSV
   - CSV is source of truth
   - No hardcoded badge data

5. **Job-Relative**
   - Badge codes are standardized slots
   - Each job fills slots with specific materials
   - PL1 in NETFLIX ≠ PL1 in DENTONS

---

## Notes

* This ramus is **production-ready** and used in real millwork environments
* Maintain data integrity and follow naming conventions
* System is version 2.0 (November 2025)
* See `SYSTEM_DOCUMENTATION.md` for complete details

---

*Last updated: 2025-11-16*

