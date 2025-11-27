using System.Collections.Concurrent;
using FeatureMillwork.CommandBridge.Shared.Interfaces;
using FeatureMillwork.CommandBridge.Shared.Messages;

namespace FeatureMillwork.CommandBridge.Client.Services;

public class StatisticsService
{
    private readonly IBridgeClient _client;
    private readonly ConcurrentDictionary<string, CommandHistoryItem> _activeCommands = new();
    private readonly ConcurrentDictionary<string, int> _errorPatterns = new();
    private readonly List<CommandHistoryItem> _commandHistory = new();
    private readonly object _historyLock = new();

    private DateTime _sessionStart;
    private int _commandCount;
    private int _errorCount;
    private double _totalExecutionTime;

    public event EventHandler? StatisticsUpdated;

    public int CommandCount => _commandCount;
    public int ErrorCount => _errorCount;
    public double ErrorRate => _commandCount > 0 ? (double)_errorCount / _commandCount * 100 : 0;
    public double AverageExecutionTime => _commandCount > 0 ? _totalExecutionTime / _commandCount : 0;
    public TimeSpan SessionDuration => DateTime.Now - _sessionStart;
    public double CommandsPerMinute => SessionDuration.TotalMinutes > 0 ? _commandCount / SessionDuration.TotalMinutes : 0;

    public IReadOnlyList<CommandHistoryItem> CommandHistory
    {
        get
        {
            lock (_historyLock)
            {
                return _commandHistory.ToList();
            }
        }
    }

    public IReadOnlyDictionary<string, int> ErrorPatterns => _errorPatterns;

    public StatisticsService(IBridgeClient client)
    {
        _client = client;
        _client.MessageReceived += OnMessageReceived;
        _client.ConnectionStateChanged += OnConnectionStateChanged;
        _sessionStart = DateTime.Now;
    }

    private void OnConnectionStateChanged(object? sender, bool connected)
    {
        if (connected)
        {
            Reset();
        }
    }

    private void OnMessageReceived(object? sender, BridgeMessage message)
    {
        switch (message.Type)
        {
            case MessageType.CommandStart:
            case MessageType.LispStart:
                TrackCommandStart(message);
                break;

            case MessageType.CommandEnd:
            case MessageType.LispEnd:
                TrackCommandEnd(message, CommandStatus.Completed);
                break;

            case MessageType.CommandCancelled:
            case MessageType.LispCancelled:
                TrackCommandEnd(message, CommandStatus.Cancelled);
                break;

            case MessageType.CommandFailed:
                TrackCommandEnd(message, CommandStatus.Failed);
                TrackError(message.Error ?? "Command failed");
                break;

            case MessageType.Error:
                TrackError(message.Message ?? "Unknown error");
                break;
        }
    }

    private void TrackCommandStart(BridgeMessage message)
    {
        var commandName = message.Command ?? message.FirstExpression ?? "Unknown";
        var item = new CommandHistoryItem
        {
            Command = commandName,
            Type = message.Type,
            StartTime = message.Timestamp,
            Status = CommandStatus.InProgress
        };

        _activeCommands[commandName] = item;

        lock (_historyLock)
        {
            _commandHistory.Add(item);
            // Keep history manageable
            if (_commandHistory.Count > 1000)
            {
                _commandHistory.RemoveAt(0);
            }
        }

        Interlocked.Increment(ref _commandCount);
        StatisticsUpdated?.Invoke(this, EventArgs.Empty);
    }

    private void TrackCommandEnd(BridgeMessage message, CommandStatus status)
    {
        var commandName = message.Command ?? "Unknown";

        if (_activeCommands.TryRemove(commandName, out var item))
        {
            item.EndTime = message.Timestamp;
            item.Status = status;
            item.Error = message.Error;

            if (item.DurationMs.HasValue)
            {
                Interlocked.Exchange(ref _totalExecutionTime,
                    _totalExecutionTime + item.DurationMs.Value);
            }
        }

        if (status == CommandStatus.Failed)
        {
            Interlocked.Increment(ref _errorCount);
        }

        StatisticsUpdated?.Invoke(this, EventArgs.Empty);
    }

    public void TrackError(string errorMessage)
    {
        var pattern = CategorizeError(errorMessage);
        _errorPatterns.AddOrUpdate(pattern, 1, (_, count) => count + 1);
        Interlocked.Increment(ref _errorCount);
        StatisticsUpdated?.Invoke(this, EventArgs.Empty);
    }

    private static string CategorizeError(string message)
    {
        var lowerMessage = message.ToLowerInvariant();

        if (lowerMessage.Contains("bad argument type")) return "Bad argument type";
        if (lowerMessage.Contains("too few arguments")) return "Too few arguments";
        if (lowerMessage.Contains("too many arguments")) return "Too many arguments";
        if (lowerMessage.Contains("null function")) return "Null function";
        if (lowerMessage.Contains("invalid selection")) return "Invalid selection";
        if (lowerMessage.Contains("object not found")) return "Object not found";
        if (lowerMessage.Contains("syntax error")) return "Syntax error";

        return "Other error";
    }

    public void Reset()
    {
        _activeCommands.Clear();
        _errorPatterns.Clear();

        lock (_historyLock)
        {
            _commandHistory.Clear();
        }

        _sessionStart = DateTime.Now;
        _commandCount = 0;
        _errorCount = 0;
        _totalExecutionTime = 0;

        StatisticsUpdated?.Invoke(this, EventArgs.Empty);
    }

    public SessionExport Export()
    {
        return new SessionExport
        {
            SessionStart = _sessionStart,
            SessionEnd = DateTime.Now,
            CommandCount = _commandCount,
            ErrorCount = _errorCount,
            ErrorRate = ErrorRate,
            AverageExecutionTime = AverageExecutionTime,
            CommandsPerMinute = CommandsPerMinute,
            ErrorPatterns = _errorPatterns.ToDictionary(x => x.Key, x => x.Value),
            CommandHistory = CommandHistory.ToList()
        };
    }
}

public class SessionExport
{
    public DateTime SessionStart { get; set; }
    public DateTime SessionEnd { get; set; }
    public int CommandCount { get; set; }
    public int ErrorCount { get; set; }
    public double ErrorRate { get; set; }
    public double AverageExecutionTime { get; set; }
    public double CommandsPerMinute { get; set; }
    public Dictionary<string, int> ErrorPatterns { get; set; } = new();
    public List<CommandHistoryItem> CommandHistory { get; set; } = new();
}
