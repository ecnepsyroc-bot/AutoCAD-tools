using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;

namespace Luxify.Layout
{
    public class FrameGenerator
    {
        public static void CreateSheet(Transaction tr, Database db, BlockTableRecord btr, Point3d origin)
        {
            // 1. Draw Frame
            Polyline pl = new Polyline();
            pl.AddVertexAt(0, new Point2d(origin.X, origin.Y), 0, 0, 0);
            pl.AddVertexAt(1, new Point2d(origin.X + GridEngine.SheetWidth, origin.Y), 0, 0, 0);
            pl.AddVertexAt(2, new Point2d(origin.X + GridEngine.SheetWidth, origin.Y - GridEngine.SheetHeight), 0, 0, 0);
            pl.AddVertexAt(3, new Point2d(origin.X, origin.Y - GridEngine.SheetHeight), 0, 0, 0);
            pl.Closed = true;
            pl.Layer = "PLOT_FRAME_PS";

            btr.AppendEntity(pl);
            tr.AddNewlyCreatedDBObject(pl, true);

            // 2. Insert Title Block
            TitleBlockManager.Insert(tr, db, btr, origin);
        }
    }
}
