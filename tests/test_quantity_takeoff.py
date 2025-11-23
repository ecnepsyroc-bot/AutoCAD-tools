"""
Test quantity takeoff
"""

import pytest
import os
import tempfile
import ezdxf
from autocad_tools import QuantityTakeoff


@pytest.fixture
def sample_dxf_geometry():
    """Create a sample DXF file with geometry for testing."""
    doc = ezdxf.new('R2010')
    msp = doc.modelspace()
    
    # Add lines
    msp.add_line((0, 0, 0), (10, 0, 0), dxfattribs={'layer': 'LINES'})
    msp.add_line((10, 0, 0), (10, 10, 0), dxfattribs={'layer': 'LINES'})
    
    # Add circles
    msp.add_circle((20, 20, 0), radius=5, dxfattribs={'layer': 'CIRCLES'})
    msp.add_circle((30, 30, 0), radius=3, dxfattribs={'layer': 'CIRCLES'})
    
    # Add a closed polyline (rectangle)
    points = [(0, 0), (10, 0), (10, 5), (0, 5)]
    msp.add_lwpolyline(points, close=True, dxfattribs={'layer': 'POLYLINES'})
    
    with tempfile.NamedTemporaryFile(suffix='.dxf', delete=False) as tmp:
        tmp_path = tmp.name
    
    doc.saveas(tmp_path)
    yield tmp_path
    
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)


def test_count_entities(sample_dxf_geometry):
    """Test counting entities."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    
    line_count = takeoff.count_entities('LINE')
    assert line_count == 2
    
    circle_count = takeoff.count_entities('CIRCLE')
    assert circle_count == 2


def test_count_entities_by_layer(sample_dxf_geometry):
    """Test counting entities by layer."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    
    circle_count = takeoff.count_entities('CIRCLE', layer='CIRCLES')
    assert circle_count == 2


def test_measure_lengths(sample_dxf_geometry):
    """Test measuring lengths."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    
    length_data = takeoff.measure_lengths()
    assert length_data['total_length'] > 0
    assert 'entity_counts' in length_data


def test_measure_areas(sample_dxf_geometry):
    """Test measuring areas."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    
    area_data = takeoff.measure_areas()
    assert area_data['total_area'] > 0
    assert 'entity_counts' in area_data


def test_generate_takeoff_report(sample_dxf_geometry):
    """Test generating takeoff report."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    
    quantities = takeoff.generate_takeoff_report()
    assert len(quantities) > 0
    
    # Check that quantities have required fields
    for qty in quantities:
        assert 'category' in qty
        assert 'item' in qty
        assert 'quantity' in qty
        assert 'unit' in qty


def test_to_excel(sample_dxf_geometry):
    """Test exporting to Excel."""
    takeoff = QuantityTakeoff(sample_dxf_geometry)
    takeoff.generate_takeoff_report()
    
    with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
        tmp_path = tmp.name
    
    try:
        takeoff.to_excel(tmp_path)
        assert os.path.exists(tmp_path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
