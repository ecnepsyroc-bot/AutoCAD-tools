# Badges-Command Bridge Graft

**Graft Type:** Integration  
**Location:** `grafts/badges-command-bridge/`  
**Status:** **NOT IMPLEMENTED** (Optional future integration)

---

## Purpose

This graft defines the integration point between the Badges branch and the Command Bridge branch. It would enable optional monitoring of badge operations through the Command Bridge system.

**Important:** This integration is **optional** and **not implemented by default**. The Badges branch is designed to operate completely independently.

---

## Integration Design

### When Enabled

If this graft is implemented, badge operations could send messages to the Command Bridge:

* Badge creation events
* Badge insertion events
* Badge update events
* Badge extraction events
* Error events

### Message Format (Water)

```lisp
{
  type: "BADGE",
  operation: "CREATE" | "INSERT" | "UPDATE" | "EXTRACT" | "ERROR",
  badgeCode: string,
  jobName: string,
  timestamp: string,
  details: object
}
```

### Example Messages

```
BADGE: CREATE - Job: NETFLIX, Badges: 45
BADGE: INSERT - Code: PL1, Location: (100, 200)
BADGE: UPDATE - Updated: 12 badges from CSV
BADGE: ERROR - Failed to read CSV: file locked
```

---

## Implementation Requirements

### Prerequisites

1. Command Bridge must be loaded and active
2. Badge system must detect bridge availability
3. Opt-in mechanism (user must enable integration)

### Integration Points

**In Badges Branch:**
- Add optional bridge-write calls
- Check for bridge availability before writing
- Graceful degradation if bridge unavailable

**In Command Bridge:**
- Add badge message formatting
- Add badge-specific emoji indicators
- Filter badge messages if needed

---

## Current Status

**NOT IMPLEMENTED**

The Badges branch operates independently. This graft document exists to:
- Define future integration design
- Document the interface contract
- Guide future implementation

---

## Design Principles

1. **Opt-In Only**
   - Integration must be explicitly enabled
   - Default behavior: no bridge communication

2. **Graceful Degradation**
   - Badge system works without bridge
   - No errors if bridge unavailable
   - Bridge failures don't affect badge operations

3. **Minimal Coupling**
   - Badge system doesn't require bridge
   - Bridge doesn't require badges
   - Integration is additive, not required

4. **Clear Boundaries**
   - Badge operations continue normally
   - Bridge only receives messages
   - No bidirectional control flow

---

## Future Implementation

If this graft is implemented:

1. Add bridge detection to `BadgeInit.lsp`
2. Add optional bridge-write calls to key operations
3. Create bridge message formatting functions
4. Add user command to enable/disable integration
5. Update Command Bridge to handle badge messages

---

## Notes

* This is a **future enhancement**, not a current requirement
* Badge system is fully functional without this integration
* Integration would be purely for monitoring/debugging
* No functional dependencies between systems

---

*Last updated: 2025-11-15*

