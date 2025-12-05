# Luxify mOS (Millwork Operating System)

Luxify is a suite of AutoCAD plugins designed to automate the drafting, detailing, and production workflow for architectural millwork. It bridges the gap between static CAD drawings and dynamic project data.

## Features

### 1. Smart Badging (`Luxify.Badging`)
*   **Dynamic Badges:** Place "Smart Badges" (e.g., PL1, HW1) that are linked to a central CSV database.
*   **Live Status:** The "Pulse" feature checks the database for changes and visually flags items in the drawing:
    *   **Red Triangle:** Specification has changed (Dirty).
    *   **Orange Octagon:** Item is backordered/critical (Stock Issue).
*   **Palette UI:** A custom WPF palette to view, edit, and place badges.

### 2. Layout Engine (`Luxify.Layout`)
*   **Infinite Grid:** Automatically manages sheet layout on an infinite grid in Model Space.
*   **Title Block Automation:** `LUX_NEW_SHEET` generates a new sheet with a title block, automatically filling in attributes (Project Name, Sheet Number) from the job data.

### 3. Legend Generator (`Luxify.Legends`)
*   **Auto-Legends:** Scans the drawing for badges and generates a localized finish schedule/legend for the specific view.

### 4. Smart Plotting (`Luxify.Plotting`)
*   **Batch Plotting:** Automatically detects sheet boundaries and plots them to PDF with correct naming conventions.

## Installation

1.  **Prerequisites:**
    *   AutoCAD 2026 (or compatible).
    *   .NET 8.0 Runtime.

2.  **Loading:**
    *   Open AutoCAD.
    *   Run `NETLOAD`.
    *   Select the compiled DLLs from the `Release` folder (or `bin/Debug`):
        *   `Luxify.Core.dll`
        *   `Luxify.Badging.dll`
        *   `Luxify.Layout.dll`
        *   `Luxify.Legends.dll`
        *   `Luxify.Plotting.dll`
        *   `Luxify.Labeling.dll`
    *   *Alternatively:* Drag and drop `luxify-loader.lsp` into AutoCAD.

## Commands

| Command | Description |
| :--- | :--- |
| `LUX_SHOW_PALETTE` | Opens the Luxify Badge Palette. |
| `LUX_PLACE_BADGE` | Places a badge from the active selection in the palette. |
| `LUX_NEW_SHEET` | Creates a new drawing sheet with title block. |
| `LUX_CREATE_LEGEND` | Generates a legend for the current selection/view. |
| `LUX_PLOT_ALL` | Batch plots all detected sheets to PDF. |

## Architecture

*   **Core:** Shared data models (`LuxifyLeaf`, `PulseStatus`).
*   **Badging:** WPF UI, AutoCAD interaction, API integration.
*   **Layout:** Geometry creation, Block management.
*   **Data:** CSV-based backing store (mocked Excel service).

## Developer Notes

*   Built with .NET 8.0 and AutoCAD .NET API 2026.
*   Uses `CommunityToolkit.Mvvm` for WPF.
*   "Pulse" feature simulates a REST API call to a Node.js backend.
