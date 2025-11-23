# Monitor Ramus

**Ramus Type:** Core Module  
**Location:** `rami/monitor/`  
**File:** `watch_bridge.py`

---

## Purpose

The Monitor ramus watches the bridge file for new messages and parses them for display. It provides the core file-watching and message-reading logic.

**Key Principle:** This ramus **only reads** from the bridge file and parses messages. Display formatting should be handled by leaves, but is currently mixed in for simplicity.

---

## Responsibilities

* ✅ Watch `Logs/autocad_bridge.txt` for changes
* ✅ Read new messages from bridge file
* ✅ Parse message lines
* ✅ Track file position and size
* ✅ Handle file resets/clears
* ✅ Core monitoring loop logic

---

## Non-Responsibilities

* ❌ Display formatting (leaves responsibility - currently mixed)
* ❌ Emoji selection (leaves responsibility - currently mixed)
* ❌ Timestamp formatting (leaves responsibility - currently mixed)
* ❌ AutoCAD LISP code
* ❌ File writing (autocad ramus responsibility)
* ❌ Terminal UI (leaves responsibility - currently mixed)

---

## Public API

### Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `watch_bridge()` | Main monitoring loop | `None` (runs until Ctrl+C) |

### Configuration

| Variable | Type | Description |
|----------|------|-------------|
| `BRIDGE_FILE` | String | Path to bridge file |

---

## Water Interface

### Events Consumed

Reads plain text messages from bridge file:

* `TEST: <message>` - Test messages
* `CMD-START: <command>` - Command started
* `CMD-END: <command>` - Command ended
* `MONITOR: <status>` - Monitor state changes
* `STATUS: <message>` - Status messages
* `SUCCESS: <message>` - Success messages
* `ERROR: <message>` - Error messages

### Event Format

```
<EVENT-TYPE>: <message>
```

Example:
```
TEST: Command Bridge connection test
CMD-START: LINE
CMD-END: LINE
```

---

## Grafts

### `grafts/autocad-monitor/`

**Connection:** AutoCAD ramus → Monitor ramus

**Protocol:**
- File: `Logs/autocad_bridge.txt`
- Format: Plain text, append-only
- Direction: One-way (AutoCAD → Monitor)

See `grafts/autocad-monitor/autocad-monitor.graft.md` for details.

### `grafts/monitor-display/`

**Connection:** Monitor ramus → Leaves

**Protocol:**
- Format: Timestamp + emoji + message
- Direction: Monitor → Display

**Note:** Currently mixed in `watch_bridge.py`. Should be extracted to `leaves/terminal-formatter.py`.

See `grafts/monitor-display/monitor-display.graft.md` for details.

---

## Dependencies

**None** - Uses only:
- Python 3.x standard library
- `os`, `time`, `datetime` modules

---

## Configuration

### Bridge File Path

```python
BRIDGE_FILE = r'C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt'
```

**To change:** Edit line 11 in `watch_bridge.py`

---

## Error Handling

**Current:** Basic file existence check, waits for file creation

**Future:** Should use `sap/file-safety.py` for:
- Retry logic on file locks
- Permission error handling
- Path validation
- Message validation via `sap/message-validator.py`

---

## Current Implementation Notes

**⚠️ Mixed Responsibilities:**

The current `watch_bridge.py` mixes monitor logic (rami) with display formatting (leaves):

- Lines 55-76: Display formatting logic (should be in `leaves/terminal-formatter.py`)
- Lines 38-85: File watching logic (correct - ramus responsibility)

**Future Refactoring:**
- Extract formatting to `leaves/terminal-formatter.py`
- Import formatter in monitor
- Keep only file watching and parsing in monitor ramus

---

## Notes

* This ramus is **completely isolated** from AutoCAD logic
* No knowledge of how messages are produced
* Pure consumer role in the architecture
* File-based communication is the only integration point

---

*Last updated: 2025-11-16*

