using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;
using Luxify.Core;

namespace Luxify.Labeling;

public class LabelCommands
{
    [CommandMethod("LUX_LABEL_GEN")]
    public void GenerateLabel()
    {
        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        // 1. Input: Select Model Space Geometry
        PromptSelectionOptions pso = new PromptSelectionOptions();
        pso.MessageForAdding = "\nSelect geometry for label: ";
        
        PromptSelectionResult psr = ed.GetSelection(pso);
        if (psr.Status != PromptStatus.OK) return;

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            // 2. Calculation: Get Bounding Box
            Extents3d? bounds = null;

            foreach (SelectedObject so in psr.Value)
            {
                Entity ent = (Entity)tr.GetObject(so.ObjectId, OpenMode.ForRead);
                if (ent.Bounds.HasValue)
                {
                    if (bounds == null)
                        bounds = ent.Bounds.Value;
                    else
                        bounds.Value.AddExtents(ent.Bounds.Value);
                }
            }

            if (bounds == null) return;

            // 3. Action: Insert LABEL block
            // Mock Data Selection (In real app, we'd pick from a list or the last selected badge)
            LabelData mockData = new LabelData
            {
                ElevationLetter = "A",
                Description = "Cabinet Elevation",
                Note = "Verify Field Dims",
                DetailRef = "SK1",
                ArchSheetRef = "2-AD02"
            };

            // Calculate insertion point: MinPoint.X, MinPoint.Y - Offset
            double offset = 10.0;
            Point3d insertionPoint = new Point3d(bounds.Value.MinPoint.X, bounds.Value.MinPoint.Y - offset, 0);

            InsertLabelBlock(tr, db, insertionPoint, mockData);

            tr.Commit();
        }
    }

    private void InsertLabelBlock(Transaction tr, Database db, Point3d position, LabelData data)
    {
        BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
        BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

        // Check if "LABEL" block exists, if not create a placeholder
        ObjectId blockId;
        if (bt.Has("LABEL"))
        {
            blockId = bt["LABEL"];
        }
        else
        {
            // Create placeholder block
            BlockTableRecord newBlock = new BlockTableRecord();
            newBlock.Name = "LABEL";
            
            // Add some geometry to the block definition
            Circle c = new Circle(Point3d.Origin, Vector3d.ZAxis, 2.0);
            newBlock.AppendEntity(c);
            
            // Add attributes definitions
            AttributeDefinition att1 = new AttributeDefinition(Point3d.Origin, "A", "ELEV", "Elevation Letter", ObjectId.Null);
            newBlock.AppendEntity(att1);

            bt.UpgradeOpen();
            blockId = bt.Add(newBlock);
            tr.AddNewlyCreatedDBObject(newBlock, true);
        }

        // Insert Block Reference
        BlockReference br = new BlockReference(position, blockId);
        btr.AppendEntity(br);
        tr.AddNewlyCreatedDBObject(br, true);

        // Set Attributes (Mocking the attribute setting logic)
        // In a real scenario, we'd iterate AttributeDefinitions and create AttributeReferences.
        // For brevity, we'll just add a DBText below it to show it worked.
        
        DBText text = new DBText();
        text.Position = new Point3d(position.X, position.Y - 5, 0);
        text.Height = 2.0;
        text.TextString = $"Label: {data.Description} ({data.ElevationLetter})";
        
        btr.AppendEntity(text);
        tr.AddNewlyCreatedDBObject(text, true);
    }
}
