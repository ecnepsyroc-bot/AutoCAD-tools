using System;
using System.Windows.Forms.Integration;
using Autodesk.AutoCAD.Windows;
using Luxify.Bridge.Views;

namespace Luxify.Bridge
{
    public class BridgePalette
    {
        private static PaletteSet? _paletteSet;
        private static ElementHost? _elementHost;
        private static BridgeMonitorView? _view;

        public static void Show()
        {
            if (_paletteSet == null)
            {
                _paletteSet = new PaletteSet("Command Bridge Monitor", new Guid("D15C9AC6-2774-4531-8E2D-5C3F0D8E9A1B"));
                _paletteSet.Style = PaletteSetStyles.ShowAutoHideButton | 
                                    PaletteSetStyles.ShowCloseButton | 
                                    PaletteSetStyles.ShowPropertiesMenu;
                _paletteSet.MinimumSize = new System.Drawing.Size(300, 200);
                
                _elementHost = new ElementHost();
                _elementHost.Dock = System.Windows.Forms.DockStyle.Fill;
                _elementHost.AutoSize = true;
                
                _view = new BridgeMonitorView();
                _elementHost.Child = _view;
                
                _paletteSet.Add("Monitor", _elementHost);
            }

            _paletteSet.Visible = true;
        }
    }
}
