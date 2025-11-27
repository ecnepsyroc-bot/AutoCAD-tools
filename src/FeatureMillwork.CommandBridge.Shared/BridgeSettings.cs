namespace FeatureMillwork.CommandBridge.Shared;

/// <summary>
/// Configuration settings for the command bridge
/// </summary>
public class BridgeSettings
{
    /// <summary>
    /// Name of the named pipe for communication
    /// </summary>
    public string PipeName { get; set; } = "AutoCADCommandBridge";

    /// <summary>
    /// Whether to automatically connect on startup
    /// </summary>
    public bool AutoConnect { get; set; } = true;

    /// <summary>
    /// Whether to show timestamps in log output
    /// </summary>
    public bool ShowTimestamps { get; set; } = true;

    /// <summary>
    /// Whether to highlight errors in the UI
    /// </summary>
    public bool HighlightErrors { get; set; } = true;

    /// <summary>
    /// Connection timeout in milliseconds
    /// </summary>
    public int ConnectionTimeoutMs { get; set; } = 10000;

    /// <summary>
    /// Maximum number of commands to keep in history
    /// </summary>
    public int MaxHistoryItems { get; set; } = 1000;

    /// <summary>
    /// Bridge version
    /// </summary>
    public string Version { get; set; } = "2.0.0";
}
