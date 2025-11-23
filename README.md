# AutoCAD Tools - Luxify Smartbadge System

A modular AutoCAD automation system built on the **Luxify Architecture** for managing intelligent badges with Excel SSOT integration.

## Architecture

This project follows the [Luxify Architecture](./Luxify%20Architecture%20—%20Core%20Spec.md), a modular system enforcing strict separation of concerns through five core concepts:

- **rami/** — Isolated units of responsibility (autocad, badges, monitor)
- **grafts/** — Explicit bridges between rami
- **water/** — Event and payload definitions
- **sap/** — Protective guardrails (validation, safety)
- **leaves/** — Presentation layer (UI/terminal formatters)

## Project Structure

```
01_SSOT_EXCEL_TEMPLATE/    # Single Source of Truth - Excel data templates
02_CAD_LISP_ASSETS/        # AutoCAD LISP code and badge systems
03_EXTERNAL_COM_BRIDGE/    # .NET/Python bridge for external communication
04_PROJECT_DOCS/           # Documentation and guides

Command Bridge/            # Current implementation (to be organized)
  rami/                    # Domain logic units
  grafts/                  # Integration bridges
  water/                   # Event definitions
  sap/                     # Safety and validation
  leaves/                  # Presentation components
```

## Key Features

- **Badge System**: Dynamic AutoCAD attribute management
- **Excel Integration**: Data-driven badge population from SSOT
- **Command Bridge**: Real-time AutoCAD ↔ Python communication
- **Monitoring**: Live event tracking and display

## Getting Started

See [QUICK_START.md](Command%20Bridge/QUICK_START.md) for setup instructions.

## Architecture Documentation

- **[Luxify Architecture — Core Spec](Luxify%20Architecture%20—%20Core%20Spec.md)** - Foundational architectural principles
- **[System Documentation](AutoCAD%20Badge%20System/SYSTEM_DOCUMENTATION.md)** - Badge system overview
- **[Workflow Guide](Command%20Bridge/WORKFLOW.md)** - Development workflow

## Development Status

🚧 Active development - transitioning to structured Luxify-compliant organization.