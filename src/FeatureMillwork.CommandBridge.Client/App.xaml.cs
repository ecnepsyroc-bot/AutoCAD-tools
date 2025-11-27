using System.Windows;
using FeatureMillwork.CommandBridge.Client.Services;
using FeatureMillwork.CommandBridge.Client.ViewModels;
using FeatureMillwork.CommandBridge.Shared;
using FeatureMillwork.CommandBridge.Shared.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace FeatureMillwork.CommandBridge.Client;

public partial class App : Application
{
    public static IServiceProvider Services { get; private set; } = null!;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var services = new ServiceCollection();
        ConfigureServices(services);
        Services = services.BuildServiceProvider();
    }

    private static void ConfigureServices(IServiceCollection services)
    {
        // Settings
        services.AddSingleton<BridgeSettings>();

        // Services
        services.AddSingleton<IBridgeClient, NamedPipeBridgeClient>();
        services.AddSingleton<StatisticsService>();

        // ViewModels
        services.AddSingleton<MainViewModel>();
        services.AddTransient<MonitorViewModel>();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        if (Services is IDisposable disposable)
        {
            disposable.Dispose();
        }
        base.OnExit(e);
    }
}
