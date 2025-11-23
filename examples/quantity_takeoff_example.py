"""
Example: Quantity Takeoff

This example demonstrates how to perform automated quantity takeoff
from an AutoCAD drawing.
"""

from autocad_tools import QuantityTakeoff

def main():
    # Path to your DXF file
    dxf_file = "sample_drawing.dxf"
    
    # Create takeoff tool
    takeoff = QuantityTakeoff(dxf_file)
    
    # Generate comprehensive takeoff report
    print("Generating quantity takeoff report...")
    quantities = takeoff.generate_takeoff_report()
    
    print(f"\nFound {len(quantities)} quantity items:")
    for qty in quantities:
        print(f"  {qty['category']}: {qty['item']} = {qty['quantity']} {qty['unit']}")
    
    # Get specific measurements
    print("\nDetailed Measurements:")
    
    # Measure lengths
    length_data = takeoff.measure_lengths()
    print(f"  Total linear length: {length_data['total_length']:.2f} units")
    print(f"  Linear entities: {length_data['entity_counts']}")
    
    # Measure areas
    area_data = takeoff.measure_areas()
    print(f"  Total enclosed area: {area_data['total_area']:.2f} sq units")
    print(f"  Area entities: {area_data['entity_counts']}")
    
    # Export to Excel
    output_file = "quantity_takeoff.xlsx"
    takeoff.to_excel(output_file)
    print(f"\nExported to {output_file}")

if __name__ == "__main__":
    main()
