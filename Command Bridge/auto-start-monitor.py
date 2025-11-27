#!/usr/bin/env python3
"""
auto-start-monitor.py
Simple auto-start: Just launch the monitor immediately
Location: Command Bridge root

When workspace opens, this starts the monitor which watches the bridge file.
When AutoCAD loads, all command line output appears in this terminal.
"""

import os
import sys

# Import monitor directly - no waiting, just start it
MONITOR_SCRIPT = os.path.join(os.path.dirname(__file__), 'rami', 'monitor', 'watch_bridge.py')

# Ensure project root is in path for imports
project_root = os.path.dirname(__file__)
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# Load and run monitor
import importlib.util
spec = importlib.util.spec_from_file_location("watch_bridge", MONITOR_SCRIPT)
if spec and spec.loader:
    monitor = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(monitor)
    # Monitor runs until Ctrl+C
else:
    print("⚠️ Failed to load monitor script")
    sys.exit(1)
