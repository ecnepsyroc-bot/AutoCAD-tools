using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;

namespace Luxify.Badging;

public class BadgeJig : EntityJig
{
    private Point3d _position;
    private readonly BlockReference _br;

    public BadgeJig(BlockReference br) : base(br)
    {
        _br = br;
        _position = br.Position;
    }

    protected override SamplerStatus Sampler(JigPrompts prompts)
    {
        JigPromptPointOptions opts = new JigPromptPointOptions("\nSelect insertion point: ");
        opts.UserInputControls = UserInputControls.Accept3dCoordinates;

        PromptPointResult ppr = prompts.AcquirePoint(opts);

        if (ppr.Status == PromptStatus.OK)
        {
            if (_position.DistanceTo(ppr.Value) < Tolerance.Global.EqualPoint)
                return SamplerStatus.NoChange;

            _position = ppr.Value;
            return SamplerStatus.OK;
        }

        return SamplerStatus.Cancel;
    }

    protected override bool Update()
    {
        _br.Position = _position;
        return true;
    }

    public static bool Jig(BlockReference br)
    {
        BadgeJig jig = new BadgeJig(br);
        Document doc = Application.DocumentManager.MdiActiveDocument;
        PromptResult pr = doc.Editor.Drag(jig);
        return pr.Status == PromptStatus.OK;
    }
}
