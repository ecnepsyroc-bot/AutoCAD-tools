"""
Test utilities module
"""

import pytest
import os
import tempfile
from autocad_tools.utils import (
    format_coordinate,
    calculate_distance,
    create_excel_workbook,
    save_excel
)


def test_format_coordinate():
    """Test coordinate formatting."""
    assert format_coordinate(1.23456, 2) == "1.23"
    assert format_coordinate(1.23456, 3) == "1.235"
    assert format_coordinate(100.0, 1) == "100.0"


def test_calculate_distance():
    """Test distance calculation."""
    p1 = (0, 0, 0)
    p2 = (3, 4, 0)
    assert calculate_distance(p1, p2) == 5.0
    
    p1 = (0, 0, 0)
    p2 = (1, 1, 1)
    assert abs(calculate_distance(p1, p2) - 1.732) < 0.01


def test_create_excel_workbook():
    """Test Excel workbook creation."""
    wb, ws = create_excel_workbook("Test Sheet")
    assert wb is not None
    assert ws is not None
    assert ws.title == "Test Sheet"


def test_save_excel():
    """Test Excel file saving."""
    wb, ws = create_excel_workbook("Test")
    ws.cell(row=1, column=1, value="Test Value")
    
    with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
        tmp_path = tmp.name
    
    try:
        save_excel(wb, tmp_path)
        assert os.path.exists(tmp_path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
