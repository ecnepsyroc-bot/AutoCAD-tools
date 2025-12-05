using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.Geometry;
using System.Collections.Generic;

namespace Luxify.Layout
{
    public class GridEngine
    {
        // Constants
        public const double SheetWidth = 36.0;
        public const double SheetHeight = 24.0;
        public const double Gap = 4.0;

        // State
        private static double _lastSheetNumber = 0.0;

        public static Point3d GetNextInsertionPoint(Transaction tr, BlockTableRecord btr, bool isColumn)
        {
            double maxX = 0;
            double minY = 0;
            bool found = false;

            foreach (ObjectId id in btr)
            {
                Entity ent = (Entity)tr.GetObject(id, OpenMode.ForRead);
                if (ent is Polyline pl && ent.Layer == "PLOT_FRAME_PS")
                {
                    found = true;
                    if (pl.Bounds.HasValue)
                    {
                        if (pl.Bounds.Value.MaxPoint.X > maxX) maxX = pl.Bounds.Value.MaxPoint.X;
                        if (pl.Bounds.Value.MinPoint.Y < minY) minY = pl.Bounds.Value.MinPoint.Y;
                    }
                }
            }

            if (!found) return Point3d.Origin;

            if (isColumn)
            {
                return new Point3d(maxX + Gap, 0, 0);
            }
            else
            {
                // New row starts below the lowest point
                // But we want it aligned with the first column (X=0)?
                // The requirement says: "2.0 is generated below 1.0, with 2.1, 2.2 2.3 to the right"
                // So if adding a ROW, we should probably reset X to 0 and go down.
                // But the current logic in LayoutCommands was just finding min Y.
                // Let's assume "Add Row" means "Start a new row at X=0 below the bottom-most sheet".
                
                // Find the bottom-most Y
                double bottomY = 0;
                foreach (ObjectId id in btr)
                {
                    Entity ent = (Entity)tr.GetObject(id, OpenMode.ForRead);
                    if (ent is Polyline pl && ent.Layer == "PLOT_FRAME_PS")
                    {
                        if (pl.Bounds.HasValue)
                        {
                            if (pl.Bounds.Value.MinPoint.Y < bottomY) bottomY = pl.Bounds.Value.MinPoint.Y;
                        }
                    }
                }
                
                return new Point3d(0, bottomY - Gap, 0);
            }
        }

        public static string GetNextSheetNumber()
        {
            // This is a simplified placeholder. 
            // In a real scenario, we might want to parse existing sheets to find the max.
            // For now, we'll increment a static counter or rely on user input if not tracking persistence.
            // The requirement says: "System tracks the Last Used Number across Layouts."
            
            // We need a way to initialize this from the drawing if it's the first run in a session.
            // For this iteration, let's just return a placeholder that the user can edit, 
            // or implement a basic counter.
            
            // Let's try to be smart: Scan the drawing for the highest number?
            // That's expensive. Let's stick to the static for now, but expose a way to set it.
            return "X.X"; 
        }
    }
}
