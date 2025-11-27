using System.IO;
using System.IO.Pipes;
using FeatureMillwork.CommandBridge.Shared;
using FeatureMillwork.CommandBridge.Shared.Interfaces;
using FeatureMillwork.CommandBridge.Shared.Messages;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace FeatureMillwork.CommandBridge.Client.Services;

public class NamedPipeBridgeClient : IBridgeClient
{
    private readonly BridgeSettings _settings;
    private NamedPipeClientStream? _pipe;
    private StreamReader? _reader;
    private StreamWriter? _writer;
    private CancellationTokenSource? _readCts;
    private Task? _readTask;
    private bool _disposed;

    private static readonly JsonSerializerSettings JsonSettings = new()
    {
        ContractResolver = new DefaultContractResolver
        {
            NamingStrategy = new SnakeCaseNamingStrategy()
        },
        NullValueHandling = NullValueHandling.Ignore
    };

    public bool IsConnected => _pipe?.IsConnected ?? false;

    public event EventHandler<BridgeMessage>? MessageReceived;
    public event EventHandler<bool>? ConnectionStateChanged;
    public event EventHandler<Exception>? ErrorOccurred;

    public NamedPipeBridgeClient(BridgeSettings settings)
    {
        _settings = settings;
    }

    public async Task ConnectAsync(CancellationToken cancellationToken = default)
    {
        if (IsConnected) return;

        try
        {
            // Use In direction to match AutoCAD plugin's Out direction
            _pipe = new NamedPipeClientStream(
                ".",
                _settings.PipeName,
                PipeDirection.In,
                PipeOptions.Asynchronous);

            using var timeoutCts = new CancellationTokenSource(_settings.ConnectionTimeoutMs);
            using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken, timeoutCts.Token);

            await _pipe.ConnectAsync(linkedCts.Token);

            _reader = new StreamReader(_pipe);
            // Writer only available if pipe is bidirectional
            if (_pipe.CanWrite)
            {
                _writer = new StreamWriter(_pipe) { AutoFlush = true };
            }

            _readCts = new CancellationTokenSource();
            _readTask = ReadMessagesAsync(_readCts.Token);

            ConnectionStateChanged?.Invoke(this, true);
        }
        catch (Exception ex)
        {
            ErrorOccurred?.Invoke(this, ex);
            await DisconnectAsync();
            throw;
        }
    }

    public async Task DisconnectAsync()
    {
        if (_readCts != null)
        {
            await _readCts.CancelAsync();
            _readCts.Dispose();
            _readCts = null;
        }

        _writer?.Dispose();
        _reader?.Dispose();
        _pipe?.Dispose();

        _writer = null;
        _reader = null;
        _pipe = null;

        ConnectionStateChanged?.Invoke(this, false);
    }

    public async Task SendMessageAsync(BridgeMessage message, CancellationToken cancellationToken = default)
    {
        if (!IsConnected)
            throw new InvalidOperationException("Not connected to AutoCAD");

        if (_writer == null)
            throw new InvalidOperationException("Pipe is read-only, cannot send messages");

        var json = JsonConvert.SerializeObject(message, JsonSettings);
        await _writer.WriteLineAsync(json.AsMemory(), cancellationToken);
    }

    public async Task SendCommandAsync(string command, CancellationToken cancellationToken = default)
    {
        await SendMessageAsync(new BridgeMessage
        {
            Type = MessageType.Execute,
            Command = command
        }, cancellationToken);
    }

    public async Task SendLispAsync(string expression, CancellationToken cancellationToken = default)
    {
        await SendMessageAsync(new BridgeMessage
        {
            Type = MessageType.Lisp,
            Message = expression
        }, cancellationToken);
    }

    private async Task ReadMessagesAsync(CancellationToken cancellationToken)
    {
        try
        {
            while (!cancellationToken.IsCancellationRequested && _reader != null)
            {
                var line = await _reader.ReadLineAsync(cancellationToken);
                if (line == null)
                {
                    // Connection closed
                    await DisconnectAsync();
                    break;
                }

                try
                {
                    var message = JsonConvert.DeserializeObject<BridgeMessage>(line, JsonSettings);
                    if (message != null)
                    {
                        MessageReceived?.Invoke(this, message);
                    }
                }
                catch (JsonException)
                {
                    // Ignore malformed messages
                }
            }
        }
        catch (OperationCanceledException)
        {
            // Normal cancellation
        }
        catch (Exception ex)
        {
            ErrorOccurred?.Invoke(this, ex);
            await DisconnectAsync();
        }
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;

        _readCts?.Cancel();
        _readCts?.Dispose();
        _writer?.Dispose();
        _reader?.Dispose();
        _pipe?.Dispose();

        GC.SuppressFinalize(this);
    }
}
