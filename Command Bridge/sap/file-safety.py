#!/usr/bin/env python3
"""
file-safety.py
Safe file operations with retry logic
Location: sap/

This is SAP (protective guardrails) for file operations
Used by: rami/monitor/watch_bridge.py
"""

import os
import time

# Configuration
SAP_MAX_RETRIES = 5
SAP_RETRY_DELAY = 1.5  # seconds


def safe_file_open_read(filepath, encoding='utf-8'):
    """
    Safely open file in read mode with retry logic
    
    Args:
        filepath: Path to file
        encoding: File encoding (default: utf-8)
    
    Returns:
        File handle or None if failed
    """
    retry_count = 0
    
    while retry_count < SAP_MAX_RETRIES:
        try:
            file = open(filepath, 'r', encoding=encoding)
            if retry_count > 0:
                print("✓ File opened successfully")
            return file
        except (IOError, OSError, PermissionError) as e:
            if retry_count == 0:
                print("⏳ File locked, retrying...")
            time.sleep(SAP_RETRY_DELAY)
            retry_count += 1
    
    print(f"⚠️ Failed to open file after {SAP_MAX_RETRIES} attempts: {filepath}")
    return None


def safe_file_exists(filepath):
    """
    Safely check if file exists
    
    Args:
        filepath: Path to file
    
    Returns:
        True if exists, False otherwise
    """
    try:
        return os.path.exists(filepath)
    except Exception:
        return False


def safe_file_size(filepath):
    """
    Safely get file size
    
    Args:
        filepath: Path to file
    
    Returns:
        File size in bytes, or 0 if error
    """
    try:
        return os.path.getsize(filepath)
    except Exception:
        return 0


def validate_path(filepath):
    """
    Validate file path and ensure directory exists
    
    Args:
        filepath: Path to file
    
    Returns:
        True if valid, False otherwise
    """
    dir_path = os.path.dirname(filepath)
    
    if not os.path.exists(dir_path):
        print(f"⚠️ Directory does not exist: {dir_path}")
        return False
    
    return True

