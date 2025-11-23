#!/usr/bin/env python3
"""
display-api.py
Thin API layer for Monitor ramus to access Leaves
Location: grafts/monitor-display/

This is the thin external API that allows Monitor ramus to access
Leaves without direct import, as required by Luxify Architecture.
"""

import sys
import os

# Add project root to path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# Import leaves (presentation layer) using importlib (hyphenated filename)
import importlib.util
leaves_formatter_path = os.path.join(project_root, 'leaves', 'terminal-formatter.py')
spec = importlib.util.spec_from_file_location("terminal_formatter", leaves_formatter_path)
terminal_formatter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(terminal_formatter)
_format_message = terminal_formatter.format_message
_format_reset_message = terminal_formatter.format_reset_message

# Import emoji rules from same graft directory
graft_dir = os.path.dirname(__file__)
emoji_rules_path = os.path.join(graft_dir, 'emoji-rules.py')
spec = importlib.util.spec_from_file_location("emoji_rules", emoji_rules_path)
emoji_rules = importlib.util.module_from_spec(spec)
spec.loader.exec_module(emoji_rules)
select_emoji_for_message = emoji_rules.select_emoji_for_message


def format_for_display(message):
    """
    Format message for terminal display (thin API wrapper)
    
    This function provides the translation layer between Monitor ramus
    and Leaves, implementing the emoji selection rules defined in the graft.
    
    Args:
        message: Message string from monitor
    
    Returns:
        Formatted display string
    """
    # Apply graft-level translation (emoji selection)
    emoji = select_emoji_for_message(message)
    
    # Call leaves for pure presentation
    return _format_message(message, emoji)


def format_reset_for_display():
    """
    Format file reset message for terminal display (thin API wrapper)
    
    Returns:
        Formatted reset message
    """
    return _format_reset_message()

