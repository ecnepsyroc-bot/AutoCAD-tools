using System.Windows.Controls;

namespace Luxify.Badging;

public partial class BadgePalette : UserControl
{
    public BadgePalette()
    {
        InitializeComponent();
        DataContext = new BadgePaletteViewModel();
    }
}
