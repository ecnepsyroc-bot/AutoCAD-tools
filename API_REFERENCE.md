# API Reference

## AutoCAD-Excel Integration Toolkit API

Complete API documentation for all toolkit components.

---

## CoordinateExtractor

Extract point coordinates from AutoCAD drawings.

### Class: `CoordinateExtractor(dxf_path: str)`

**Parameters:**
- `dxf_path` (str): Path to the DXF file

### Methods

#### `extract_points(layer: Optional[str] = None, entity_type: str = 'POINT') -> List[Dict]`

Extract point coordinates from the drawing.

**Parameters:**
- `layer` (str, optional): Layer name to filter by (None for all layers)
- `entity_type` (str): Entity type to extract ('POINT', 'INSERT', 'CIRCLE', 'LINE')

**Returns:**
- List[Dict]: List of point dictionaries with coordinates and metadata

**Example:**
```python
extractor = CoordinateExtractor('drawing.dxf')
points = extractor.extract_points(layer='POINTS', entity_type='POINT')
```

#### `extract_all_points(layer: Optional[str] = None) -> List[Dict]`

Extract all point-like entities from the drawing.

**Parameters:**
- `layer` (str, optional): Layer name to filter by

**Returns:**
- List[Dict]: List of all point dictionaries

#### `to_excel(output_path: str, include_metadata: bool = True)`

Export extracted points to Excel.

**Parameters:**
- `output_path` (str): Path for the output Excel file
- `include_metadata` (bool): Whether to include entity metadata

#### `get_summary() -> Dict`

Get summary statistics of extracted points.

**Returns:**
- Dict: Dictionary with summary information (count, types, layers, ranges)

---

## BlockAttributeExtractor

Extract block information and attributes from AutoCAD drawings.

### Class: `BlockAttributeExtractor(dxf_path: str)`

**Parameters:**
- `dxf_path` (str): Path to the DXF file

### Methods

#### `extract_all_blocks(layer: Optional[str] = None) -> List[Dict]`

Extract all block insertions with their attributes.

**Parameters:**
- `layer` (str, optional): Layer name to filter by

**Returns:**
- List[Dict]: List of block dictionaries

#### `extract_by_name(block_name: str, layer: Optional[str] = None) -> List[Dict]`

Extract blocks by name.

**Parameters:**
- `block_name` (str): Name of the block to extract
- `layer` (str, optional): Layer name to filter by

**Returns:**
- List[Dict]: List of matching block dictionaries

#### `to_excel(output_path: str, separate_attributes: bool = True)`

Export extracted blocks to Excel.

**Parameters:**
- `output_path` (str): Path for the output Excel file
- `separate_attributes` (bool): Create separate columns for each attribute

#### `get_summary() -> Dict`

Get summary statistics of extracted blocks.

**Returns:**
- Dict: Dictionary with summary information

#### `filter_blocks(name: Optional[str] = None, layer: Optional[str] = None) -> List[Dict]`

Filter extracted blocks by criteria.

**Parameters:**
- `name` (str, optional): Block name to filter by
- `layer` (str, optional): Layer name to filter by

**Returns:**
- List[Dict]: Filtered list of blocks

---

## QuantityTakeoff

Perform automated measurements and quantity calculations.

### Class: `QuantityTakeoff(dxf_path: str)`

**Parameters:**
- `dxf_path` (str): Path to the DXF file

### Methods

#### `count_entities(entity_type: str, layer: Optional[str] = None) -> int`

Count entities of a specific type.

**Parameters:**
- `entity_type` (str): Type of entity to count (e.g., 'LINE', 'CIRCLE', 'INSERT')
- `layer` (str, optional): Layer to filter by

**Returns:**
- int: Count of entities

#### `measure_lengths(layer: Optional[str] = None, entity_types: Optional[List[str]] = None) -> Dict`

Measure total lengths of linear entities.

**Parameters:**
- `layer` (str, optional): Layer to filter by
- `entity_types` (List[str], optional): List of entity types to measure

