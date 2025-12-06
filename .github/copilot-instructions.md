# Copilot Instructions for AutoCAD Tools

## Project Overview

This is the **AutoCAD Tools - Luxify Smartbadge System**, a modular AutoCAD automation system built on the Luxify Architecture. The project provides intelligent badge management with Excel SSOT (Single Source of Truth) integration.

## Architecture: Luxify Architecture

This project strictly follows the **Luxify Architecture** principles. You MUST understand and respect this architecture in all code changes:

### Five Core Concepts

1. **rami/** — Isolated units of responsibility
   - Each ramus is completely independent
   - **NEVER** import from one ramus to another
   - Each ramus has a `.ramus.md` file documenting its responsibilities and APIs
   - Current rami: `autocad`, `badges`, `monitor`, `excel`

2. **grafts/** — Explicit bridges between rami
   - **ONLY** way to connect rami
   - Each graft has a `.graft.md` file describing connections and data flows
   - Grafts orchestrate but don't contain domain logic
   - Current grafts: `badges-command-bridge`, `autocad-monitor`, `monitor-display`

3. **water/** — Event and payload definitions
   - Declarative event specifications only
   - No business logic or orchestration
   - Documents producers and consumers
   - Events are versioned when payloads change

4. **sap/** — Protective guardrails
   - Input sanitation and validation
   - Boundary protection
   - Error handling and logging
   - Does not redefine domain rules

5. **leaves/** — Presentation layer
   - UI and display formatting only
   - No domain or integration logic
   - Interacts through grafts or thin APIs

### Critical Architecture Rules

- **Isolation is strict**: Rami never communicate except through grafts or water
- **Responsibilities are explicit**: Every ramus and graft must document its purpose
- **No cross-contamination**: If adding code, ensure it's in the correct layer
- **Update documentation**: Always update `.ramus.md` or `.graft.md` files when modifying components

## Technology Stack

### Languages and Frameworks
- **C# / .NET 8.0**: AutoCAD plugin (Command Bridge)
- **Python 3.x**: Monitoring, automation scripts, and Excel integration
- **AutoLISP**: AutoCAD automation and badge system
- **Excel**: Data source (SSOT)

### Key Dependencies
- AutoCAD 2024 .NET API (AcDbMgd.dll, AcMgd.dll, AcCoreMgd.dll)
- .NET 8.0 SDK
- Python 3.x standard library

## Project Structure

```
/AutoCAD-tools/
├── Command Bridge/          # Current implementation
│   ├── rami/               # Domain logic units (autocad, badges, monitor, excel)
│   ├── grafts/             # Integration bridges
│   ├── water/              # Event definitions
│   ├── sap/                # Safety and validation
│   └── leaves/             # Presentation components
├── AutoCAD Badge System/   # Badge system components
├── 01_SSOT_EXCEL_TEMPLATE/ # Excel data templates
└── 04_PROJECT_DOCS/        # Documentation
```

## Build and Test Instructions

### Building the .NET Plugin

```bash
cd "Command Bridge/rami/autocad/CommandBridgePlugin"
dotnet build -c Release
```

**Output location**: `bin/Release/net8.0/FeatureMillwork.CommandBridge.dll`

### Running Python Scripts

Python scripts don't require building. Run directly:

```bash
python auto-start-monitor.py
```

### Testing in AutoCAD

1. In AutoCAD, type `APPLOAD`
2. Load `Command Bridge/rami/autocad/command_bridge.lsp`
3. Type `TEST` to verify connection
4. Check terminal/monitor for output

**Note**: There is no automated test suite currently. Manual testing in AutoCAD is required.

## Code Quality Standards

### General Principles
- **Minimal changes**: Make the smallest possible changes to achieve the goal
- **Documentation**: Keep `.ramus.md` and `.graft.md` files up to date
- **Clarity**: Code should be self-documenting; add comments only when needed for complex logic
- **Existing patterns**: Follow patterns already established in the codebase

### Language-Specific Guidelines

#### C# / .NET
- Use .NET 8.0 features
- Follow C# naming conventions (PascalCase for public members, camelCase for private)
- Keep AutoCAD API references with `<Private>False</Private>` to avoid deployment issues
- Handle AutoCAD exceptions appropriately

#### Python
- Use type hints where appropriate
- Follow PEP 8 style guidelines
- Keep scripts simple and focused
- Use standard library when possible

#### AutoLISP
- Follow existing LISP conventions in the codebase
- Maintain compatibility with AutoCAD 2024
- Use descriptive function names
- Include error handling

## Security Considerations

### File Safety (sap/file-safety.py, sap/file-safety.lsp)
- All file operations must go through sap validation
- Never write to files without sanitization
- Validate file paths before access
- Protect against path traversal attacks

### Input Validation
- Validate all external inputs (Excel data, AutoCAD selections, user input)
- Use sap layer for boundary validation
- Never trust data from external sources without validation

### Secrets and Credentials
- **NEVER** commit secrets, API keys, or credentials to source code
- Keep sensitive data in environment variables or external configuration
- The `Millwork_SSOT_v6_NonFinancial.xlsx` file is gitignored for a reason

## Common Tasks

### Adding a New Feature
1. Identify which ramus owns the domain logic
2. Add logic to the appropriate ramus
3. If connecting multiple rami, create or update a graft
4. Update corresponding `.ramus.md` or `.graft.md` documentation
5. Add validation to sap if needed
6. Add presentation logic to leaves if needed

### Modifying AutoCAD Integration
- Core logic goes in `rami/autocad/`
- Bridge communication via grafts
- Safety checks in `sap/file-safety.lsp` and `sap/file-safety.py`

### Adding Python Automation
- Domain logic in appropriate ramus
- Integration through grafts
- Input validation in sap
- Display formatting in leaves

## Issue Scoping Guidelines

When working on issues:
- Start with simple, well-defined tasks
- Break down complex issues into smaller steps
- Focus on one ramus or graft at a time
- Maintain architectural boundaries
- Test changes in AutoCAD when applicable

## Documentation

Key documentation files:
- `Luxify Architecture — Core Spec.md` — Architectural principles
- `README.md` — Project overview
- `Command Bridge/QUICK_START.md` — Getting started guide
- `Command Bridge/WORKFLOW.md` — Development workflow
- Individual `.ramus.md` and `.graft.md` files — Component specifications

## What NOT to Do

- ❌ Don't create direct imports between rami
- ❌ Don't add domain logic to grafts
- ❌ Don't add business logic to water, sap, or leaves
- ❌ Don't skip updating documentation files
- ❌ Don't remove or modify existing tests without good reason
- ❌ Don't add new testing frameworks or tools unless necessary
- ❌ Don't commit build artifacts (*.dll, *.pdb, bin/, obj/)
- ❌ Don't commit AutoCAD temporary files (*.dwl, *.dwl2, *.bak)
- ❌ Don't commit the SSOT Excel file
- ❌ Don't violate the Luxify Architecture principles

## Iteration and Feedback

- Make incremental changes
- Test frequently in the actual AutoCAD environment
- Document architectural decisions
- Ask for clarification if architectural boundaries are unclear
- Use the existing patterns and conventions in the codebase as a guide
