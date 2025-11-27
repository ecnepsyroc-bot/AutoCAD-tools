using System.Collections.ObjectModel;
using System.IO;
using System.Windows;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using FeatureMillwork.CommandBridge.Client.Services;
using FeatureMillwork.CommandBridge.Shared;
using FeatureMillwork.CommandBridge.Shared.Interfaces;
using FeatureMillwork.CommandBridge.Shared.Messages;
using Newtonsoft.Json;

namespace FeatureMillwork.CommandBridge.Client.ViewModels;

public partial class MainViewModel : ObservableObject, IDisposable
{
    private readonly IBridgeClient _client;
    private readonly StatisticsService _statistics;
    private readonly BridgeSettings _settings;

    [ObservableProperty]
    private bool _isConnected;

    [ObservableProperty]
    private string _connectionStatus = "Disconnected";

    [ObservableProperty]
    private string _autoCADVersion = "";

    [ObservableProperty]
    private int _commandCount;

    [ObservableProperty]
    private int _errorCount;

    [ObservableProperty]
    private double _errorRate;

    [ObservableProperty]
    private double _averageExecutionTime;

    [ObservableProperty]
    private double _commandsPerMinute;

    [ObservableProperty]
    private string _sessionDuration = "00:00:00";

    [ObservableProperty]
    private string _commandInput = "";

    [ObservableProperty]
    private string _lispInput = "";

    public ObservableCollection<LogEntry> LogEntries { get; } = new();
    public ObservableCollection<CommandHistoryItem> RecentCommands { get; } = new();
    public ObservableCollection<ErrorPatternItem> TopErrors { get; } = new();

    private System.Timers.Timer? _sessionTimer;

    public MainViewModel(IBridgeClient client, StatisticsService statistics, BridgeSettings settings)
    {
        _client = client;
        _statistics = statistics;
        _settings = settings;

        _client.MessageReceived += OnMessageReceived;
        _client.ConnectionStateChanged += OnConnectionStateChanged;
        _client.ErrorOccurred += OnErrorOccurred;

        _statistics.StatisticsUpdated += OnStatisticsUpdated;

        StartSessionTimer();

        if (_settings.AutoConnect)
        {
            _ = ConnectAsync();
        }
    }

    private void StartSessionTimer()
    {
        _sessionTimer = new System.Timers.Timer(1000);
        _sessionTimer.Elapsed += (_, _) =>
        {
            Application.Current?.Dispatcher.Invoke(() =>
            {
                SessionDuration = _statistics.SessionDuration.ToString(@"hh\:mm\:ss");
            });
        };
        _sessionTimer.Start();
    }

    private void OnConnectionStateChanged(object? sender, bool connected)
    {
        Application.Current?.Dispatcher.Invoke(() =>
        {
            IsConnected = connected;
            ConnectionStatus = connected ? "Connected" : "Disconnected";

            AddLogEntry(connected ? "Connected to AutoCAD" : "Disconnected from AutoCAD",
                connected ? LogLevel.Success : LogLevel.Info);
        });
    }

    private void OnMessageReceived(object? sender, BridgeMessage message)
    {
        Application.Current?.Dispatcher.Invoke(() =>
        {
            ProcessMessage(message);
        });
    }

    private void ProcessMessage(BridgeMessage message)
    {
        var (text, level) = message.Type switch
        {
            MessageType.Connected => ($"Connected to AutoCAD {message.AutoCADVersion}", LogLevel.Success),
            MessageType.CommandStart => ($"Command: {message.Command}", LogLevel.Info),
            MessageType.CommandEnd => ($"Command completed: {message.Command}", LogLevel.Success),
            MessageType.CommandFailed => ($"Command failed: {message.Command} - {message.Error}", LogLevel.Error),
            MessageType.CommandCancelled => ($"Command cancelled: {message.Command}", LogLevel.Warning),
            MessageType.LispStart => ($"LISP: {message.FirstExpression}", LogLevel.Info),
            MessageType.LispEnd => ("LISP completed", LogLevel.Success),
            MessageType.LispCancelled => ("LISP cancelled", LogLevel.Warning),
            MessageType.PromptString or MessageType.PromptPoint or MessageType.PromptSelection =>
                ($"Prompt: {message.Message}", LogLevel.Info),
            MessageType.Error => ($"Error: {message.Message}", LogLevel.Error),
            MessageType.Test => ($"Test: {message.Message} (Drawing: {message.Drawing})", LogLevel.Info),
            MessageType.SysVar => ($"{message.Variable} = {message.Value}", LogLevel.Info),
            MessageType.SysVarSet => ($"Set {message.Variable} = {message.Value}", LogLevel.Success),
            _ => (JsonConvert.SerializeObject(message), LogLevel.Debug)
        };

        if (message.Type == MessageType.Connected && !string.IsNullOrEmpty(message.AutoCADVersion))
        {
            AutoCADVersion = message.AutoCADVersion;
        }

        AddLogEntry(text, level, message.Timestamp);
    }

