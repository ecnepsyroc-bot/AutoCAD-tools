# Create-TestExcel.ps1
# Create sample Excel workbook with Badge_Library_MASTER data for testing

$ExcelPath = "$PSScriptRoot\Feature_Millwork_Test.xlsx"

# Create Excel application
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.DisplayAlerts = $false

# Create new workbook
$Workbook = $Excel.Workbooks.Add()

# Remove default sheets except first one
while ($Workbook.Worksheets.Count -gt 1) {
    $Workbook.Worksheets.Item(2).Delete()
}

# Rename first sheet
$Sheet = $Workbook.Worksheets.Item(1)
$Sheet.Name = "Badge_Library_MASTER"

# Define headers
$Headers = @(
    "Badge_Code",
    "Full_Description",
    "Material_Type",
    "Vendor",
    "Lead_Time_Weeks",
    "Cost_Unit",
    "Alert_Status",
    "Projects_Using",
    "Thickness",
    "Finish",
    "Core_Material",
    "Edge_Detail",
    "Notes",
    "Last_Updated",
    "Updated_By"
)

# Write headers
for ($i = 0; $i -lt $Headers.Count; $i++) {
    $Sheet.Cells.Item(1, $i + 1) = $Headers[$i]
    $Sheet.Cells.Item(1, $i + 1).Font.Bold = $true
    $Sheet.Cells.Item(1, $i + 1).Interior.ColorIndex = 15  # Gray background
}

# Sample badge data (realistic test data)
$BadgeData = @(
    @("PL1", "Plastic Laminate - Fenix NTA (1/2`" MDF Core)", "PLASTIC_LAMINATE_FENIX", "Pacific Plywood / 3-Form", 6, 175.00, "YES", "Project A,Project B", "1/2`"", "Matte", "MDF", "Eased", "Premium finish", "2025-11-20", "Steve"),
    @("PL2", "Plastic Laminate - Wilsonart (3/4`" Particleboard Core)", "PLASTIC_LAMINATE_STANDARD", "Pacific Plywood", 3, 85.00, "NO", "Project C", "3/4`"", "Standard", "Particleboard", "Square", "", "2025-11-15", "Sean"),
    @("WP1", "Wood Veneer - White Oak (Rift Cut)", "WOOD_VENEER_OAK", "Certainly Wood", 8, 320.00, "YES", "Project A,Project D", "3/4`"", "Clear Finish", "MDF", "Veneer Wrapped", "Long lead time", "2025-11-18", "Steve"),
    @("WP2", "Wood Veneer - Walnut (Flat Cut)", "WOOD_VENEER_WALNUT", "Certainly Wood", 8, 350.00, "YES", "Project B", "3/4`"", "Oil Rubbed", "Plywood", "Solid Edge", "Premium material", "2025-11-19", "Steve"),
    @("WP3", "Wood Veneer - Maple (Book Matched)", "WOOD_VENEER_MAPLE", "Certainly Wood", 7, 280.00, "NO", "", "1/2`"", "Natural", "MDF", "Veneer Wrapped", "", "2025-11-10", "John"),
    @("PP1", "Paint Grade - MDF Primed", "PAINT_GRADE_MDF", "Local Supplier", 2, 45.00, "NO", "Project C,Project E", "3/4`"", "Primed", "MDF", "Square", "Ready to paint", "2025-11-22", "Sean"),
    @("PP2", "Paint Grade - Poplar Hardwood", "PAINT_GRADE_WOOD", "Local Supplier", 2, 65.00, "NO", "Project E", "3/4`"", "Raw", "Poplar", "Solid Edge", "", "2025-11-21", "Sean"),
    @("SL1", "Solid Surface - Corian (1/2`")", "SOLID_SURFACE_CORIAN", "Dupont / 3-Form", 10, 450.00, "YES", "Project A", "1/2`"", "Polished", "Solid", "Fabricated", "Very long lead", "2025-11-17", "John"),
    @("SL2", "Solid Surface - Quartz (3/4`")", "SOLID_SURFACE_QUARTZ", "Caesarstone", 6, 380.00, "YES", "Project B", "3/4`"", "Honed", "Solid", "Polished Edge", "Stock dependent", "2025-11-16", "John"),
    @("GL1", "Glass - Back Painted (1/4`")", "GLASS_PAINTED", "Oldcastle", 4, 120.00, "NO", "Project D", "1/4`"", "Painted", "Tempered Glass", "Polished", "", "2025-11-14", "Steve")
)

# Write data rows
$Row = 2
foreach ($Badge in $BadgeData) {
    for ($i = 0; $i -lt $Badge.Count; $i++) {
        $Sheet.Cells.Item($Row, $i + 1) = $Badge[$i]
    }
    $Row++
}

# Format as table
$DataRange = $Sheet.Range("A1:O$($BadgeData.Count + 1)")
$ListObject = $Sheet.ListObjects.Add(
    [Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange,
    $DataRange,
    $null,
    [Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes
)
$ListObject.Name = "tblBadgeLibrary"
$ListObject.TableStyle = "TableStyleMedium2"

# Auto-fit columns
$Sheet.UsedRange.Columns.AutoFit() | Out-Null

# Add conditional formatting for Alert_Status
$AlertColumn = $Sheet.Range("G2:G$($BadgeData.Count + 1)")
$AlertCondition = $AlertColumn.FormatConditions.Add(
    [Microsoft.Office.Interop.Excel.XlFormatConditionType]::xlCellValue,
    [Microsoft.Office.Interop.Excel.XlFormatConditionOperator]::xlEqual,
    "YES"
)
$AlertCondition.Interior.ColorIndex = 6  # Yellow background

# Freeze top row
$Sheet.Select()
$Excel.ActiveWindow.SplitRow = 1
$Excel.ActiveWindow.FreezePanes = $true

# Save workbook
$Workbook.SaveAs($ExcelPath)
$Workbook.Close($false)
$Excel.Quit()

# Release COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "✅ Test Excel workbook created successfully!" -ForegroundColor Green
Write-Host "   Location: $ExcelPath" -ForegroundColor Cyan
Write-Host "   Records: $($BadgeData.Count) badges" -ForegroundColor Cyan
