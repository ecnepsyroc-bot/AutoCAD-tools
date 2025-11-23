"""
Test block extractor
"""

import pytest
import os
import tempfile
import ezdxf
from autocad_tools import BlockAttributeExtractor


@pytest.fixture
def sample_dxf_with_blocks():
    """Create a sample DXF file with blocks for testing."""
    doc = ezdxf.new('R2010')
    
    # Create a block definition
    block = doc.blocks.new(name='TEST_BLOCK')
    block.add_circle((0, 0), radius=1)
    block.add_attdef(tag='ID', insert=(0, -2), height=0.5)
    block.add_attdef(tag='NAME', insert=(0, -3), height=0.5)
    
    # Insert blocks in modelspace
    msp = doc.modelspace()
    
    # Insert with attributes
    insert1 = msp.add_blockref('TEST_BLOCK', (10, 10), 
                               dxfattribs={'layer': 'BLOCKS'})
    insert1.add_auto_attribs({'ID': '001', 'NAME': 'Block A'})
    
    insert2 = msp.add_blockref('TEST_BLOCK', (20, 20), 
                               dxfattribs={'layer': 'BLOCKS'})
    insert2.add_auto_attribs({'ID': '002', 'NAME': 'Block B'})
    
    insert3 = msp.add_blockref('TEST_BLOCK', (30, 30), 
                               dxfattribs={'layer': 'OTHER'})
    insert3.add_auto_attribs({'ID': '003', 'NAME': 'Block C'})
    
    with tempfile.NamedTemporaryFile(suffix='.dxf', delete=False) as tmp:
        tmp_path = tmp.name
    
    doc.saveas(tmp_path)
    yield tmp_path
    
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)


def test_extract_all_blocks(sample_dxf_with_blocks):
    """Test extracting all blocks."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    blocks = extractor.extract_all_blocks()
    
    assert len(blocks) == 3
    assert all(b['name'] == 'TEST_BLOCK' for b in blocks)


def test_extract_blocks_by_layer(sample_dxf_with_blocks):
    """Test filtering blocks by layer."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    blocks = extractor.extract_all_blocks(layer='BLOCKS')
    
    assert len(blocks) == 2
    assert all(b['layer'] == 'BLOCKS' for b in blocks)


def test_extract_by_name(sample_dxf_with_blocks):
    """Test extracting blocks by name."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    blocks = extractor.extract_by_name('TEST_BLOCK')
    
    assert len(blocks) == 3
    assert all(b['name'] == 'TEST_BLOCK' for b in blocks)


def test_block_properties(sample_dxf_with_blocks):
    """Test that block properties are extracted."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    blocks = extractor.extract_all_blocks()
    
    block = blocks[0]
    assert 'x' in block
    assert 'y' in block
    assert 'z' in block
    assert 'layer' in block
    assert 'rotation' in block
    assert 'attributes' in block


def test_get_summary(sample_dxf_with_blocks):
    """Test getting summary statistics."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    extractor.extract_all_blocks()
    summary = extractor.get_summary()
    
    assert summary['count'] == 3
    assert summary['unique_blocks'] == 1
    assert 'TEST_BLOCK' in summary['block_types']


def test_to_excel(sample_dxf_with_blocks):
    """Test exporting to Excel."""
    extractor = BlockAttributeExtractor(sample_dxf_with_blocks)
    extractor.extract_all_blocks()
    
    with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
        tmp_path = tmp.name
    
    try:
        extractor.to_excel(tmp_path)
        assert os.path.exists(tmp_path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