**Returns:**
- Dict: Dictionary with length measurements

#### `measure_areas(layer: Optional[str] = None) -> Dict`

Measure total areas of closed entities.

**Parameters:**
- `layer` (str, optional): Layer to filter by

**Returns:**
- Dict: Dictionary with area measurements

#### `generate_takeoff_report(layer: Optional[str] = None) -> List[Dict]`

Generate a comprehensive quantity takeoff report.

**Parameters:**
- `layer` (str, optional): Layer to filter by

**Returns:**
- List[Dict]: List of quantity measurements

#### `to_excel(output_path: str)`

Export quantity takeoff to Excel.

**Parameters:**
- `output_path` (str): Path for output Excel file

---

## LayerManager

Manage AutoCAD layer properties and configurations through Excel.

### Class: `LayerManager(dxf_path: str)`

**Parameters:**
- `dxf_path` (str): Path to the DXF file

### Methods

#### `extract_layer_info() -> List[Dict]`

Extract information about all layers.

**Returns:**
- List[Dict]: List of layer information dictionaries

#### `to_excel(output_path: str)`

Export layer configuration to Excel.

**Parameters:**
- `output_path` (str): Path for output Excel file

#### `from_excel(excel_path: str) -> List[Dict]`

Import layer configuration from Excel.

**Parameters:**
- `excel_path` (str): Path to Excel file with layer configuration

**Returns:**
- List[Dict]: List of layer configurations

#### `apply_layer_config(layer_configs: List[Dict])`

Apply layer configurations to the drawing.

**Parameters:**
- `layer_configs` (List[Dict]): List of layer configuration dictionaries

#### `save_drawing(output_path: str)`

Save the modified drawing.

**Parameters:**
- `output_path` (str): Path for output DXF file

#### `get_layer_statistics() -> Dict`

Get statistics about layers and their usage.

**Returns:**
- Dict: Dictionary with layer statistics

#### `create_layer_template(output_path: str)`

Create an Excel template for layer configuration.

**Parameters:**
- `output_path` (str): Path for template file

---

## BatchProcessor

Execute batch operations on multiple AutoCAD drawings.

### Class: `BatchProcessor()`

### Methods

#### `create_batch_template(output_path: str)`

Create an Excel template for batch processing.

**Parameters:**
- `output_path` (str): Path for template file

#### `load_batch_config(excel_path: str) -> List[Dict]`

Load batch processing configuration from Excel.

**Parameters:**
- `excel_path` (str): Path to Excel configuration file

**Returns:**
- List[Dict]: List of batch operation configurations

#### `process_drawing(config: Dict) -> Dict`

Process a single drawing based on configuration.

**Parameters:**
- `config` (Dict): Configuration dictionary

**Returns:**
- Dict: Result dictionary with status and message

#### `process_batch(excel_path: str, base_path: Optional[str] = None) -> List[Dict]`

Process multiple drawings from Excel configuration.

**Parameters:**
- `excel_path` (str): Path to Excel configuration file
- `base_path` (str, optional): Base directory for relative paths

**Returns:**
- List[Dict]: List of processing results

#### `export_results(output_path: str)`

Export batch processing results to Excel.

**Parameters:**
- `output_path` (str): Path for output Excel file

#### `get_summary() -> Dict`

Get summary of batch processing results.

**Returns:**
- Dict: Summary dictionary

---

## MeasurementTools

Advanced measurement and analysis tools.

### Class: `MeasurementTools(dxf_path: str)`

**Parameters:**
- `dxf_path` (str): Path to the DXF file

### Methods

#### `measure_distances(point_pairs: List[Tuple[Tuple, Tuple]]) -> List[Dict]`

Measure distances between point pairs.

**Parameters:**
- `point_pairs` (List[Tuple]): List of point pair tuples

**Returns:**
- List[Dict]: List of distance measurements

#### `analyze_polyline(layer: Optional[str] = None) -> List[Dict]`

Analyze polyline properties.

**Parameters:**
- `layer` (str, optional): Layer to filter by

