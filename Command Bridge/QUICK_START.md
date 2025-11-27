# Command Bridge - Quick Start

## Standard Workflow

### Step 1: Open Command Bridge Workspace in Cursor
- Open the Command Bridge folder in Cursor/VS Code
- The monitor should auto-start (if configured)
- **OR** manually run: `python "auto-start-monitor.py"` in terminal
- You'll see: "Waiting for Command Bridge to load..."

### Step 2: Load Command Bridge in AutoCAD

**Path to load:**
```
C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\rami\autocad\command_bridge.lsp
```

**Steps:**
1. In AutoCAD, type `APPLOAD`
2. Browse to the path above
3. Click "Load" then "Close"
4. You should see the Command Bridge menu in AutoCAD
5. **The monitor in Cursor will automatically detect this and switch to monitor mode**

### Step 3: Test Connection

**In AutoCAD command line:**
- Type `TEST` and press Enter
- **You should immediately see test messages appear in the Cursor terminal**

That's it! The workflow is:
1. ✅ Open Cursor workspace → Monitor auto-starts
2. ✅ Load LISP in AutoCAD → Monitor detects and switches to active mode
3. ✅ Type `TEST` in AutoCAD → Messages appear in Cursor terminal

---

## Alternative: Manual Monitor Start

If auto-start doesn't work, you can manually start the monitor:

**In Cursor terminal:**
```powershell
python "auto-start-monitor.py"
```

This will:
- Wait for Command Bridge to load
- Automatically switch to monitor mode when detected
- Display all AutoCAD commands in real-time

---

## Available Commands in AutoCAD

- `TEST` - Test connection (messages appear in Cursor terminal)
- `STATUS` - Check bridge status
- `MONITOR-ON` - Enable command tracking
- `MONITOR-OFF` - Stop tracking

---

## Troubleshooting

### "Command bridge is not active"

**Check 1: Is the LISP file loaded?**
- Type `STATUS` in AutoCAD
- If you get "Unknown command", the file isn't loaded
- Reload using APPLOAD

**Check 2: Is the monitor running?**
- Look for console window showing "COMMAND BRIDGE - WATCHING FOR MESSAGES"
- If not running, start it with `RUN_BRIDGE.bat`

**Check 3: Check for errors**
- In AutoCAD, check command line for error messages
- Common issue: SAP file not found (should auto-load)

**Check 4: File permissions**
- Ensure `Logs/autocad_bridge.txt` is writable
- Check OneDrive sync status

---

## File Locations

- **AutoCAD LISP:** `rami/autocad/command_bridge.lsp`
- **Monitor Script:** `rami/monitor/watch_bridge.py`
- **Bridge File:** `Logs/autocad_bridge.txt`
- **Launcher:** `RUN_BRIDGE.bat`

---

*Last updated: 2025-11-16*

