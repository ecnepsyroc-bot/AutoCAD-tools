using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.Windows;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Luxify.Badging;

[assembly: CommandClass(typeof(BadgingCommands))]

namespace Luxify.Badging;

public class BadgingCommands
{
    private static PaletteSet? _ps;
    private static BadgePalette? _palette;

    public static Luxify.Core.LuxifyLeaf? ActiveBadge { get; set; }

    [CommandMethod("LUX_SHOW_PALETTE")]
    public void ShowPalette()
    {
        if (_ps == null)
        {
            _ps = new PaletteSet("Luxify Badges");
            _palette = new BadgePalette();
            _ps.AddVisual("Badges", _palette);
            _ps.Style = PaletteSetStyles.ShowAutoHideButton | 
                        PaletteSetStyles.ShowCloseButton | 
                        PaletteSetStyles.ShowPropertiesMenu;
            _ps.MinimumSize = new System.Drawing.Size(300, 400);
            _ps.Dock = DockSides.Left;
        }

        _ps.Visible = true;
    }

    [CommandMethod("LUX_PLACE_BADGE", CommandFlags.Modal)]
    public void PlaceBadge()
    {
        if (ActiveBadge == null) return;

        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
            BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

            // Ensure Block Definition exists
            ObjectId blockId;
            string blockName = "BADGE_BLOCK";
            if (bt.Has(blockName))
            {
                blockId = bt[blockName];
            }
            else
            {
                // Create placeholder block
                BlockTableRecord newBlock = new BlockTableRecord();
                newBlock.Name = blockName;
                
                // Geometry: Rectangle (Base)
                Polyline pl = new Polyline();
                pl.AddVertexAt(0, new Point2d(0, 0), 0, 0, 0);
                pl.AddVertexAt(1, new Point2d(10, 0), 0, 0, 0);
                pl.AddVertexAt(2, new Point2d(10, 5), 0, 0, 0);
                pl.AddVertexAt(3, new Point2d(0, 5), 0, 0, 0);
                pl.Closed = true;
                newBlock.AppendEntity(pl);

                // Attributes
                AttributeDefinition att1 = new AttributeDefinition(Point3d.Origin, "PL00", "CODE", "Code", ObjectId.Null);
                newBlock.AppendEntity(att1);

                bt.UpgradeOpen();
                blockId = bt.Add(newBlock);
                tr.AddNewlyCreatedDBObject(newBlock, true);
            }

            // Create Block Reference
            BlockReference br = new BlockReference(Point3d.Origin, blockId);
            btr.AppendEntity(br);
            tr.AddNewlyCreatedDBObject(br, true);

            // Run Jig
            BadgeJig jig = new BadgeJig(br);
            PromptResult pr = ed.Drag(jig);

            if (pr.Status == PromptStatus.OK)
            {
                // Set Attributes based on ActiveBadge
                tr.Commit();
            }
            else
            {
                tr.Abort();
            }
        }
    }

    public static void UpdateOverlays(IEnumerable<Luxify.Core.LuxifyLeaf> badges)
    {
        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            // 1. Setup Layer
            string layerName = "LUX_OVERLAYS";
            LayerTable lt = (LayerTable)tr.GetObject(db.LayerTableId, OpenMode.ForRead);
            if (!lt.Has(layerName))
            {
                lt.UpgradeOpen();
                LayerTableRecord ltr = new LayerTableRecord();
                ltr.Name = layerName;
                ltr.Color = Autodesk.AutoCAD.Colors.Color.FromColorIndex(Autodesk.AutoCAD.Colors.ColorMethod.ByAci, 1); // Red default
                lt.Add(ltr);
                tr.AddNewlyCreatedDBObject(ltr, true);
            }

            // 2. Clear existing overlays
            BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
            BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

            // Fast way: iterate modelspace and check layer (inefficient but simple)
            // Better: SelectAll with filter
            TypedValue[] filter = { new TypedValue((int)DxfCode.LayerName, layerName) };
            SelectionFilter sf = new SelectionFilter(filter);
            PromptSelectionResult psr = ed.SelectAll(sf);

            if (psr.Status == PromptStatus.OK)
            {
                foreach (ObjectId id in psr.Value.GetObjectIds())
                {
                    Entity ent = (Entity)tr.GetObject(id, OpenMode.ForWrite);
                    ent.Erase();
                }
            }

            // 3. Draw new overlays
            // First, map codes to status for fast lookup
            var statusMap = new System.Collections.Generic.Dictionary<string, Luxify.Core.LuxifyLeaf>();
            foreach (var b in badges) statusMap[b.Xylem.Code] = b;

            // Find all badge blocks
            TypedValue[] blockFilter = { 
                new TypedValue((int)DxfCode.Start, "INSERT"),
                new TypedValue((int)DxfCode.BlockName, "BADGE_BLOCK")
            };
            PromptSelectionResult blockPsr = ed.SelectAll(new SelectionFilter(blockFilter));

            if (blockPsr.Status == PromptStatus.OK)
            {
                foreach (ObjectId id in blockPsr.Value.GetObjectIds())
                {
                    BlockReference br = (BlockReference)tr.GetObject(id, OpenMode.ForRead);
                    string code = GetAttributeValue(br, "CODE", tr);

                    if (statusMap.TryGetValue(code, out var leaf))
                    {
                        if (leaf.Phloem.IsSpecDirty)
                        {
                            // Draw Triangle
                            Polyline tri = new Polyline();
                            tri.AddVertexAt(0, new Point2d(0, 5), 0, 0, 0);
                            tri.AddVertexAt(1, new Point2d(5, 13.66), 0, 0, 0);
                            tri.AddVertexAt(2, new Point2d(10, 5), 0, 0, 0);
                            tri.Closed = true;
                            tri.ColorIndex = 1; // Red
                            tri.Layer = layerName;
                            
                            // Transform to block position
                            tri.TransformBy(br.BlockTransform);
                            
                            btr.AppendEntity(tri);
                            tr.AddNewlyCreatedDBObject(tri, true);
                        }

                        if (leaf.Phloem.IsStockCritical)
                        {
                            // Draw Octagon (approximated as circle or polygon)
                            Circle oct = new Circle();
                            oct.Center = new Point3d(5, 2.5, 0);
                            oct.Radius = 4;
                            oct.ColorIndex = 30; // Orange-ish
                            oct.Layer = layerName;

                            // Transform
                            oct.TransformBy(br.BlockTransform);

                            btr.AppendEntity(oct);
                            tr.AddNewlyCreatedDBObject(oct, true);
                        }
                    }
                }
            }

            tr.Commit();
        }
        
        ed.Regen();
    }

    private static string GetAttributeValue(BlockReference br, string tag, Transaction tr)
    {
        foreach (ObjectId id in br.AttributeCollection)
        {
            AttributeReference att = (AttributeReference)tr.GetObject(id, OpenMode.ForRead);
            if (att.Tag.Equals(tag, System.StringComparison.InvariantCultureIgnoreCase))
            {
                return att.TextString;
            }
        }
        return string.Empty;
    }
}
