namespace FeatureMillwork.CommandBridge.Shared.Messages;

/// <summary>
/// Represents a command in the execution history
/// </summary>
public class CommandHistoryItem
{
    public string Command { get; set; } = string.Empty;
    public MessageType Type { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public TimeSpan? Duration => EndTime.HasValue ? EndTime.Value - StartTime : null;
    public double? DurationMs => Duration?.TotalMilliseconds;
    public CommandStatus Status { get; set; } = CommandStatus.InProgress;
    public string? Error { get; set; }
}

public enum CommandStatus
{
    InProgress,
    Completed,
    Failed,
    Cancelled
}
