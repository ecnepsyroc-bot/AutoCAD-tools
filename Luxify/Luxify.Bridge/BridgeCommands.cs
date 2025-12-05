using Autodesk.AutoCAD.Runtime;
using Luxify.Bridge;

[assembly: CommandClass(typeof(BridgeCommands))]

namespace Luxify.Bridge
{
    public class BridgeCommands
    {
        [CommandMethod("BRIDGE-UI")]
        public void ShowBridgeUI()
        {
            BridgePalette.Show();
        }
    }
}
