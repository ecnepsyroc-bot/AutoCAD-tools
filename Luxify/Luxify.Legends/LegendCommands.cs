using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;
using Luxify.Core;

namespace Luxify.Legends;

public class LegendCommands
{
    [CommandMethod("LUX_GEN_LEGEND")]
    public void GenerateLegend()
    {
        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        // 1. Scanner: Select Crossing Polygon inside a specific PLOT_FRAME_PS
        // For simplicity, we'll ask user to select the frame polyline first.
        PromptEntityOptions peo = new PromptEntityOptions("\nSelect Plot Frame Polyline: ");
        peo.SetRejectMessage("\nMust be a Polyline.");
        peo.AddAllowedClass(typeof(Polyline), true);
        
        PromptEntityResult per = ed.GetEntity(peo);
        if (per.Status != PromptStatus.OK) return;

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            Polyline frame = (Polyline)tr.GetObject(per.ObjectId, OpenMode.ForRead);
            
            // Get polygon points for selection
            Point3dCollection points = new Point3dCollection();
            for (int i = 0; i < frame.NumberOfVertices; i++)
            {
                points.Add(frame.GetPoint3dAt(i));
            }

            // Select objects inside the frame
            PromptSelectionResult psr = ed.SelectCrossingPolygon(points);
            if (psr.Status != PromptStatus.OK) return;

            // 2. Harvest: Collect unique Badges
            HashSet<string> uniqueCodes = new HashSet<string>();
            List<LuxifyLeaf> legendItems = new List<LuxifyLeaf>();

            foreach (SelectedObject so in psr.Value)
            {
                Entity ent = (Entity)tr.GetObject(so.ObjectId, OpenMode.ForRead);
                if (ent is BlockReference br)
                {
                    // Check if it's a badge (e.g., has XAttributes or specific name)
                    // For this phase, we assume any block with "PL" in name or attributes is a badge.
                    // Let's assume we can extract data.
                    // In a real app, we'd read XData or Attributes.
                    // Mocking extraction:
                    string code = "PL" + br.Handle.Value.ToString().Substring(0, 3); // Fake code
                    if (!uniqueCodes.Contains(code))
                    {
                        uniqueCodes.Add(code);
                        legendItems.Add(new LuxifyLeaf 
                        { 
                            Xylem = new LeafXylem { Code = code, Shorthand = $"Spec for {code}" } 
                        });
                    }
                }
            }

            // 3. Draw Legend
            // Find Title Block insertion point (Top-Right of Title Block).
            // We'll assume the Title Block is inside the frame or we use the frame's top-right corner.
            // Let's use Frame Top-Right - Offset.
            
            if (frame.Bounds.HasValue)
            {
                Point3d startPoint = new Point3d(frame.Bounds.Value.MaxPoint.X - 2, frame.Bounds.Value.MaxPoint.Y - 2, 0);
                DrawLegendStack(tr, frame.BlockId, startPoint, legendItems);
            }

            tr.Commit();
        }
    }

    private void DrawLegendStack(Transaction tr, ObjectId paperSpaceId, Point3d startPoint, List<LuxifyLeaf> items)
    {
        BlockTableRecord btr = (BlockTableRecord)tr.GetObject(paperSpaceId, OpenMode.ForWrite);
        double currentY = startPoint.Y;

        foreach (var item in items)
        {
            // Draw Text
            DBText text = new DBText();
            text.Position = new Point3d(startPoint.X, currentY, 0);
            text.Height = 0.5;
            text.TextString = $"{item.Xylem.Code}: {item.Xylem.Shorthand}";
            
            btr.AppendEntity(text);
            tr.AddNewlyCreatedDBObject(text, true);

            // Stack upwards? Spec says "Stack upwards".
            // If starting from Top-Right, maybe we stack downwards?
            // "Start Point: Top-Right of Title Block. Direction: Stack upwards."
            // Okay, so we go UP from the title block.
            currentY += 1.0; 
        }
    }
}
