# AutoCAD-Monitor Graft

**Graft Type:** Integration  
**Location:** `grafts/autocad-monitor/`  
**Status:** **ACTIVE** (Core integration)

---

## Purpose

This graft defines the integration point between the AutoCAD ramus and the Monitor ramus. It enables one-way communication from AutoCAD to external monitoring tools via a file-based protocol.

**Key Principle:** This graft is **the only allowed method** for communication between the AutoCAD and Monitor rami. All interactions must pass through this defined protocol.

---

## Connected Rami

* **Producer:** `rami/autocad/` (AutoCAD ramus)
* **Consumer:** `rami/monitor/` (Monitor ramus)

---

## Allowed Data Flows

**Direction:** One-way only (AutoCAD → Monitor)

* ✅ AutoCAD writes messages to bridge file
* ✅ Monitor reads messages from bridge file
* ❌ Monitor does NOT write to bridge file
* ❌ AutoCAD does NOT read from bridge file

---

## Protocol Specification

### File Location

```
C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt
```

### File Format

**Type:** Plain text file  
**Mode:** Append-only (AutoCAD writes, Monitor reads)  
**Encoding:** UTF-8  
**Line Endings:** Platform-native (CRLF on Windows)

### Message Format

**Structure:** One message per line

```
<EVENT-TYPE>: <message>
```

**Examples:**
```
TEST: Command Bridge connection test
CMD-START: LINE
CMD-END: LINE
MONITOR: Command monitoring ENABLED
STATUS: Command Bridge status checked
SUCCESS: Test complete
```

### Event Types

| Event Type | Format | Description |
|------------|--------|-------------|
| `TEST` | `TEST: <message>` | Test messages |
| `CMD-START` | `CMD-START: <command>` | Command started |
| `CMD-END` | `CMD-END: <command>` | Command ended |
| `MONITOR` | `MONITOR: <status>` | Monitor state changes |
| `STATUS` | `STATUS: <message>` | Status messages |
| `SUCCESS` | `SUCCESS: <message>` | Success messages |
| `ERROR` | `ERROR: <message>` | Error messages |

---

## Mapping Rules

### AutoCAD Ramus → Bridge File

**Function:** `bridge-write(message)`

**Process:**
1. Check if bridge is enabled (`*bridge-enabled*`)
2. Open file in append mode (`"a"`)
3. Write message as single line
4. Close file immediately
5. Display message in AutoCAD command line (for user feedback)

**Error Handling:**
- If file cannot be opened, display error in AutoCAD
- No retry logic (basic implementation)
- Future: Use `sap/file-safety.lsp` for retry logic

### Bridge File → Monitor Ramus

**Process:**
1. Watch file for size changes
2. Read new lines from last known position
3. Parse each line as message
4. Pass to display formatter (via monitor-display graft)

**Error Handling:**
- If file doesn't exist, wait for creation
- If file is locked, wait and retry
- Future: Use `sap/file-safety.py` for retry logic

---

## Translation Rules

**No translation required** - Messages pass through as plain text strings.

**Future Enhancement:** If structured format is needed, translation could be added here.

---

## Orchestration

**None** - This graft is purely pass-through. No orchestration logic.

---

## Water Reference

See `water/message-flow.md` for complete event catalog and payload specifications.

---

## Implementation Details

### AutoCAD Side (`rami/autocad/command_bridge.lsp`)

```lisp
(defun bridge-write (message)
  "Write a message to the bridge file for monitoring"
  (if *bridge-enabled*
    (progn
      (setq file (open *bridge-file* "a"))
      (if file
        (progn
          (write-line message file)
          (close file)
          (princ (strcat "\n→ " message))
        )
        (princ (strcat "\n⚠️ Cannot write to bridge file"))
      )
    )
  )
)
```

### Monitor Side (`rami/monitor/watch_bridge.py`)

```python
# Watch file for changes
if os.path.exists(BRIDGE_FILE):
    current_size = os.path.getsize(BRIDGE_FILE)
    if current_size > last_size:
        with open(BRIDGE_FILE, 'r') as f:
            f.seek(last_position)
            new_lines = f.readlines()
            # Process new messages...
```

---

## Error Scenarios

### File Locked

**AutoCAD Side:**
- Current: Error message displayed
- Future: Retry with backoff (via sap)

**Monitor Side:**
- Current: Wait and retry on next iteration
- Future: Retry with backoff (via sap)

### File Not Found

**AutoCAD Side:**
- File will be created on first write

**Monitor Side:**
- Wait for file creation, then begin reading

### Permission Denied

**AutoCAD Side:**
- Error message displayed
- Future: Graceful degradation

**Monitor Side:**
- Error logged, continue waiting
- Future: Graceful degradation

---

## Performance Considerations

* **File I/O:** Small messages, fast writes
* **No Locking:** Append-only reduces contention
* **Polling:** Monitor checks every 100ms
* **Memory:** Only new lines read, not entire file

---

## Future Enhancements

* Add structured message format (JSON)
* Add message versioning
* Add message validation (via sap)
* Add retry logic with backoff (via sap)
* Add message queuing for high-volume scenarios

---

## Notes

* This graft is **critical** - it's the only communication channel
* Protocol is intentionally simple for reliability
* No bidirectional communication needed
* File-based approach ensures persistence across sessions

---

*Last updated: 2025-11-16*

