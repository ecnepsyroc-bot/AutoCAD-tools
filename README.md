# AutoCAD Command Line Monitoring Tool

## 🎯 Purpose
Real-time bridge between AutoCAD and VS Code that exponentially accelerates LISP development by providing instant feedback, error tracking, and performance metrics.

## 🚀 Key Features

### Real-Time Monitoring
- **Live Command Tracking** - See every AutoCAD command as it executes
- **LISP Execution Monitoring** - Track LISP expressions with timing data
- **Error Pattern Detection** - Automatically identifies common error types
- **Performance Metrics** - Execution times, error rates, commands/minute

### VS Code Integration
- **Instant Error Highlighting** - Errors appear directly in your LISP files
- **Command History** - Full session recording with export capability
- **Monitor Panel** - Live dashboard showing statistics and patterns
- **Bidirectional Communication** - Send commands from VS Code to AutoCAD

## 📊 Monitoring Dashboard
The monitor panel shows:
- Command count and error rate
- Average execution time
- Commands per minute
- Recent command history
- Top error patterns
- Session duration

## 🔧 Installation

### Quick Setup
1. Run `install.bat` as Administrator
2. Start AutoCAD 2024
3. Type `STARTBRIDGE` in AutoCAD
4. Open VS Code and press `Ctrl+Shift+M` to see monitor

### Manual Setup
```batch
# Build the .NET plugin
cd autocad-plugin
dotnet build -c Release

# In AutoCAD
NETLOAD
Select: bin\Release\FeatureMillwork.CommandBridge.dll
STARTBRIDGE

# In VS Code
F5 to launch extension
Ctrl+Shift+P → "AutoCAD Bridge: Connect"
```
## 💻 Usage

### AutoCAD Commands
- `STARTBRIDGE` - Start monitoring
- `STOPBRIDGE` - Stop monitoring  
- `TESTBRIDGE` - Send test message to VS Code

### VS Code Commands (Ctrl+Shift+P)
- `AutoCAD Bridge: Connect` - Connect to AutoCAD
- `AutoCAD Bridge: Show Monitor Panel` - Open monitoring dashboard
- `AutoCAD Bridge: Execute LISP` - Run current file/selection
- `AutoCAD Bridge: Send Command` - Send AutoCAD command
- `AutoCAD Bridge: Clear Log` - Clear output channel

### Keyboard Shortcuts
- `Ctrl+Shift+E` - Execute LISP code (when in .lsp file)
- `Ctrl+Shift+C` - Send AutoCAD command
- `Ctrl+Shift+M` - Show monitor panel

## 🔄 Development Workflow

### Rapid LISP Development
1. Write LISP code in VS Code
2. Press `Ctrl+Shift+E` to execute
3. Monitor panel shows execution time and errors
4. Errors highlight directly in your code
5. Fix and re-execute instantly

### Error Pattern Learning
The tool tracks error patterns to help identify:
- Common syntax errors
- Argument type mismatches
- Missing functions
- Selection errors
- Performance bottlenecks
## 🏗️ Architecture

### Named Pipe Communication
```
AutoCAD ←→ Named Pipe (AutoCADCommandBridge) ←→ VS Code
   ↓                                               ↓
CommandMonitor.cs                            extension.js
   ↓                                               ↓
Events & Hooks                              Monitor Panel
```

### Message Types
- `command_start/end` - AutoCAD command execution
- `lisp_start/end` - LISP expression execution
- `error` - Error messages with stack traces
- `prompt_*` - User prompts (string/point/selection)
- `sysvar` - System variable get/set

## 🎯 Badge Reflex Integration

This monitoring tool is KEY to developing the badge reflex system:

### Immediate Benefits
1. **Pattern Recognition** - See exactly how badge commands execute
2. **Error Diagnosis** - Instant feedback on badge processing errors
3. **Performance Tuning** - Identify slow badge operations
4. **Batch Testing** - Run multiple badge scenarios and track results

### Example Badge Development
```lisp
;; Write badge detection in VS Code
(defun detect-badge (entity)
  (get-badge-type entity))

;; Press Ctrl+Shift+E to execute
;; Monitor shows: "LISP: detect-badge - 45ms"
;; Errors appear inline if badge not found
```

## 📈 Performance Metrics

The tool tracks:
- Command execution times
- Error frequencies by type
- Commands per minute productivity
- Session statistics with export

## 🔮 Future Enhancements
- [ ] Badge-specific error patterns
- [ ] AutoCAD variable watchers
- [ ] Drawing state snapshots
- [ ] Team telemetry sharing
- [ ] AI-powered error suggestions

## 📝 Notes
- Works with AutoCAD 2023-2025
- Requires .NET Framework 4.8
- VS Code 1.74.0 or higher
- Named pipe: `\\.\pipe\AutoCADCommandBridge`

---
Built for Feature Millwork's 18-month automation timeline