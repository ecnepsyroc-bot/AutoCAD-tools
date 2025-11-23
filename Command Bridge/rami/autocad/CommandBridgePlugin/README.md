# Command Bridge .NET Plugin

**Simple Purpose:** Capture ALL command line text output from AutoCAD to save copy/paste for tool versioning.

## What It Does

Captures **every line** of text that appears in the AutoCAD command line and writes it to the bridge file:
- Command prompts ("Specify first point:", etc.)
- Command output
- Error messages
- Status messages
- Everything that appears in the command line

## Building

1. **Update AutoCAD Paths** in `CommandBridgePlugin.csproj`:
   - Change `AutoCAD 2024` to match your AutoCAD version

2. **Build:**
   ```bash
   cd rami/autocad/CommandBridgePlugin
   dotnet build -c Release
   ```

3. **Output:** `bin/Release/net8.0/FeatureMillwork.CommandBridge.dll`

## Loading

In AutoCAD, load `rami/autocad/load-bridge-plugin.lsp` and type `LOADBRIDGE`.

Or use `NETLOAD` directly to load the DLL.

## How It Works

The plugin uses **AutoCAD's command echo mechanism** via the internal API:
1. **`Utils.GetLastCommandLines()`** - Reads command line history (last 500 lines)
2. **Timer-based capture** - Checks every 200ms for new command line text
3. **Differential capture** - Only writes new lines that haven't been captured yet

This method captures ALL text that appears in the command line, including:
- Interactive prompts
- Command output
- Error messages
- Status information

All captured text is written to:
```
C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt
```

## Commands

- `BRIDGE-ON` - Enable capture
- `BRIDGE-OFF` - Disable capture

## Technical Note

Uses `Autodesk.AutoCAD.Internal.Utils.GetLastCommandLines()` which is part of AutoCAD's internal API. This provides reliable access to the command line echo buffer. The plugin maintains a history of captured lines to avoid duplicates and only writes new content.

## Note

This plugin focuses **only** on capturing command line text. No other features.
