using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;

namespace Luxify.Layout;

public class LayoutCommands
{
    [CommandMethod("LUX_ADD_SHEET_ROW")]
    public void AddSheetRow()
    {
        AddSheet(false);
    }

    [CommandMethod("LUX_ADD_SHEET_COL")]
    public void AddSheetCol()
    {
        AddSheet(true);
    }

    private void AddSheet(bool isColumn)
    {
        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
            BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.PaperSpace], OpenMode.ForWrite);

            // Ensure Layer Exists
            string layerName = "PLOT_FRAME_PS";
            LayerTable lt = (LayerTable)tr.GetObject(db.LayerTableId, OpenMode.ForRead);
            if (!lt.Has(layerName))
            {
                lt.UpgradeOpen();
                LayerTableRecord newLayer = new LayerTableRecord();
                newLayer.Name = layerName;
                lt.Add(newLayer);
                tr.AddNewlyCreatedDBObject(newLayer, true);
            }

            // 1. Calculate next coordinate
            Point3d insertionPoint = GridEngine.GetNextInsertionPoint(tr, btr, isColumn);

            // 2. Create Sheet
            FrameGenerator.CreateSheet(tr, db, btr, insertionPoint);

            tr.Commit();
            ed.Regen();
        }
    }
}
