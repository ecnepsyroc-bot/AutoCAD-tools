# AutoCAD Badge System - Complete Documentation

## System Version: 2.0
## Last Updated: November 2025

---

## 🎯 SYSTEM OVERVIEW

The AutoCAD Badge System is a standalone, production-ready LISP application for managing badge blocks in AutoCAD drawings. It provides a complete workflow for creating, inserting, extracting, and updating badges from CSV/Excel data in a millwork/cabinetry environment.

### Core Principles
- **Job-Relative**: Badge codes (PL1, WP1, etc.) are standardized "slots" - each job fills these with specific materials
- **CSV-Driven**: All badge data flows through CSV format
- **Self-Contained**: No external dependencies or debug systems required
- **Production-Ready**: Built for real-world millwork environments

---

## 📁 FILE STRUCTURE

### Core System Files (Required)

| File | Purpose | Load Order |
|------|---------|------------|
| `BadgeInit.lsp` | System initialization and globals | 1 |
| `BadgeUtils.lsp` | CSV parsing and utilities | 2 |
| `BadgeLibrary.lsp` | Library cache and lookup | 3 |
| `BadgeAttributes.lsp` | Attribute manipulation | 4 |
| `BadgeSelection.lsp` | Selection and filtering | 5 |
| `BadgeErrorHandler.lsp` | Error handling and recovery | 6 |
| `CreateBadgeBlocks.lsp` | Badge block generation | 7 |
| `CreateBadgesForJob.lsp` | Job-specific creation | 8 |
| `InsertBadge.lsp` | Badge insertion | 9 |
| `ExtractBadges.lsp` | Badge extraction | 10 |
| `UpdateBadges.lsp` | Badge updating | 11 |
| `CONVERT_CircleToBadge.lsp` | Circle conversion | 12 |
| `BadgeShortcuts.lsp` | Keyboard shortcuts | 13 |
| `TEST_ListBlocks.lsp` | Block listing utility | 14 (optional) |

### Master Loader
- `LoadBadgeSystem.lsp` - Loads entire system in correct order

---

## 🚀 QUICK START

### Initial Setup
```lisp
(load "LoadBadgeSystem.lsp")
```

### Basic Workflow
1. **CBJ** - Create badges for your job
2. **B WP1** - Quick insert badge WP1
3. **BL** - Create badge legend
4. **BH** - Show help

---

## 📋 COMMAND REFERENCE

### Primary Commands

| Command | Description | Example |
|---------|-------------|---------|
| **CBJ** | Create Badges for Job | `CBJ` → Select project |
| **B** | Quick badge insert | `B WP1` → Click to place |
| **BL** | Compile badge legend | `BL` → Click legend location |
| **IBG** | Insert badge (legacy) | `IBG` → Follow prompts |
| **XBG** | Extract badges | `XBG` → Select viewport |
| **UBG** | Update badges from CSV | `UBG` → Updates all |

### Utility Commands

| Command | Description |
|---------|-------------|
| **BADGEHELP** / **BH** | Display help |
| **BADGESTATS** | Library statistics |
| **LISTBADGES** | List badges by prefix |
| **CHECKBADGES** | Check badge integrity |
| **FIXALLBADGES** | Fix attribute visibility |
| **FIXATTDISP** | Fix ATTDISP setting |

### Selection Commands

| Command | Description |
|---------|-------------|
| **SELECTBADGES** | Interactive selection menu |
| **ANALYZEBADGES** | Analyze badge composition |
| **COUNTBADGES** | Count badges by code |
| **MOVEBADGES** | Move selected badges |
| **SCALEBADGES** | Scale selected badges |

### System Commands

| Command | Description |
|---------|-------------|
| **REFRESHBADGES** | Refresh library from CSV |
| **VALIDATELIBRARY** | Validate library entries |
| **RELOADBADGES** | Reload entire system |
| **BADGEERRORS** | View error log |
| **CLEARERRORS** | Clear error log |
| **CHECKBADGESYSTEM** | System health check |

---

## 🏷️ BADGE TYPES

### Finish Badges (Ellipse)
- **Shape**: Ellipse
- **Prefixes**: PL (Plastic Laminate), PT (Paint)
- **Examples**: PL1, PL2, PT1, PT2
- **Use**: Paint, lacquer, stain specifications

### Fixture Badges (Rectangle)  
- **Shape**: Rectangle
- **Prefixes**: SS (Stainless Steel), ST (Stone)
- **Examples**: SS1, SS2, ST1, ST2
- **Use**: Sinks, shelving, stone, tile

### Equipment Badges (Diamond)
- **Shape**: Diamond (rotated square)
- **Prefixes**: APPL (Appliance), EQ (Equipment)
- **Examples**: APPL1, APPL2, EQ1, EQ2
- **Use**: Appliances, equipment, mechanical items

---

## 📊 CSV FORMAT

