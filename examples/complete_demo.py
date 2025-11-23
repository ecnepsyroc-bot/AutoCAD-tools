"""
Complete Example: All AutoCAD-Excel Tools

This comprehensive example demonstrates all features of the AutoCAD-Excel toolkit.
"""

from autocad_tools import (
    CoordinateExtractor,
    BlockAttributeExtractor,
    QuantityTakeoff,
    LayerManager,
    BatchProcessor,
    MeasurementTools
)
import os


def demonstrate_coordinate_extraction(dxf_file):
    """Demonstrate coordinate extraction capabilities."""
    print("\n" + "="*60)
    print("1. COORDINATE EXTRACTION")
    print("="*60)
    
    extractor = CoordinateExtractor(dxf_file)
    points = extractor.extract_all_points()
    
    print(f"Extracted {len(points)} points")
    summary = extractor.get_summary()
    print(f"Point types: {summary.get('types', {})}")
    
    if points:
        extractor.to_excel("output_coordinates.xlsx")
        print("✓ Exported to output_coordinates.xlsx")


def demonstrate_block_extraction(dxf_file):
    """Demonstrate block attribute extraction."""
    print("\n" + "="*60)
    print("2. BLOCK ATTRIBUTE EXTRACTION")
    print("="*60)
    
    extractor = BlockAttributeExtractor(dxf_file)
    blocks = extractor.extract_all_blocks()
    
    print(f"Extracted {len(blocks)} blocks")
    summary = extractor.get_summary()
    print(f"Unique block types: {summary.get('unique_blocks', 0)}")
    print(f"Total attributes: {summary.get('total_attributes', 0)}")
    
    if blocks:
        extractor.to_excel("output_blocks.xlsx")
        print("✓ Exported to output_blocks.xlsx")


def demonstrate_quantity_takeoff(dxf_file):
    """Demonstrate quantity takeoff."""
    print("\n" + "="*60)
    print("3. QUANTITY TAKEOFF")
    print("="*60)
    
    takeoff = QuantityTakeoff(dxf_file)
    quantities = takeoff.generate_takeoff_report()
    
    print(f"Generated {len(quantities)} quantity items:")
    for qty in quantities[:10]:  # Show first 10
        print(f"  - {qty['item']}: {qty['quantity']} {qty['unit']}")
    
    if quantities:
        takeoff.to_excel("output_quantities.xlsx")
        print("✓ Exported to output_quantities.xlsx")


def demonstrate_layer_management(dxf_file):
    """Demonstrate layer management."""
    print("\n" + "="*60)
    print("4. LAYER MANAGEMENT")
    print("="*60)
    
    manager = LayerManager(dxf_file)
    manager.extract_layer_info()
    
    stats = manager.get_layer_statistics()
    print(f"Total layers: {stats.get('total_layers', 0)}")
    print(f"Layers with entities: {len(stats.get('entity_counts', {}))}")
    
    manager.to_excel("output_layers.xlsx")
    print("✓ Exported to output_layers.xlsx")
    
    # Create template
    manager.create_layer_template("layer_template.xlsx")
    print("✓ Created template: layer_template.xlsx")


def demonstrate_measurement_tools(dxf_file):
    """Demonstrate measurement and analysis."""
    print("\n" + "="*60)
    print("5. MEASUREMENT AND ANALYSIS")
    print("="*60)
    
    tools = MeasurementTools(dxf_file)
    analysis = tools.comprehensive_analysis()
    
    polyline_count = len(analysis.get('polylines', []))
    circle_count = len(analysis.get('circles', []))
    
    print(f"Analyzed {polyline_count} polylines")
    print(f"Analyzed {circle_count} circles")
    
    if 'polyline_stats' in analysis and 'length' in analysis['polyline_stats']:
        stats = analysis['polyline_stats']['length']
        if stats:
            print(f"Total polyline length: {stats.get('total', 0):.2f} units")
    
    if 'circle_stats' in analysis and 'area' in analysis['circle_stats']:
        stats = analysis['circle_stats']['area']
        if stats:
            print(f"Total circle area: {stats.get('total', 0):.2f} sq units")
    
    if polyline_count > 0 or circle_count > 0:
        tools.export_analysis_to_excel("output_analysis.xlsx")
        print("✓ Exported to output_analysis.xlsx")


def demonstrate_batch_processing():
    """Demonstrate batch processing."""
    print("\n" + "="*60)
    print("6. BATCH PROCESSING")
    print("="*60)
    
    processor = BatchProcessor()
    processor.create_batch_template("batch_template.xlsx")
    print("✓ Created batch template: batch_template.xlsx")
    print("  Configure this file to process multiple drawings")


def main():
    """Run all demonstrations."""
    print("\n" + "="*60)
    print("AutoCAD-Excel Integration Toolkit - Complete Demo")
    print("="*60)
    
    # Check for sample DXF file
    dxf_file = "sample_drawing.dxf"
    
    if not os.path.exists(dxf_file):
        print(f"\n⚠ Sample file '{dxf_file}' not found.")
        print("Please provide a DXF file to demonstrate the tools.")
        print("\nCreating demonstration templates and examples...")
        
        # Still create templates that don't require input
        demonstrate_batch_processing()
        
        # Create a layer template without input file
        print("\nTo run the complete demo:")
        print(f"1. Place a DXF file named '{dxf_file}' in this directory")
        print("2. Run this script again")
        return
    
    try:
        # Run all demonstrations
        demonstrate_coordinate_extraction(dxf_file)
        demonstrate_block_extraction(dxf_file)
        demonstrate_quantity_takeoff(dxf_file)
        demonstrate_layer_management(dxf_file)
        demonstrate_measurement_tools(dxf_file)
        demonstrate_batch_processing()
        
        print("\n" + "="*60)
        print("DEMONSTRATION COMPLETE")
        print("="*60)
        print("\nGenerated files:")
        output_files = [
            "output_coordinates.xlsx",
            "output_blocks.xlsx",
            "output_quantities.xlsx",
            "output_layers.xlsx",
            "output_analysis.xlsx",
            "layer_template.xlsx",
            "batch_template.xlsx"
        ]
        
        for f in output_files:
            if os.path.exists(f):
                print(f"  ✓ {f}")
        
        print("\nThe AutoCAD-Excel toolkit is ready to use!")
        
    except Exception as e:
        print(f"\n✗ Error during demonstration: {e}")
        print("Please check that the DXF file is valid.")


if __name__ == "__main__":
    main()
