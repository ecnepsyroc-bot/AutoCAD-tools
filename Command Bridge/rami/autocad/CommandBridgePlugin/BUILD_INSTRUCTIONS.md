# Building the Command Bridge .NET Plugin

## Quick Start

### 1. Prerequisites
- Visual Studio 2022 or later (or .NET 8.0 SDK)
- AutoCAD 2024 installed
- Access to AutoCAD .NET API DLLs

### 2. Update AutoCAD Paths

Edit `CommandBridgePlugin.csproj` and update the AutoCAD installation path:

```xml
<Reference Include="AcDbMgd">
  <HintPath>C:\Program Files\Autodesk\AutoCAD 2024\AcDbMgd.dll</HintPath>
  <Private>False</Private>
</Reference>
```

**Important:** Change `AutoCAD 2024` to match your AutoCAD version.

### 3. Build the Plugin

**Using Visual Studio:**
1. Open `CommandBridgePlugin.csproj` in Visual Studio
2. Select "Release" configuration
3. Build → Build Solution (Ctrl+Shift+B)

**Using Command Line:**
```bash
cd rami/autocad/CommandBridgePlugin
dotnet build -c Release
```

### 4. Output Location

The DLL will be created at:
```
rami/autocad/CommandBridgePlugin/bin/Release/net8.0/FeatureMillwork.CommandBridge.dll
```

### 5. Load in AutoCAD

**Option A: Use LISP Loader**
1. In AutoCAD, type `APPLOAD`
2. Load `rami/autocad/load-bridge-plugin.lsp`
3. Type `LOADBRIDGE` to load the plugin

**Option B: Direct NETLOAD**
1. In AutoCAD, type `NETLOAD`
2. Browse to: `rami/autocad/CommandBridgePlugin/bin/Release/net8.0/FeatureMillwork.CommandBridge.dll`
3. Click "Open"

### 6. Test

Type `TESTBRIDGE` in AutoCAD to test the plugin.

---

## Current Limitations

**What It Captures:**
- ✅ Command names (LINE, CIRCLE, etc.)
- ✅ Command completion status
- ✅ Command cancellation
- ✅ Command failures

**What It Does NOT Capture (Yet):**
- ❌ Command line prompts ("Specify first point:", etc.)
- ❌ Interactive command output
- ❌ Full command line text

## To Capture Full Command Line Text

Capturing actual command line prompt text requires:
1. COM interop with AutoCAD's command line interface
2. Hooking into command line window events
3. Accessing the command line buffer directly

This is a more advanced implementation. The current plugin provides the foundation and can be extended.

---

## Troubleshooting

### "Cannot find AutoCAD DLLs"
- Verify AutoCAD installation path
- Update `HintPath` in `.csproj` file
- Ensure AutoCAD version matches

### "Plugin loads but doesn't capture text"
- This is expected - current version only captures command names
- Full text capture requires additional COM interop implementation

### "NETLOAD fails"
- Check that DLL exists in output folder
- Verify .NET 8.0 runtime is installed
- Check AutoCAD version compatibility