### Badge_Library_MASTER.csv Structure
```csv
BADGE_CODE,CATEGORY,DESCRIPTION,MATERIAL,SUPPLIER,ISSUE_NOTES
PL1,FINISH,White Melamine,Melamine,Uniboard,
PT1,FINISH,Satin Black,Paint,Benjamin Moore,Back ordered
SS1,FIXTURE,Single Bowl Sink,Stainless,Franke,
APPL1,EQUIPMENT,Dishwasher,DW80R5061US,Samsung,
```

### Field Descriptions
- **BADGE_CODE**: Unique identifier (PL1, PT1, etc.)
- **CATEGORY**: FINISH, FIXTURE, or EQUIPMENT
- **DESCRIPTION**: Human-readable description
- **MATERIAL**: Material specification
- **SUPPLIER**: Vendor/manufacturer
- **ISSUE_NOTES**: Any special notes or issues

---

## ⚙️ SYSTEM CONFIGURATION

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

## 🔧 TECHNICAL DETAILS

### Attribute Tags
All badge blocks contain these attributes:
- BADGE_CODE
- CATEGORY  
- DESCRIPTION
- MATERIAL
- SUPPLIER
- ISSUE_NOTES

### Layer Structure
- **BADGES**: Main badge layer (Color 7 - White/Black)

### System Variables
The system manages these AutoCAD variables:
- ATTDIA = 0 (Suppress attribute dialog)
- ATTREQ = 1 (Require attributes)
- CMDECHO = 0 (Suppress command echo)

---

## 🛠️ TROUBLESHOOTING

### Common Issues

#### Badge Library Not Loading
```
Solution: Run REFRESHBADGES
Check: CSV file path is correct
Check: File not locked by Excel/Google Drive
```

#### Badges Not Visible
```
Solution: Run FIXATTDISP
Check: ATTDISP = 1
Check: Layer not frozen
```

#### Update Badges Fails
```
Solution: Wait 30 seconds after Excel edit
Check: CSV not locked
Run: CHECKBADGESYSTEM for diagnostics
```

#### Missing Attributes
```
Solution: Run FIXALLBADGES
Check: Block has required attributes
Run: VALIDATELIBRARY
```

---

## 📝 BEST PRACTICES

### Job Organization
1. One job per drawing
2. Run CBJ at start of each session
3. Keep Badge_Library_MASTER.csv updated
4. Use consistent badge naming

### Performance Tips
1. Load system once per session
2. Use REFRESHBADGES sparingly
3. Keep library under 1000 badges
4. Close Excel before updating

### Data Management
1. Backup Badge_Library_MASTER.csv regularly
2. Document custom badges in ISSUE_NOTES
3. Review badge descriptions before production
4. Test badge blocks after creation

---

## 🔄 WORKFLOW EXAMPLES

### New Project Setup
```
1. Open new drawing
2. (load "LoadBadgeSystem.lsp")
3. CBJ → Select "NETFLIX"
4. Badges created for project
```

### Placing Badges
```
1. B PL1 → Click location
2. B PT2 → Click location  
3. BL → Click for legend
```

### Updating from Excel
```
1. Edit Badge_Library_MASTER.csv
2. Save and close Excel
3. Wait 30 seconds (Google Drive sync)
4. UBG → All badges updated
```

### Quality Check
```
1. CHECKBADGES → Review integrity
2. COUNTBADGES → Count by type
3. ANALYZEBADGES → Category breakdown
```

---

## 🚨 ERROR HANDLING

The system includes comprehensive error handling:

- **Automatic Recovery**: System attempts to recover from errors
- **Error Logging**: All errors logged with context
- **File Locking**: 5 retry attempts with 1.5 sec delays
- **Validation**: Pre-flight checks before operations

View errors: `BADGEERRORS`
Clear log: `CLEARERRORS`
System check: `CHECKBADGESYSTEM`

---

## 📌 IMPORTANT NOTES

1. **This is the AutoCAD Badge System ONLY**
   - No Command Bridge components
   - No debug/telemetry systems
   - Completely self-contained

2. **Job-Relative Design**
   - PL1 in NETFLIX ≠ PL1 in DENTONS
   - Always maintain job context
   - Badges are job-specific references

3. **CSV is Source of Truth**
   - All data flows through CSV
   - Excel/Google Sheets for editing
   - System reads CSV only

4. **Production Environment**
   - Used in real millwork shop
   - Maintain data integrity
   - Follow naming conventions

---

## 🎯 SYSTEM PHILOSOPHY

The AutoCAD Badge System follows these principles:

1. **Simplicity**: One command, one purpose
2. **Reliability**: Extensive error handling
3. **Modularity**: Clear file boundaries
4. **Performance**: Efficient caching
5. **Usability**: Intuitive shortcuts

---

## 📧 SUPPORT

For issues or questions about the AutoCAD Badge System:
- Check: `BADGEHELP` command
- Run: `CHECKBADGESYSTEM` diagnostic
- Review: Error log with `BADGEERRORS`

---

*End of Documentation*
