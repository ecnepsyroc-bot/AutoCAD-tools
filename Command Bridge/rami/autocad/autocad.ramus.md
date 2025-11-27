# AutoCAD Ramus

**Ramus Type:** Core Module  
**Location:** `rami/autocad/`  
**File:** `command_bridge.lsp`

---

## Purpose

The AutoCAD ramus captures AutoCAD commands and writes messages to the bridge file for real-time monitoring. It provides a one-way communication channel from AutoCAD to external monitoring tools.

**Key Principle:** This ramus **only writes** to the bridge file. It contains no display logic, no parsing, and no Python integration.

---

## Responsibilities

* ✅ Capture AutoCAD commands via reactor
* ✅ Generate formatted messages
* ✅ Write messages to `Logs/autocad_bridge.txt`
* ✅ Manage command reactor lifecycle
* ✅ Provide user commands (TEST, STATUS, MONITOR-ON, MONITOR-OFF)
* ✅ Initialize bridge file on load

---

## Non-Responsibilities

* ❌ Display logic (leaves responsibility)
* ❌ Message parsing (monitor ramus responsibility)
* ❌ File watching (monitor ramus responsibility)
* ❌ Python integration
* ❌ Terminal output formatting
* ❌ Error recovery beyond basic file checks

---

## Public API

### Commands

| Command | Description | Water Event |
|---------|-------------|-------------|
| `TEST` | Test bridge connection | `TEST: ...` |
| `STATUS` | Show bridge status | `STATUS: ...` |
| `MONITOR-ON` | Enable command monitoring | `MONITOR: Command monitoring ENABLED` |
| `MONITOR-OFF` | Disable command monitoring | `MONITOR: Command monitoring DISABLED` |

### Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `bridge-write` | Write message to bridge file | `nil` |
| `bridge-clear` | Clear bridge file | `nil` |
| `log-command-start` | Reactor callback for command start | `nil` |
| `log-command-end` | Reactor callback for command end | `nil` |

### Global Variables

| Variable | Type | Description |
|----------|------|-------------|
| `*bridge-file*` | String | Path to bridge file |
| `*bridge-enabled*` | Boolean | Bridge enabled flag |
| `*command-reactor*` | Reactor | Command reactor object |

---

## Water Interface

### Events Produced

All events are written as plain text, one message per line:

* `TEST: <message>` - Test messages
* `CMD-START: <command>` - Command started
* `CMD-END: <command>` - Command ended
* `MONITOR: <status>` - Monitor state changes
* `STATUS: <message>` - Status messages
* `SUCCESS: <message>` - Success messages
* `ERROR: <message>` - Error messages (if implemented)

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

---

## Dependencies

**None** - Uses only:
- AutoCAD LISP (built-in)
- Visual LISP extensions (`vl-load-com`)

---

## Configuration

### Bridge File Path

```lisp
(setq *bridge-file* "C:\\Users\\cory\\OneDrive\\_Feature_Millwork\\Command Bridge\\Logs\\autocad_bridge.txt")
```

**To change:** Edit line 8 in `command_bridge.lsp`

---

## Error Handling

**Current:** Basic file existence check, error message on failure

**Future:** Should use `sap/file-safety.lsp` for:
- Retry logic on file locks
- Permission error handling
- Path validation

---

## Notes

* This ramus is **completely isolated** from monitor logic
* No knowledge of how messages are consumed
* Pure producer role in the architecture
* File-based communication is the only integration point

---

*Last updated: 2025-11-16*

