"""
Example: Measurement and Analysis

This example demonstrates comprehensive measurement and analysis tools.
"""

from autocad_tools import MeasurementTools

def main():
    # Path to your DXF file
    dxf_file = "sample_drawing.dxf"
    
    # Create measurement tool
    print("Creating measurement tool...")
    tools = MeasurementTools(dxf_file)
    
    # Analyze polylines
    print("\nAnalyzing polylines...")
    polylines = tools.analyze_polyline()
    print(f"Found {len(polylines)} polylines")
    
    for poly in polylines[:5]:  # Show first 5
        print(f"  {poly['type']}: Length={poly['length']:.2f}, "
              f"Vertices={poly['vertices']}, Closed={poly['closed']}")
        if poly['area']:
            print(f"    Area={poly['area']:.2f}")
    
    # Analyze circles
    print("\nAnalyzing circles...")
    circles = tools.analyze_circles()
    print(f"Found {len(circles)} circles")
    
    for circle in circles[:5]:  # Show first 5
        print(f"  Circle: Radius={circle['radius']:.2f}, "
              f"Area={circle['area']:.2f}, "
              f"Center=({circle['center_x']:.2f}, {circle['center_y']:.2f})")
    
    # Get comprehensive analysis
    print("\nPerforming comprehensive analysis...")
    analysis = tools.comprehensive_analysis()
    
    # Show statistics
    if 'polyline_stats' in analysis:
        print("\nPolyline Statistics:")
        if 'length' in analysis['polyline_stats']:
            stats = analysis['polyline_stats']['length']
            print(f"  Length - Min: {stats['min']:.2f}, Max: {stats['max']:.2f}, "
                  f"Mean: {stats['mean']:.2f}, Total: {stats['total']:.2f}")
        
        if 'area' in analysis['polyline_stats']:
            stats = analysis['polyline_stats']['area']
            if stats:
                print(f"  Area - Min: {stats['min']:.2f}, Max: {stats['max']:.2f}, "
                      f"Mean: {stats['mean']:.2f}, Total: {stats['total']:.2f}")
    
    if 'circle_stats' in analysis:
        print("\nCircle Statistics:")
        if 'radius' in analysis['circle_stats']:
            stats = analysis['circle_stats']['radius']
            print(f"  Radius - Min: {stats['min']:.2f}, Max: {stats['max']:.2f}, "
                  f"Mean: {stats['mean']:.2f}")
        
        if 'area' in analysis['circle_stats']:
            stats = analysis['circle_stats']['area']
            print(f"  Area - Min: {stats['min']:.2f}, Max: {stats['max']:.2f}, "
                  f"Mean: {stats['mean']:.2f}, Total: {stats['total']:.2f}")
    
    # Export comprehensive analysis to Excel
    output_file = "measurement_analysis.xlsx"
    tools.export_analysis_to_excel(output_file)
    print(f"\nComprehensive analysis exported to {output_file}")

if __name__ == "__main__":
    main()
