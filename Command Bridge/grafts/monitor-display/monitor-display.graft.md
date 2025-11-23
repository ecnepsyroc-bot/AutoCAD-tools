# Monitor-Display Graft

**Graft Type:** Integration  
**Location:** `grafts/monitor-display/`  
**Status:** **ACTIVE** (Core integration)

---

## Purpose

This graft defines the integration point between the Monitor ramus and the Leaves (presentation layer). It maps parsed messages to formatted display output.

**Key Principle:** This graft handles **formatting rules only**. Display logic itself lives in `leaves/terminal-formatter.py`. This graft defines the mapping contract.

---

## Connected Rami

* **Producer:** `rami/monitor/` (Monitor ramus)
* **Consumer:** `leaves/` (Terminal formatter)

---

## Allowed Data Flows

**Direction:** One-way only (Monitor → Display)

* ✅ Monitor passes parsed messages to formatter
* ✅ Formatter returns formatted strings
* ✅ Monitor displays formatted strings
* ❌ Formatter does NOT read from bridge file
* ❌ Formatter does NOT parse messages

---

## Protocol Specification

### Input Format

**Type:** Plain text message string

```
<EVENT-TYPE>: <message>
```

**Examples:**
```
TEST: Command Bridge connection test
CMD-START: LINE
SUCCESS: Test complete
ERROR: File not found
```

### Output Format

**Type:** Formatted string with timestamp and emoji

```
[HH:MM:SS] <emoji> <message>
```

**Examples:**
```
[09:13:39] 🧪 TEST: Command Bridge connection test
[09:13:40] ⚡ CMD-START: LINE
[09:13:41] ✅ SUCCESS: Test complete
[09:13:42] ❌ ERROR: File not found
```

---

## Mapping Rules

### Message Type → Emoji Mapping

| Message Pattern | Emoji | Example |
|----------------|-------|---------|
| Contains `ERROR` | ❌ | `ERROR: File not found` |
| Contains `SUCCESS` or `COMPLETE` | ✅ | `SUCCESS: Test complete` |
| Contains `FOUND` or `DETECTED` | 🔍 | `FOUND: 5 badges` |
| Starts with `CMD` | ⚡ | `CMD-START: LINE` |
| Starts with `TEST` | 🧪 | `TEST: Connection test` |
| Contains `MONITOR` | 📡 | `MONITOR: ENABLED` |
| File reset | 🔄 | `Bridge file was reset` |
| Default | → | `STATUS: Bridge active` |

### Timestamp Format

**Format:** `[HH:MM:SS]`  
**Example:** `[09:13:39]`  
**Source:** Current system time when message is displayed

---

## Translation Rules

### Step 1: Parse Message

**Input:** Raw message line from bridge file  
**Output:** Message type and content

```python
message = "TEST: Command Bridge connection test"
# Extract: type="TEST", content="Command Bridge connection test"
```

### Step 2: Select Emoji

**Input:** Message type and content  
**Output:** Appropriate emoji

```python
if 'ERROR' in message.upper():
    emoji = "❌"
elif 'SUCCESS' in message.upper():
    emoji = "✅"
# ... etc
```

### Step 3: Format Timestamp

**Input:** Current time  
**Output:** Formatted timestamp

```python
timestamp = datetime.now().strftime('%H:%M:%S')
# Result: "[09:13:39]"
```

### Step 4: Combine

**Input:** Timestamp, emoji, message  
**Output:** Formatted display string

```python
output = f"[{timestamp}] {emoji} {message}"
# Result: "[09:13:39] 🧪 TEST: Command Bridge connection test"
```

---

## Orchestration

**None** - This graft is purely formatting. No orchestration logic.

---

## Implementation Details

### Current Implementation (Mixed in Monitor)

**Location:** `rami/monitor/watch_bridge.py` (lines 55-76)

```python
# Format based on content
if 'ERROR' in message.upper():
    output = f"[{timestamp}] ❌ {message}"
elif 'SUCCESS' in message.upper() or 'COMPLETE' in message.upper():
    output = f"[{timestamp}] ✅ {message}"
# ... etc
```

### Future Implementation (Extracted to Leaves)

**Location:** `leaves/terminal-formatter.py`

```python
def format_message(message, timestamp):
    """Format message for terminal display"""
    emoji = select_emoji(message)
    return f"[{timestamp}] {emoji} {message}"
```

**Usage in Monitor:**
```python
from leaves.terminal_formatter import format_message

output = format_message(message, timestamp)
print(output)
```

---

## Error Scenarios

### Invalid Message Format

**Handling:**
- Default to `→` emoji
- Display message as-is
- No error thrown

### Missing Timestamp

**Handling:**
- Use current time
- Never fail on timestamp

### Encoding Issues

**Handling:**
- UTF-8 encoding
- Replace invalid characters
- Never crash on encoding

---

## Performance Considerations

* **Formatting:** O(1) operation, very fast
* **Emoji Selection:** Simple string matching
* **Timestamp:** System call, minimal overhead
* **No I/O:** Pure string manipulation

---

## Future Enhancements

* Add color coding (ANSI codes)
* Add message filtering
* Add message grouping
* Add structured output (JSON mode)
* Add log levels (DEBUG, INFO, WARN, ERROR)

---

## Notes

* This graft is **presentation-only** - no business logic
* Formatting rules are **declarative** - easy to modify
* Current implementation is **mixed** in monitor ramus
* Future refactoring will **extract** to leaves/

---

*Last updated: 2025-11-16*

