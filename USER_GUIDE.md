# User Guide

## AutoCAD-Excel Integration Toolkit

This comprehensive guide will help you get started with the AutoCAD-Excel Integration Toolkit.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Tools Overview](#tools-overview)
4. [Detailed Examples](#detailed-examples)
5. [Best Practices](#best-practices)

## Installation

### Prerequisites

- Python 3.8 or higher
- AutoCAD DXF files (DWG files must be converted to DXF)

### Install Dependencies

```bash
pip install -r requirements.txt
```

Or install the package:

```bash
pip install -e .
```

## Quick Start

### Basic Usage

```python
from autocad_tools import CoordinateExtractor

# Extract coordinates from a DXF file
extractor = CoordinateExtractor('your_drawing.dxf')
extractor.extract_all_points()
extractor.to_excel('output.xlsx')
```

### Running Examples

```bash
cd examples
python complete_demo.py
```

## Tools Overview

### 1. Coordinate Extractor

**Purpose:** Extract point coordinates from AutoCAD drawings.

**Use Cases:**
- Export survey points
- Extract insertion points
- Generate coordinate lists

**Example:**
```python
from autocad_tools import CoordinateExtractor

extractor = CoordinateExtractor('drawing.dxf')
extractor.extract_points(layer='POINTS', entity_type='POINT')
extractor.to_excel('coordinates.xlsx')
```

### 2. Block Attribute Extractor

**Purpose:** Extract block information and attributes.

**Use Cases:**
- Create parts lists
- Extract room data
- Generate equipment schedules

**Example:**
```python
from autocad_tools import BlockAttributeExtractor

extractor = BlockAttributeExtractor('drawing.dxf')
extractor.extract_all_blocks()
extractor.to_excel('blocks.xlsx', separate_attributes=True)
```

### 3. Quantity Takeoff

**Purpose:** Automated quantity calculations and measurements.

**Use Cases:**
- Construction quantity estimation
- Material takeoff
- Length and area calculations

**Example:**
```python
from autocad_tools import QuantityTakeoff

takeoff = QuantityTakeoff('drawing.dxf')
takeoff.generate_takeoff_report()
takeoff.to_excel('quantities.xlsx')
```

### 4. Layer Manager

**Purpose:** Manage layer properties via Excel.

**Use Cases:**
- Standardize layer configurations
- Batch layer property updates
- Export/import layer settings

**Example:**
```python
from autocad_tools import LayerManager

# Export layers
manager = LayerManager('drawing.dxf')
manager.extract_layer_info()
manager.to_excel('layers.xlsx')

# Import and apply
configs = manager.from_excel('layers.xlsx')
manager.apply_layer_config(configs)
manager.save_drawing('updated.dxf')
```

### 5. Batch Processor

**Purpose:** Process multiple drawings from Excel configuration.

**Use Cases:**
- Bulk data extraction
- Multiple drawing analysis
- Automated reporting

**Example:**
```python
from autocad_tools import BatchProcessor

processor = BatchProcessor()
processor.create_batch_template('template.xlsx')

# After configuring the template
processor.process_batch('config.xlsx')
processor.export_results('results.xlsx')
```

### 6. Measurement Tools

**Purpose:** Advanced measurement and analysis.

**Use Cases:**
- Geometric analysis
- Statistical summaries
- Comprehensive measurements

**Example:**
```python
from autocad_tools import MeasurementTools

tools = MeasurementTools('drawing.dxf')
analysis = tools.comprehensive_analysis()
tools.export_analysis_to_excel('analysis.xlsx')
```

## Detailed Examples

### Working with Layers

Filter entities by layer:

```python
extractor = CoordinateExtractor('drawing.dxf')
extractor.extract_points(layer='SURVEY-POINTS')
extractor.to_excel('survey_points.xlsx')
```

### Filtering Blocks

Extract specific block types:

```python
extractor = BlockAttributeExtractor('drawing.dxf')
extractor.extract_by_name('DOOR', layer='ARCHITECTURE')
extractor.to_excel('doors.xlsx')
```

### Custom Measurements

```python
tools = MeasurementTools('drawing.dxf')

# Analyze specific layer
polylines = tools.analyze_polyline(layer='WALLS')
circles = tools.analyze_circles(layer='COLUMNS')

# Get statistics
stats = tools.calculate_statistics(polylines, 'length')
print(f"Total wall length: {stats['total']}")
```

## Best Practices

### 1. File Organization

- Keep input DXF files in a dedicated directory
- Use consistent naming conventions
- Organize output files by date or project

### 2. Layer Management

- Use meaningful layer names
- Maintain consistent layer standards across drawings
- Use layer templates for standardization

### 3. Batch Processing

- Test on a single drawing first
- Use batch processing for repetitive tasks
- Keep batch configuration files for reuse

### 4. Data Validation

- Always check summary statistics
- Review Excel output for accuracy
- Verify units and coordinate systems

### 5. Performance

- Filter by layer when possible
- Process only required entity types
- Use batch processing for multiple files

### 6. Error Handling

- Check file paths before processing
- Handle missing or corrupted DXF files gracefully
- Keep logs of batch processing operations

## Troubleshooting

### Common Issues

**Issue:** File not found error
- **Solution:** Use absolute paths or verify working directory

**Issue:** No entities extracted
- **Solution:** Check layer names and entity types in the drawing

**Issue:** Excel file cannot be saved
- **Solution:** Close the Excel file if it's open

**Issue:** Incorrect coordinates
- **Solution:** Verify coordinate system and units in AutoCAD

## Advanced Topics

### Custom Entity Processing

You can extend the tools to process custom entity types by accessing the underlying ezdxf document:

```python
extractor = CoordinateExtractor('drawing.dxf')
doc = extractor.doc
msp = extractor.msp

# Process custom entities
for entity in msp.query('MTEXT'):
    # Custom processing
    pass
```

### Integration with Other Tools

The toolkit can be integrated with:
- pandas for advanced data analysis
- matplotlib for visualization
- other AutoCAD automation tools

## Support and Contribution

For issues, questions, or contributions, please visit the project repository.

## License

MIT License - See LICENSE file for details.
