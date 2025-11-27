using System.Collections.Specialized;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;
using FeatureMillwork.CommandBridge.Client.ViewModels;
using Microsoft.Extensions.DependencyInjection;

namespace FeatureMillwork.CommandBridge.Client.Views;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        DataContext = App.Services.GetRequiredService<MainViewModel>();

        // Auto-scroll log to bottom with debouncing
        if (DataContext is MainViewModel vm)
        {
            ((INotifyCollectionChanged)vm.LogEntries).CollectionChanged += (_, e) =>
            {
                if (e.Action == NotifyCollectionChangedAction.Add && vm.LogEntries.Count > 0)
                {
                    // Use BeginInvoke to defer scroll until after layout is complete
                    Dispatcher.BeginInvoke(DispatcherPriority.Background, () =>
                    {
                        try
                        {
                            LogList.ScrollIntoView(vm.LogEntries[^1]);
                        }
                        catch
                        {
                            // Ignore scroll errors during rapid updates
                        }
                    });
                }
            };
        }
    }

    protected override void OnClosed(EventArgs e)
    {
        if (DataContext is IDisposable disposable)
        {
            disposable.Dispose();
        }
        base.OnClosed(e);
    }
}
