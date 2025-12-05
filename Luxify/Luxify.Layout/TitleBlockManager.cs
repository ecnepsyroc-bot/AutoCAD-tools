using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using System;

namespace Luxify.Layout
{
    public class TitleBlockManager
    {
        public static void Insert(Transaction tr, Database db, BlockTableRecord btr, Point3d origin)
        {
            BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
            string blockName = "TITLE";
            ObjectId blockId;

            if (!bt.Has(blockName))
            {
                blockId = CreateTitleBlockDef(tr, bt);
            }
            else
            {
                blockId = bt[blockName];
            }

            // Insert at bottom-right of the sheet
            // Sheet is 36x24. Origin is Top-Left.
            // Bottom-Right is (Origin.X + 36, Origin.Y - 24)
            Point3d insertPoint = new Point3d(origin.X + GridEngine.SheetWidth, origin.Y - GridEngine.SheetHeight, 0);

            BlockReference br = new BlockReference(insertPoint, blockId);
            btr.AppendEntity(br);
            tr.AddNewlyCreatedDBObject(br, true);

            // Add Attributes
            BlockTableRecord blockDef = (BlockTableRecord)tr.GetObject(blockId, OpenMode.ForRead);
            foreach (ObjectId id in blockDef)
            {
                Entity ent = (Entity)tr.GetObject(id, OpenMode.ForRead);
                if (ent is AttributeDefinition attDef)
                {
                    AttributeReference attRef = new AttributeReference();
                    attRef.SetAttributeFromBlock(attDef, br.BlockTransform);
                    
                    // Set Default Values
                    // In a real system, we'd pass a context object with these values
                    switch (attDef.Tag)
                    {
                        case "1": attRef.TextString = GridEngine.GetNextSheetNumber(); break;
                        case "DATE": attRef.TextString = DateTime.Now.ToString("MM/dd/yy"); break;
                        // Keep other defaults
                    }

                    br.AttributeCollection.AppendAttribute(attRef);
                    tr.AddNewlyCreatedDBObject(attRef, true);
                }
            }
        }

        private static ObjectId CreateTitleBlockDef(Transaction tr, BlockTable bt)
        {
            bt.UpgradeOpen();
            BlockTableRecord btr = new BlockTableRecord();
            btr.Name = "TITLE";
            btr.Origin = Point3d.Origin; 

            // Draw a placeholder frame (4" wide x 24" high)
            // Origin is bottom-right of the sheet, so this should extend left and up?
            // Or if the block is inserted at bottom-right, and we want it to be the right strip:
            // It should go from (0,0) to (-4, 24).
            
            Polyline frame = new Polyline();
            frame.AddVertexAt(0, new Point2d(-4, 0), 0, 0, 0);
            frame.AddVertexAt(1, new Point2d(0, 0), 0, 0, 0);
            frame.AddVertexAt(2, new Point2d(0, 24), 0, 0, 0);
            frame.AddVertexAt(3, new Point2d(-4, 24), 0, 0, 0);
            frame.Closed = true;
            btr.AppendEntity(frame);

            // Add Attributes
            double y = 23.0; // Start from top
            AddAtt(btr, "CHK_DESIGN", "For Design Review", "X", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "CHK_CONST", "For Construction", "X", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "FO#", "ENTER FO#", "123456", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "PROJECT", "ENTER PROJECT", "PROJECT NAME", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "CONTRACTOR", "ENTER G.C.", "CONTRACTOR", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "ARCHITECT", "ENTER ARCHITECT", "ARCHITECT", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "PRODUCT_DESCRIPTION", "ENTER TITLE", "TITLE", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "DATE", "ENTER DATE", "DATE", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "REVISION", "Enter Revision Number", "0", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "DRAWNBY", "Enter draftsman", "NAME", new Point3d(-3.5, y -= 1.0, 0));
            AddAtt(btr, "N.T.S", "ENTER SCALE", "1:1", new Point3d(-3.5, y -= 1.0, 0));
            
            // Sheet Number at bottom right
            AddAtt(btr, "1", "ENTER SHEET", "1.0", new Point3d(-0.5, 0.5, 0)); 

            ObjectId id = bt.Add(btr);
            tr.AddNewlyCreatedDBObject(btr, true);
            return id;
        }

        private static void AddAtt(BlockTableRecord btr, string tag, string prompt, string def, Point3d pos)
        {
            AttributeDefinition att = new AttributeDefinition(pos, def, tag, prompt, ObjectId.Null);
            att.Height = 0.125;
            btr.AppendEntity(att);
        }
    }
}
