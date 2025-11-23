"""
Example: Batch Processing

This example demonstrates how to process multiple drawings using Excel configuration.
"""

from autocad_tools import BatchProcessor

def create_template():
    """Create a batch processing template."""
    print("Creating batch processing template...")
    
    processor = BatchProcessor()
    processor.create_batch_template("batch_template.xlsx")
    
    print("Template created: batch_template.xlsx")
    print("Edit this file to configure your batch operations")

def run_batch():
    """Run batch processing from Excel configuration."""
    print("\nRunning batch processing...")
    
    processor = BatchProcessor()
    
    # Process all drawings from configuration
    results = processor.process_batch("batch_config.xlsx")
    
    # Show summary
    summary = processor.get_summary()
    print(f"\nBatch Processing Summary:")
    print(f"  Total operations: {summary['total']}")
    print(f"  Successful: {summary['success']}")
    print(f"  Errors: {summary['errors']}")
    print(f"  Success rate: {summary['success_rate']}")
    
    # Export detailed results
    processor.export_results("batch_results.xlsx")
    print("\nDetailed results exported to batch_results.xlsx")

def main():
    # First, create a template
    create_template()
    
    # Then process batch (after configuring the Excel file)
    # Uncomment when ready to process
    # run_batch()
    
    print("\nNext steps:")
    print("1. Edit batch_template.xlsx and save as batch_config.xlsx")
    print("2. Configure your drawing files and operations")
    print("3. Run this script again with run_batch() uncommented")

if __name__ == "__main__":
    main()