    private void AddLogEntry(string text, LogLevel level, DateTime? timestamp = null)
    {
        var entry = new LogEntry
        {
            Timestamp = timestamp ?? DateTime.Now,
            Message = text,
            Level = level
        };

        // Keep log manageable - remove old entries first
        while (LogEntries.Count >= 500)
        {
            LogEntries.RemoveAt(0);
        }

        LogEntries.Add(entry);
    }

    private void OnErrorOccurred(object? sender, Exception ex)
    {
        Application.Current?.Dispatcher.Invoke(() =>
        {
            AddLogEntry($"Connection error: {ex.Message}", LogLevel.Error);

            if (ex.Message.Contains("pipe"))
            {
                AddLogEntry("Make sure STARTBRIDGE is running in AutoCAD", LogLevel.Warning);
            }
        });
    }

    private void OnStatisticsUpdated(object? sender, EventArgs e)
    {
        Application.Current?.Dispatcher.Invoke(() =>
        {
            CommandCount = _statistics.CommandCount;
            ErrorCount = _statistics.ErrorCount;
            ErrorRate = Math.Round(_statistics.ErrorRate, 1);
            AverageExecutionTime = Math.Round(_statistics.AverageExecutionTime, 1);
            CommandsPerMinute = Math.Round(_statistics.CommandsPerMinute, 1);

            // Update recent commands
            RecentCommands.Clear();
            foreach (var cmd in _statistics.CommandHistory.TakeLast(10).Reverse())
            {
                RecentCommands.Add(cmd);
            }

            // Update top errors
            TopErrors.Clear();
            foreach (var (pattern, count) in _statistics.ErrorPatterns.OrderByDescending(x => x.Value).Take(5))
            {
                TopErrors.Add(new ErrorPatternItem { Pattern = pattern, Count = count });
            }
        });
    }

    [RelayCommand]
    private async Task ConnectAsync()
    {
        if (IsConnected) return;

        const int maxRetries = 3;
        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                ConnectionStatus = attempt == 1 ? "Connecting..." : $"Connecting (attempt {attempt}/{maxRetries})...";
                AddLogEntry($"Attempting to connect to AutoCAD bridge...", LogLevel.Info);
                await _client.ConnectAsync();
                return; // Success
            }
            catch (Exception ex)
            {
                AddLogEntry($"Connection attempt {attempt} failed: {ex.Message}", LogLevel.Warning);

                if (attempt < maxRetries)
                {
                    await Task.Delay(2000); // Wait before retry
                }
                else
                {
                    ConnectionStatus = "Disconnected";
                    AddLogEntry("Failed to connect. Make sure STARTBRIDGE is running in AutoCAD.", LogLevel.Error);
                }
            }
        }
    }

    [RelayCommand]
    private async Task DisconnectAsync()
    {
        if (!IsConnected) return;
        await _client.DisconnectAsync();
    }

    [RelayCommand]
    private async Task SendCommandAsync()
    {
        if (!IsConnected || string.IsNullOrWhiteSpace(CommandInput)) return;

        try
        {
            await _client.SendCommandAsync(CommandInput);
            AddLogEntry($"Sent: {CommandInput}", LogLevel.Info);
            CommandInput = "";
        }
        catch (Exception ex)
        {
            AddLogEntry($"Failed to send command: {ex.Message}", LogLevel.Error);
        }
    }

    [RelayCommand]
    private async Task SendLispAsync()
    {
        if (!IsConnected || string.IsNullOrWhiteSpace(LispInput)) return;

        try
        {
            await _client.SendLispAsync(LispInput);
            AddLogEntry($"Sent LISP ({LispInput.Length} chars)", LogLevel.Info);
        }
        catch (Exception ex)
        {
            AddLogEntry($"Failed to send LISP: {ex.Message}", LogLevel.Error);
        }
    }

    [RelayCommand]
    private void ClearLog()
    {
        LogEntries.Clear();
        _statistics.Reset();
    }

    [RelayCommand]
    private async Task ExportSessionAsync()
    {
        var export = _statistics.Export();
        var json = JsonConvert.SerializeObject(export, Formatting.Indented);

        var fileName = $"session-{DateTime.Now:yyyyMMdd-HHmmss}.json";
        var path = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), fileName);

        await File.WriteAllTextAsync(path, json);
        AddLogEntry($"Session exported to {path}", LogLevel.Success);
    }

    public void Dispose()
    {
        _sessionTimer?.Stop();
        _sessionTimer?.Dispose();
        _client.MessageReceived -= OnMessageReceived;
        _client.ConnectionStateChanged -= OnConnectionStateChanged;
        _client.ErrorOccurred -= OnErrorOccurred;
        _statistics.StatisticsUpdated -= OnStatisticsUpdated;
        GC.SuppressFinalize(this);
    }
}

public class LogEntry
{
    public DateTime Timestamp { get; set; }
    public string Message { get; set; } = "";
    public LogLevel Level { get; set; }
    public string TimestampFormatted => Timestamp.ToString("HH:mm:ss.fff");
}

public enum LogLevel
{
    Debug,
    Info,
    Success,
    Warning,
    Error
}

public class ErrorPatternItem
{
    public string Pattern { get; set; } = "";
    public int Count { get; set; }
}
