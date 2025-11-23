"""
Test package initialization
"""

def test_imports():
    """Test that all main classes can be imported."""
    from autocad_tools import (
        CoordinateExtractor,
        BlockAttributeExtractor,
        QuantityTakeoff,
        LayerManager,
        BatchProcessor,
        MeasurementTools
    )
    
    assert CoordinateExtractor is not None
    assert BlockAttributeExtractor is not None
    assert QuantityTakeoff is not None
    assert LayerManager is not None
    assert BatchProcessor is not None
    assert MeasurementTools is not None


def test_version():
    """Test that version is defined."""
    import autocad_tools
    assert hasattr(autocad_tools, '__version__')
    assert autocad_tools.__version__ == '1.0.0'
