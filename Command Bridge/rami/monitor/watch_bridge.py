#!/usr/bin/env python3
"""
Simple bridge file watcher for Cursor terminal
Shows messages in real-time without clearing screen
Location: rami/monitor/
"""

import os
import sys
import time
from datetime import datetime

# Import SAP (file safety and validation)
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# Import SAP modules (using importlib due to hyphenated filenames)
import importlib.util
sap_file_safety_path = os.path.join(project_root, 'sap', 'file-safety.py')
spec = importlib.util.spec_from_file_location("file_safety", sap_file_safety_path)
file_safety = importlib.util.module_from_spec(spec)
spec.loader.exec_module(file_safety)
safe_file_exists = file_safety.safe_file_exists
safe_file_size = file_safety.safe_file_size

sap_validator_path = os.path.join(project_root, 'sap', 'message-validator.py')
spec = importlib.util.spec_from_file_location("message_validator", sap_validator_path)
message_validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(message_validator)
validate_message = message_validator.validate_message

# Import GRAFT API (thin external API to leaves)
# Use direct path import to avoid module name issues
graft_api_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'grafts', 'monitor-display', 'display-api.py'))
import importlib.util
spec = importlib.util.spec_from_file_location("display_api", graft_api_path)
display_api = importlib.util.module_from_spec(spec)
spec.loader.exec_module(display_api)
format_for_display = display_api.format_for_display
format_reset_for_display = display_api.format_reset_for_display

BRIDGE_FILE = r'C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt'

print("=" * 70)
print(" COMMAND BRIDGE - WATCHING FOR MESSAGES")
print("=" * 70)
print(f" Watching: {BRIDGE_FILE}")
print(" Press Ctrl+C to stop")
print("=" * 70)
print()

# Track last position
last_position = 0
last_size = 0

# Initialize - read current file size
if safe_file_exists(BRIDGE_FILE):
    last_size = safe_file_size(BRIDGE_FILE)
    # Read to end (skip any existing content)
    with open(BRIDGE_FILE, 'r') as f:
        f.seek(0, 2)  # Seek to end
        last_position = f.tell()
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Monitor started - waiting for new messages...")
    print()
else:
    print(f"⚠️  Bridge file not found. Waiting for it to be created...")
    print()

try:
    while True:
        if safe_file_exists(BRIDGE_FILE):
            current_size = safe_file_size(BRIDGE_FILE)
            
            if current_size > last_size:
                # New content added
                with open(BRIDGE_FILE, 'r') as f:
                    f.seek(last_position)
                    new_lines = f.readlines()
                    last_position = f.tell()
                    last_size = current_size
                    
                    # Display new messages using GRAFT API
                    for line in new_lines:
                        # Validate message using SAP
                        message = validate_message(line)
                        if message:
                            # Format using GRAFT API (which calls leaves)
                            output = format_for_display(message)
                            print(output)
                            # Flush immediately so it appears right away
                            sys.stdout.flush()
            
            elif current_size < last_size:
                # File was cleared/reset
                last_position = 0
                last_size = current_size
                # Format reset message using GRAFT API
                output = format_reset_for_display()
                print(output)
        
        time.sleep(0.1)  # Check every 100ms

except KeyboardInterrupt:
    print()
    print("=" * 70)
    print(" Monitor stopped")
    print("=" * 70)
    sys.exit(0)
