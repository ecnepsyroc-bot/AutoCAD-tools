"""
Test coordinate extractor
"""

import pytest
import os
import tempfile
import ezdxf
from autocad_tools import CoordinateExtractor


@pytest.fixture
def sample_dxf():
    """Create a sample DXF file for testing."""
    doc = ezdxf.new('R2010')
    msp = doc.modelspace()
    
    # Add some test points
    msp.add_point((10, 20, 0), dxfattribs={'layer': 'POINTS'})
    msp.add_point((30, 40, 0), dxfattribs={'layer': 'POINTS'})
    msp.add_point((50, 60, 0), dxfattribs={'layer': 'OTHER'})
    
    # Add a circle
    msp.add_circle((100, 100, 0), radius=10, dxfattribs={'layer': 'CIRCLES'})
    
    # Add a line
    msp.add_line((0, 0, 0), (10, 10, 0), dxfattribs={'layer': 'LINES'})
    
    with tempfile.NamedTemporaryFile(suffix='.dxf', delete=False) as tmp:
        tmp_path = tmp.name
    
    doc.saveas(tmp_path)
    yield tmp_path
    
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)


def test_extract_points(sample_dxf):
    """Test extracting POINT entities."""
    extractor = CoordinateExtractor(sample_dxf)
    points = extractor.extract_points(entity_type='POINT')
    
    assert len(points) == 3
    assert all(p['type'] == 'POINT' for p in points)


def test_extract_points_by_layer(sample_dxf):
    """Test filtering points by layer."""
    extractor = CoordinateExtractor(sample_dxf)
    points = extractor.extract_points(layer='POINTS', entity_type='POINT')
    
    assert len(points) == 2
    assert all(p['layer'] == 'POINTS' for p in points)


def test_extract_circles(sample_dxf):
    """Test extracting CIRCLE entities."""
    extractor = CoordinateExtractor(sample_dxf)
    circles = extractor.extract_points(entity_type='CIRCLE')
    
    assert len(circles) == 1
    assert circles[0]['type'] == 'CIRCLE'
    assert 'radius' in circles[0]


def test_extract_all_points(sample_dxf):
    """Test extracting all point-like entities."""
    extractor = CoordinateExtractor(sample_dxf)
    points = extractor.extract_all_points()
    
    # Should have 3 POINTs + 1 CIRCLE
    assert len(points) >= 4


def test_get_summary(sample_dxf):
    """Test getting summary statistics."""
    extractor = CoordinateExtractor(sample_dxf)
    extractor.extract_all_points()
    summary = extractor.get_summary()
    
    assert 'count' in summary
    assert summary['count'] > 0
    assert 'types' in summary
    assert 'layers' in summary


def test_to_excel(sample_dxf):
    """Test exporting to Excel."""
    extractor = CoordinateExtractor(sample_dxf)
    extractor.extract_all_points()
    
    with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
        tmp_path = tmp.name
    
    try:
        extractor.to_excel(tmp_path)
        assert os.path.exists(tmp_path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
