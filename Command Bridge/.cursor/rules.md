# Command Bridge - Cursor Rules

## Project Overview
This is a Command Bridge system for Feature Millwork that enables real-time monitoring of AutoCAD commands via file-based communication between AutoCAD (LISP) and Python.

## File Structure
- `command_bridge.lsp` - AutoCAD LISP script that writes commands to bridge file
- `command_bridge_monitor.py` - Python monitor that watches the bridge file
- `Logs/` - Contains bridge file and monitor logs
- `.cursor/rules.md` - This file

## Code Style Guidelines

### Python
- Use Python 3 syntax
- Follow PEP 8 style guidelines
- Use descriptive variable names
- Include docstrings for functions
- Use f-strings for string formatting
- Handle file operations with proper error handling
- Use absolute paths for OneDrive locations

### LISP (AutoCAD)
- Use AutoLISP conventions
- Prefix global variables with `*` (e.g., `*bridge-file*`)
- Use descriptive function names with `c:` prefix for commands
- Include comments explaining complex logic
- Use `princ` for user feedback
- Handle file operations with error checking

## Path Conventions
- All paths use Windows format with backslashes
- OneDrive base path: `C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\`
- Bridge file: `Logs\autocad_bridge.txt`
- Log file: `Logs\monitor.log`

## Key Principles
1. **File-based communication**: Use file watching rather than direct inter-process communication
2. **Real-time monitoring**: Monitor should display messages as they arrive
3. **Error handling**: Always check file operations and handle errors gracefully
4. **User feedback**: Provide clear status messages in both AutoCAD and monitor
5. **Logging**: Maintain logs for debugging and audit purposes

## When Making Changes
- Test with the `TEST` command in AutoCAD
- Verify monitor receives messages correctly
- Check log files for errors
- Ensure paths are correct for OneDrive location
- Maintain backward compatibility with existing commands


