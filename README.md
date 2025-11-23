# AutoCAD-tools

A diverse toolkit of intelligent tools that utilize Excel for AutoCAD integration and automation.

## Overview

This toolkit provides a comprehensive set of Python-based tools for bidirectional integration between AutoCAD and Excel, enabling automated workflows, data extraction, and intelligent processing.

## Features

### 1. Coordinate Extraction Tool
- Extract point coordinates from AutoCAD drawings
- Export to Excel with customizable formatting
- Support for multiple coordinate systems
- Filter by layer, type, or selection

### 2. Block Attribute Extractor
- Extract block attributes and properties
- Generate comprehensive Excel reports
- Support for nested blocks
- Batch processing capabilities

### 3. Quantity Takeoff Tool
- Automated measurement and counting
- Export quantities to Excel templates
- Support for area, length, and volume calculations
- Custom calculation formulas

### 4. Layer Management
- Import/export layer configurations via Excel
- Batch layer property updates
- Layer state management
- Color and linetype standardization

### 5. Excel-Driven Batch Processing
- Process multiple drawings from Excel input
- Automated drawing modifications
- Batch attribute updates
- Report generation

### 6. Measurement and Analysis
- Distance and area calculations
- Export measurement data to Excel
- Statistical analysis tools
- Custom unit conversions

## Installation

```bash
pip install -r requirements.txt
```

## Quick Start

```python
from autocad_tools import CoordinateExtractor, BlockAttributeExtractor

# Extract coordinates from a DXF file
extractor = CoordinateExtractor('drawing.dxf')
extractor.extract_points(layer='POINTS')
extractor.to_excel('coordinates.xlsx')

# Extract block attributes
block_tool = BlockAttributeExtractor('drawing.dxf')
block_tool.extract_all_blocks()
block_tool.to_excel('blocks.xlsx')
```

## Project Structure

```
autocad_tools/
├── coordinate_extractor.py   # Point and coordinate extraction
├── block_extractor.py         # Block and attribute handling
├── quantity_takeoff.py        # Measurement and counting tools
├── layer_manager.py           # Layer configuration management
├── batch_processor.py         # Batch operations from Excel
├── measurement_tools.py       # Analysis and calculations
└── utils.py                   # Utility functions
```

## Tools Description

### Coordinate Extractor
Extracts point data from AutoCAD drawings and exports to Excel with formatting options.

### Block Attribute Extractor
Retrieves block information including attributes, insertion points, and properties.

### Quantity Takeoff Tool
Automates quantity calculations for construction and engineering projects.

### Layer Manager
Manages layer properties and configurations through Excel spreadsheets.

### Batch Processor
Executes bulk operations on multiple drawings based on Excel input.

### Measurement Tools
Provides intelligent measurement and analysis capabilities with Excel reporting.

## Excel Integration

All tools support:
- Export to Excel with formatting
- Import from Excel for batch operations
- Template-based reporting
- Custom calculation support
- Data validation and filtering

## Requirements

- Python 3.8+
- openpyxl for Excel operations
- ezdxf for DXF/DWG file handling
- pandas for data processing
- numpy for calculations

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

MIT License