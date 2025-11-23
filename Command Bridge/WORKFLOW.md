# Command Bridge - Workflow Guide

## The Simple Workflow

### What You Want
1. Open AutoCAD
2. Type `TEST` in AutoCAD command line
3. See output automatically in Cursor terminal

### How It Works

**Setup (One Time):**
1. Open Command Bridge workspace in Cursor
2. Monitor auto-starts (or run `python "auto-start-monitor.py"`)

**Daily Use:**
1. Open AutoCAD
2. Load Command Bridge: `APPLOAD` → Browse to `rami/autocad/command_bridge.lsp` → Load
3. Type `TEST` in AutoCAD
4. **Messages automatically appear in Cursor terminal**

---

## Step-by-Step

### 1. Start Monitor in Cursor

**Option A: Auto-Start (Recommended)**
- Open Command Bridge workspace
- Monitor should auto-start (configured in `.vscode/tasks.json`)
- If not, run: `python "auto-start-monitor.py"`

**Option B: Manual Start**
- In Cursor terminal: `python "auto-start-monitor.py"`
- You'll see: "Waiting for Command Bridge to load..."

### 2. Load Command Bridge in AutoCAD

1. In AutoCAD, type: `APPLOAD`
2. Browse to: `C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\rami\autocad\command_bridge.lsp`
3. Click "Load" then "Close"
4. You should see the Command Bridge menu in AutoCAD

**What happens:**
- AutoCAD writes "=== COMMAND BRIDGE LOADED ===" to the bridge file
- The monitor in Cursor detects this
- Monitor automatically switches to active monitoring mode
- You'll see: "SWITCHING TO MONITOR MODE"

### 3. Test Connection

**In AutoCAD:**
- Type `TEST` and press Enter

**In Cursor terminal:**
- You should immediately see:
  ```
  [HH:MM:SS] 🧪 TEST: Command Bridge connection test
  [HH:MM:SS] 🧪 TEST: If you see this, monitoring is working!
  [HH:MM:SS] ✅ SUCCESS: Test complete
  ```

---

## Troubleshooting

### "Monitor not starting automatically"

**Fix:** Run manually in Cursor terminal:
```powershell
python "auto-start-monitor.py"
```

### "TEST command doesn't show in Cursor"

**Check 1:** Is monitor running?
- Look for "COMMAND BRIDGE - WATCHING FOR MESSAGES" in terminal
- If not, start it with `python "auto-start-monitor.py"`

**Check 2:** Is Command Bridge loaded in AutoCAD?
- Type `STATUS` in AutoCAD
- If you get "Unknown command", reload with APPLOAD

**Check 3:** Is the bridge file being written?
- Check: `Logs/autocad_bridge.txt`
- Should contain "=== COMMAND BRIDGE LOADED ==="

### "Auto-start not working on workspace open"

**Fix:** The task is configured but may need manual trigger:
- Press `Ctrl+Shift+P` → "Tasks: Run Task" → "Bridge: Auto-Start Monitor"
- Or run directly: `python "auto-start-monitor.py"`

---

## File Locations

- **AutoCAD LISP:** `rami/autocad/command_bridge.lsp`
- **Monitor Script:** `rami/monitor/watch_bridge.py`
- **Auto-Start Script:** `auto-start-monitor.py`
- **Bridge File:** `Logs/autocad_bridge.txt`

---

*Last updated: 2025-11-18*

