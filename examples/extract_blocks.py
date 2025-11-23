"""
Example: Extract Block Attributes

This example demonstrates how to extract block information and attributes
from a DXF file and export them to Excel.
"""

from autocad_tools import BlockAttributeExtractor

def main():
    # Path to your DXF file
    dxf_file = "sample_drawing.dxf"
    
    # Create extractor
    extractor = BlockAttributeExtractor(dxf_file)
    
    # Extract all blocks
    print("Extracting blocks...")
    blocks = extractor.extract_all_blocks()
    print(f"Found {len(blocks)} blocks")
    
    # Get summary
    summary = extractor.get_summary()
    print("\nSummary:")
    print(f"  Total blocks: {summary['count']}")
    print(f"  Unique block types: {summary['unique_blocks']}")
    print(f"  Block types: {summary['block_types']}")
    print(f"  Total attributes: {summary['total_attributes']}")
    
    # Export to Excel with separate columns for each attribute
    output_file = "blocks.xlsx"
    extractor.to_excel(output_file, separate_attributes=True)
    print(f"\nExported to {output_file}")

if __name__ == "__main__":
    main()
