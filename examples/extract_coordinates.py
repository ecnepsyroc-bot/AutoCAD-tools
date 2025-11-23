"""
Example: Extract Coordinates from AutoCAD Drawing

This example demonstrates how to extract point coordinates from a DXF file
and export them to Excel.
"""

from autocad_tools import CoordinateExtractor

def main():
    # Path to your DXF file
    dxf_file = "sample_drawing.dxf"
    
    # Create extractor
    extractor = CoordinateExtractor(dxf_file)
    
    # Extract all point-like entities
    print("Extracting points...")
    points = extractor.extract_all_points()
    print(f"Found {len(points)} points")
    
    # Get summary
    summary = extractor.get_summary()
    print("\nSummary:")
    print(f"  Total points: {summary['count']}")
    print(f"  Types: {summary['types']}")
    print(f"  Layers: {summary['layers']}")
    print(f"  X range: {summary['x_range']}")
    print(f"  Y range: {summary['y_range']}")
    
    # Export to Excel
    output_file = "coordinates.xlsx"
    extractor.to_excel(output_file, include_metadata=True)
    print(f"\nExported to {output_file}")

if __name__ == "__main__":
    main()
