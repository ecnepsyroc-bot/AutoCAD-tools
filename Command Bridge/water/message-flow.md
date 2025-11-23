# Message Flow Specification (Water)

**Version:** 1.0  
**Last Updated:** 2025-11-16

---

## Purpose

This document defines the **event catalog** and **payload specifications** for the Command Bridge system. All events flowing through the system are declared here.

**Key Principle:** Water is **declarative only** - no business logic, no orchestration. Just event names, payload shapes, and producer/consumer relationships.

---

## Event Catalog

### Event: `TEST`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Test messages for connection verification.

**Payload:**
```
TEST: <message>
```

**Examples:**
```
TEST: Command Bridge connection test
TEST: If you see this, monitoring is working!
```

**Fields:**
- `message` (string): Test message content

---

### Event: `CMD-START`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Indicates an AutoCAD command has started.

**Payload:**
```
CMD-START: <command>
```

**Examples:**
```
CMD-START: LINE
CMD-START: CIRCLE
CMD-START: MOVE
```

**Fields:**
- `command` (string): AutoCAD command name (uppercase)

---

### Event: `CMD-END`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Indicates an AutoCAD command has ended.

**Payload:**
```
CMD-END: <command>
```

**Examples:**
```
CMD-END: LINE
CMD-END: CIRCLE
CMD-END: MOVE
```

**Fields:**
- `command` (string): AutoCAD command name (uppercase)

---

### Event: `MONITOR`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Indicates monitor state changes.

**Payload:**
```
MONITOR: <status>
```

**Examples:**
```
MONITOR: Command monitoring ENABLED
MONITOR: Command monitoring DISABLED
```

**Fields:**
- `status` (string): Monitor status message

---

### Event: `STATUS`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Status messages from AutoCAD.

**Payload:**
```
STATUS: <message>
```

**Examples:**
```
STATUS: Command Bridge status checked
STATUS: Bridge file exists
```

**Fields:**
- `message` (string): Status message content

---

### Event: `SUCCESS`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Success messages.

**Payload:**
```
SUCCESS: <message>
```

**Examples:**
```
SUCCESS: Test complete
SUCCESS: Bridge file cleared
```

**Fields:**
- `message` (string): Success message content

---

### Event: `ERROR`

**Version:** 1.0  
**Producer:** `rami/autocad/` (AutoCAD ramus)  
**Consumer:** `rami/monitor/` (Monitor ramus)

**Purpose:** Error messages.

**Payload:**
```
ERROR: <message>
```

**Examples:**
```
ERROR: Cannot write to bridge file
ERROR: File not found
```

**Fields:**
- `message` (string): Error message content

---

## Message Format

### General Structure

All messages follow this format:

```
<EVENT-TYPE>: <payload>
```

**Rules:**
- One message per line
- Event type is uppercase
- Colon and space separate type from payload
- Payload is plain text string
- No newlines in payload
- UTF-8 encoding

### File Format

**File:** `Logs/autocad_bridge.txt`  
**Mode:** Append-only  
**Encoding:** UTF-8  
**Line Endings:** Platform-native (CRLF on Windows)

**Example File Content:**
```
=== AUTOCAD SESSION STARTED ===
Time: 2025-11-16 09:13:21
Drawing: Drawing1.dwg
=== COMMAND BRIDGE LOADED ===
TEST: Command Bridge connection test
TEST: If you see this, monitoring is working!
SUCCESS: Test complete
```

---

## Producer/Consumer Matrix

| Event | Producer | Consumer |
|-------|----------|----------|
| `TEST` | `rami/autocad/` | `rami/monitor/` |
| `CMD-START` | `rami/autocad/` | `rami/monitor/` |
| `CMD-END` | `rami/autocad/` | `rami/monitor/` |
| `MONITOR` | `rami/autocad/` | `rami/monitor/` |
| `STATUS` | `rami/autocad/` | `rami/monitor/` |
| `SUCCESS` | `rami/autocad/` | `rami/monitor/` |
| `ERROR` | `rami/autocad/` | `rami/monitor/` |

---

## Versioning

### Version 1.0 (Current)

**Date:** 2025-11-16  
**Status:** Active

**Changes:**
- Initial event catalog
- Plain text format
- One-way communication (AutoCAD → Monitor)

### Future Versions

**Version 2.0 (Planned):**
- Structured format (JSON)
- Message metadata (timestamp, source)
- Bidirectional communication (if needed)

**Migration Path:**
- Version 1.0 messages remain valid
- Version 2.0 messages use JSON format
- Monitor detects format and handles both

---

## Notes

* All events are **optional** - producers may not emit all event types
* Consumers should handle **unknown event types** gracefully
* Message format is **intentionally simple** for reliability
* No validation in water - validation happens in sap/

---

*Last updated: 2025-11-16*