**Returns:**
- List[Dict]: List of polyline analysis results

#### `analyze_circles(layer: Optional[str] = None) -> List[Dict]`

Analyze circle properties.

**Parameters:**
- `layer` (str, optional): Layer to filter by

**Returns:**
- List[Dict]: List of circle analysis results

#### `calculate_statistics(measurements: List[Dict], value_key: str) -> Dict`

Calculate statistical summary of measurements.

**Parameters:**
- `measurements` (List[Dict]): List of measurement dictionaries
- `value_key` (str): Key to calculate statistics for

**Returns:**
- Dict: Dictionary with statistical values

#### `comprehensive_analysis(layer: Optional[str] = None) -> Dict`

Perform comprehensive analysis of the drawing.

**Parameters:**
- `layer` (str, optional): Layer to filter by

**Returns:**
- Dict: Dictionary with comprehensive analysis results

#### `export_analysis_to_excel(output_path: str, layer: Optional[str] = None)`

Export comprehensive analysis to Excel.

**Parameters:**
- `output_path` (str): Path for output Excel file
- `layer` (str, optional): Layer to filter by

---

## Utility Functions

Common utility functions available in `autocad_tools.utils`.

### `load_dxf(filepath: str)`

Load a DXF file.

### `create_excel_workbook(title: str = "AutoCAD Export") -> Tuple[Workbook, any]`

Create a new Excel workbook with styling.

### `style_header(ws, row: int = 1, columns: Optional[List[str]] = None)`

Apply header styling to Excel worksheet.

### `auto_size_columns(ws, min_width: int = 10, max_width: int = 50)`

Auto-size columns based on content.

### `add_border(ws, cell_range: str)`

Add borders to a cell range.

### `get_layer_names(doc) -> List[str]`

Get all layer names from a DXF document.

### `filter_by_layer(entities, layer_name: Optional[str] = None)`

Filter entities by layer name.

### `format_coordinate(value: float, precision: int = 3) -> str`

Format a coordinate value.

### `calculate_distance(p1: Tuple[float, float, float], p2: Tuple[float, float, float]) -> float`

Calculate 3D distance between two points.

### `save_excel(wb: Workbook, filepath: str)`

Save Excel workbook with error handling.

---

## Data Structures

### Point Dictionary

```python
{
    'type': str,         # Entity type (POINT, INSERT, CIRCLE, LINE_START, LINE_END)
    'x': float,          # X coordinate
    'y': float,          # Y coordinate
    'z': float,          # Z coordinate
    'layer': str,        # Layer name
    # Optional fields depending on type:
    'name': str,         # For INSERT types
    'radius': float,     # For CIRCLE types
}
```

### Block Dictionary

```python
{
    'name': str,         # Block name
    'x': float,          # Insertion point X
    'y': float,          # Insertion point Y
    'z': float,          # Insertion point Z
    'layer': str,        # Layer name
    'rotation': float,   # Rotation angle
    'x_scale': float,    # X scale factor
    'y_scale': float,    # Y scale factor
    'z_scale': float,    # Z scale factor
    'attributes': Dict,  # Dictionary of attributes {tag: value}
}
```

### Quantity Dictionary

```python
{
    'category': str,     # Category (Count, Length, Area)
    'item': str,         # Item description
    'quantity': float,   # Quantity value
    'unit': str,         # Unit of measurement
    'layer': str,        # Layer name
}
```

---

## Error Handling

All tools include proper error handling:

- `FileNotFoundError`: Raised when DXF file is not found
- `ValueError`: Raised when invalid parameters or no data to export
- `PermissionError`: Raised when Excel file cannot be saved (e.g., file is open)

Always use try-except blocks when processing drawings:

```python
try:
    extractor = CoordinateExtractor('drawing.dxf')
    extractor.extract_all_points()
    extractor.to_excel('output.xlsx')
except FileNotFoundError:
    print("DXF file not found")
except PermissionError:
    print("Cannot save Excel file (close it if open)")
except Exception as e:
    print(f"Error: {e}")
```
