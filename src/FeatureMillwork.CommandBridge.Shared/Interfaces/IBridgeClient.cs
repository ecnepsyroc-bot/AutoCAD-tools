using FeatureMillwork.CommandBridge.Shared.Messages;

namespace FeatureMillwork.CommandBridge.Shared.Interfaces;

/// <summary>
/// Interface for bridge client implementations
/// </summary>
public interface IBridgeClient : IDisposable
{
    /// <summary>
    /// Whether the client is currently connected
    /// </summary>
    bool IsConnected { get; }

    /// <summary>
    /// Connect to the AutoCAD bridge
    /// </summary>
    Task ConnectAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Disconnect from the bridge
    /// </summary>
    Task DisconnectAsync();

    /// <summary>
    /// Send a message to AutoCAD
    /// </summary>
    Task SendMessageAsync(BridgeMessage message, CancellationToken cancellationToken = default);

    /// <summary>
    /// Send an AutoCAD command
    /// </summary>
    Task SendCommandAsync(string command, CancellationToken cancellationToken = default);

    /// <summary>
    /// Send LISP code for execution
    /// </summary>
    Task SendLispAsync(string expression, CancellationToken cancellationToken = default);

    /// <summary>
    /// Event raised when a message is received
    /// </summary>
    event EventHandler<BridgeMessage>? MessageReceived;

    /// <summary>
    /// Event raised when connection state changes
    /// </summary>
    event EventHandler<bool>? ConnectionStateChanged;

    /// <summary>
    /// Event raised when an error occurs
    /// </summary>
    event EventHandler<Exception>? ErrorOccurred;
}
