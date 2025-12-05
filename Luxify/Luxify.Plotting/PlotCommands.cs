using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.PlottingServices;
using Autodesk.AutoCAD.Runtime;

namespace Luxify.Plotting;

public class PlotCommands
{
    [CommandMethod("LUX_PLOT_BATCH")]
    public void BatchPlot()
    {
        Document doc = Application.DocumentManager.MdiActiveDocument;
        Database db = doc.Database;
        Editor ed = doc.Editor;

        // UI Fork: Path A or B
        PromptKeywordOptions pko = new PromptKeywordOptions("\nSelect Output Path [Factory/Project]: ");
        pko.Keywords.Add("Factory");
        pko.Keywords.Add("Project");
        pko.Keywords.Default = "Factory";

        PromptResult pr = ed.GetKeywords(pko);
        if (pr.Status != PromptStatus.OK) return;

        string pathType = pr.StringResult;
        string outputDir = pathType == "Factory" ? @"C:\Temp\Luxify\Shops\Factory Orders" : @"C:\Temp\Luxify\Project Orders";
        System.IO.Directory.CreateDirectory(outputDir);

        using (Transaction tr = db.TransactionManager.StartTransaction())
        {
            BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
            BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.PaperSpace], OpenMode.ForRead);

            // Scanner: Find all PLOT_FRAME_PS polylines
            foreach (ObjectId id in btr)
            {
                Entity ent = (Entity)tr.GetObject(id, OpenMode.ForRead);
                if (ent is Polyline pl && ent.Layer == "PLOT_FRAME_PS")
                {
                    PlotSheet(doc, pl, outputDir);
                }
            }
            tr.Commit();
        }
    }

    private void PlotSheet(Document doc, Polyline frame, string outputDir)
    {
        // Settings
        string device = "DWG To PDF.pc3";
        string style = "feature.ctb";
        string filename = System.IO.Path.Combine(outputDir, $"FO123_{frame.Handle}.pdf");

        // Plot Logic (Simplified for non-interactive environment)
        // In a real plugin, we would use PlotEngine.
        
        doc.Editor.WriteMessage($"\n[Mock Plot] Plotting frame {frame.Handle} to {filename} using {device}...");
        
        // Simulating file creation
        System.IO.File.WriteAllText(filename, "Mock PDF Content");
    }
}
