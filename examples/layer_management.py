"""
Example: Layer Management

This example demonstrates how to manage AutoCAD layers via Excel.
"""

from autocad_tools import LayerManager

def export_layers():
    """Export layer configuration to Excel."""
    print("Exporting layer configuration...")
    
    manager = LayerManager("sample_drawing.dxf")
    manager.extract_layer_info()
    manager.to_excel("layer_config.xlsx")
    
    # Get statistics
    stats = manager.get_layer_statistics()
    print(f"  Total layers: {stats['total_layers']}")
    print(f"  Entity counts: {stats['entity_counts']}")
    print(f"  Empty layers: {stats['empty_layers']}")
    
    print("Exported to layer_config.xlsx")

def create_template():
    """Create a layer configuration template."""
    print("\nCreating layer template...")
    
    manager = LayerManager("sample_drawing.dxf")
    manager.create_layer_template("layer_template.xlsx")
    
    print("Template created: layer_template.xlsx")

def apply_config():
    """Apply layer configuration from Excel."""
    print("\nApplying layer configuration...")
    
    manager = LayerManager("sample_drawing.dxf")
    
    # Load configuration from Excel
    configs = manager.from_excel("layer_config.xlsx")
    print(f"  Loaded {len(configs)} layer configurations")
    
    # Apply to drawing
    manager.apply_layer_config(configs)
    
    # Save modified drawing
    manager.save_drawing("output_drawing.dxf")
    print("Configuration applied and saved to output_drawing.dxf")

def main():
    # Export current layer configuration
    export_layers()
    
    # Create a template for new configurations
    create_template()
    
    # Uncomment to apply configuration
    # apply_config()

if __name__ == "__main__":
    main()
