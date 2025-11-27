using CommunityToolkit.Mvvm.ComponentModel;
using FeatureMillwork.CommandBridge.Client.Services;

namespace FeatureMillwork.CommandBridge.Client.ViewModels;

public partial class MonitorViewModel : ObservableObject
{
    private readonly StatisticsService _statistics;

    [ObservableProperty]
    private int _commandCount;

    [ObservableProperty]
    private int _errorCount;

    [ObservableProperty]
    private double _errorRate;

    [ObservableProperty]
    private double _averageExecutionTime;

    public MonitorViewModel(StatisticsService statistics)
    {
        _statistics = statistics;
        _statistics.StatisticsUpdated += OnStatisticsUpdated;
        UpdateStatistics();
    }

    private void OnStatisticsUpdated(object? sender, EventArgs e)
    {
        UpdateStatistics();
    }

    private void UpdateStatistics()
    {
        CommandCount = _statistics.CommandCount;
        ErrorCount = _statistics.ErrorCount;
        ErrorRate = Math.Round(_statistics.ErrorRate, 1);
        AverageExecutionTime = Math.Round(_statistics.AverageExecutionTime, 1);
    }
}
