using System.IO.Pipes;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
using FeatureMillwork.CommandBridge.Shared;
using FeatureMillwork.CommandBridge.Shared.Messages;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace FeatureMillwork.CommandBridge.AutoCAD;

public class CommandMonitor : IExtensionApplication
{
    private static NamedPipeServerStream? _pipeServer;
    private static StreamWriter? _pipeWriter;
    private static StreamReader? _pipeReader;
    private static bool _isMonitoring;
    private static CancellationTokenSource? _cancellationTokenSource;
    private static Task? _serverTask;
    private static Task? _readerTask;
    private static Document? _activeDoc;
    private static readonly BridgeSettings _settings = new();

    private static readonly JsonSerializerSettings _jsonSettings = new()
    {
        ContractResolver = new DefaultContractResolver
        {
            NamingStrategy = new SnakeCaseNamingStrategy()
        },
        NullValueHandling = NullValueHandling.Ignore,
        Formatting = Formatting.None
    };

    public void Initialize()
    {
        try
        {
            StartMonitoring();
        }
        catch (System.Exception ex)
        {
            WriteToCommandLine($"CommandBridge initialization failed: {ex.Message}");
        }
    }

    public void Terminate()
    {
        StopMonitoringInternal();
    }

    [CommandMethod("STARTBRIDGE")]
    public static void StartMonitoring()
    {
        if (_isMonitoring)
        {
            WriteToCommandLine("Command Bridge is already running.");
            return;
        }

        try
        {
            _cancellationTokenSource = new CancellationTokenSource();
            _isMonitoring = true;

            _serverTask = Task.Run(() => RunPipeServerAsync(_cancellationTokenSource.Token));

            HookAutoCADEvents();
            WriteToCommandLine("Command Bridge started successfully.");
        }
        catch (System.Exception ex)
        {
            WriteToCommandLine($"Failed to start Command Bridge: {ex.Message}");
            _isMonitoring = false;
        }
    }

    [CommandMethod("STOPBRIDGE")]
    public static void StopMonitoring()
    {
        StopMonitoringInternal();
    }

    private static void StopMonitoringInternal()
    {
        if (!_isMonitoring)
        {
            WriteToCommandLine("Command Bridge is not running.");
            return;
        }

        try
        {
            UnhookAutoCADEvents();

            _cancellationTokenSource?.Cancel();

            if (_pipeWriter != null && _pipeServer?.IsConnected == true)
            {
                try
                {
                    SendMessage(new BridgeMessage { Type = MessageType.Shutdown });
                }
                catch { /* Ignore errors during shutdown */ }
            }

            _pipeWriter?.Dispose();
            _pipeReader?.Dispose();
            _pipeServer?.Dispose();

            _pipeWriter = null;
            _pipeReader = null;
            _pipeServer = null;

            _isMonitoring = false;
            WriteToCommandLine("Command Bridge stopped.");
        }
        catch (System.Exception ex)
        {
            WriteToCommandLine($"Error stopping Command Bridge: {ex.Message}");
        }
    }

    private static async Task RunPipeServerAsync(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                _pipeServer = new NamedPipeServerStream(
                    _settings.PipeName,
                    PipeDirection.InOut,
                    1,
                    PipeTransmissionMode.Byte,
                    PipeOptions.Asynchronous);

                WriteToCommandLine("Waiting for client connection...");

                await _pipeServer.WaitForConnectionAsync(cancellationToken);

                WriteToCommandLine("Client connected!");

                _pipeWriter = new StreamWriter(_pipeServer) { AutoFlush = true };
                _pipeReader = new StreamReader(_pipeServer);

                SendMessage(new BridgeMessage
                {
                    Type = MessageType.Connected,
                    Version = _settings.Version,
                    AutoCADVersion = Application.Version.ToString()
                });

                // Start reading messages from client
                _readerTask = ReadMessagesAsync(cancellationToken);

                // Keep connection alive
                while (_pipeServer.IsConnected && !cancellationToken.IsCancellationRequested)
                {
                    await Task.Delay(100, cancellationToken);
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (System.Exception ex)
            {
                if (!cancellationToken.IsCancellationRequested)
                {
                    WriteToCommandLine($"Pipe error: {ex.Message}");
                    await Task.Delay(2000, cancellationToken);
                }
            }
            finally
            {
                _pipeWriter?.Dispose();
                _pipeReader?.Dispose();
                _pipeServer?.Dispose();
                _pipeWriter = null;
                _pipeReader = null;
                _pipeServer = null;
            }
        }
    }

    private static async Task ReadMessagesAsync(CancellationToken cancellationToken)
    {
        try
        {
            while (!cancellationToken.IsCancellationRequested && _pipeReader != null)
            {
                var line = await _pipeReader.ReadLineAsync(cancellationToken);
                if (line == null) break;

                ProcessClientMessage(line);
            }
        }
        catch (OperationCanceledException) { }
        catch (System.Exception ex)
        {
            WriteToCommandLine($"Read error: {ex.Message}");
        }
    }

    private static void ProcessClientMessage(string jsonMessage)
    {
        try
        {
            var message = JsonConvert.DeserializeObject<BridgeMessage>(jsonMessage, _jsonSettings);
            if (message == null) return;

            switch (message.Type)
            {
                case MessageType.Execute:
                    if (!string.IsNullOrEmpty(message.Command))
                        ExecuteCommand(message.Command);
                    break;

                case MessageType.Lisp:
                    if (!string.IsNullOrEmpty(message.Message))
                        ExecuteLisp(message.Message);
                    break;

                case MessageType.GetVar:
                    if (!string.IsNullOrEmpty(message.Variable))
                        GetSystemVariable(message.Variable);
                    break;

                case MessageType.SetVar:
                    if (!string.IsNullOrEmpty(message.Variable) && message.Value != null)
                        SetSystemVariable(message.Variable, message.Value);
                    break;

                case MessageType.Ping:
                    SendMessage(new BridgeMessage { Type = MessageType.Pong });
                    break;
            }
        }
        catch (System.Exception ex)
        {
            SendMessage(new BridgeMessage
            {
                Type = MessageType.Error,
                Message = $"Failed to process command: {ex.Message}"
            });
        }
    }

    private static void HookAutoCADEvents()
    {
        _activeDoc = Application.DocumentManager.MdiActiveDocument;
        if (_activeDoc == null) return;

        _activeDoc.CommandWillStart += OnCommandWillStart;
        _activeDoc.CommandEnded += OnCommandEnded;
        _activeDoc.CommandCancelled += OnCommandCancelled;
        _activeDoc.CommandFailed += OnCommandFailed;

        _activeDoc.LispWillStart += OnLispWillStart;
        _activeDoc.LispEnded += OnLispEnded;
        _activeDoc.LispCancelled += OnLispCancelled;

        _activeDoc.Editor.PromptingForString += OnPromptingForString;
        _activeDoc.Editor.PromptingForPoint += OnPromptingForPoint;
        _activeDoc.Editor.PromptingForSelection += OnPromptingForSelection;
    }

    private static void UnhookAutoCADEvents()
    {
        if (_activeDoc == null) return;

        _activeDoc.CommandWillStart -= OnCommandWillStart;
        _activeDoc.CommandEnded -= OnCommandEnded;
        _activeDoc.CommandCancelled -= OnCommandCancelled;
        _activeDoc.CommandFailed -= OnCommandFailed;

        _activeDoc.LispWillStart -= OnLispWillStart;
        _activeDoc.LispEnded -= OnLispEnded;
        _activeDoc.LispCancelled -= OnLispCancelled;

        _activeDoc.Editor.PromptingForString -= OnPromptingForString;
        _activeDoc.Editor.PromptingForPoint -= OnPromptingForPoint;
        _activeDoc.Editor.PromptingForSelection -= OnPromptingForSelection;
    }

    // Event handlers
    private static void OnCommandWillStart(object sender, CommandEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.CommandStart,
            Command = e.GlobalCommandName
        });
    }

    private static void OnCommandEnded(object sender, CommandEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.CommandEnd,
            Command = e.GlobalCommandName
        });
    }

    private static void OnCommandCancelled(object sender, CommandEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.CommandCancelled,
            Command = e.GlobalCommandName
        });
    }

    private static void OnCommandFailed(object sender, CommandEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.CommandFailed,
            Command = e.GlobalCommandName,
            Error = "Command execution failed"
        });
    }

    private static void OnLispWillStart(object sender, LispWillStartEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.LispStart,
            FirstExpression = e.FirstLine
        });
    }

    private static void OnLispEnded(object sender, EventArgs e)
    {
        SendMessage(new BridgeMessage { Type = MessageType.LispEnd });
    }

    private static void OnLispCancelled(object sender, EventArgs e)
    {
        SendMessage(new BridgeMessage { Type = MessageType.LispCancelled });
    }

    private static void OnPromptingForString(object sender, PromptStringOptionsEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.PromptString,
            Message = e.Options.Message,
            DefaultValue = e.Options.DefaultValue
        });
    }

    private static void OnPromptingForPoint(object sender, PromptPointOptionsEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.PromptPoint,
            Message = e.Options.Message
        });
    }

    private static void OnPromptingForSelection(object sender, PromptSelectionOptionsEventArgs e)
    {
        SendMessage(new BridgeMessage
        {
            Type = MessageType.PromptSelection,
            Message = e.Options.MessageForAdding
        });
    }

    // Command execution helpers
    private static void ExecuteCommand(string command)
    {
        Application.DocumentManager.MdiActiveDocument?.SendStringToExecute(
            command + "\n", true, false, true);
    }

    private static void ExecuteLisp(string expression)
    {
        Application.DocumentManager.MdiActiveDocument?.SendStringToExecute(
            expression + "\n", false, false, false);
    }

    private static void GetSystemVariable(string varName)
    {
        try
        {
            var value = Application.GetSystemVariable(varName);
            SendMessage(new BridgeMessage
            {
                Type = MessageType.SysVar,
                Variable = varName,
                Value = value
            });
        }
        catch (System.Exception ex)
        {
            SendMessage(new BridgeMessage
            {
                Type = MessageType.Error,
                Message = $"Failed to get {varName}: {ex.Message}"
            });
        }
    }

    private static void SetSystemVariable(string varName, object value)
    {
        try
        {
            Application.SetSystemVariable(varName, value);
            SendMessage(new BridgeMessage
            {
                Type = MessageType.SysVarSet,
                Variable = varName,
                Value = value
            });
        }
        catch (System.Exception ex)
        {
            SendMessage(new BridgeMessage
            {
                Type = MessageType.Error,
                Message = $"Failed to set {varName}: {ex.Message}"
            });
        }
    }

    private static void SendMessage(BridgeMessage message)
    {
        if (_pipeWriter == null || _pipeServer?.IsConnected != true) return;

        try
        {
            var json = JsonConvert.SerializeObject(message, _jsonSettings);
            _pipeWriter.WriteLine(json);
        }
        catch (System.Exception ex)
        {
            WriteToCommandLine($"Failed to send message: {ex.Message}");
        }
    }

    private static void WriteToCommandLine(string message)
    {
        Application.DocumentManager.MdiActiveDocument?.Editor.WriteMessage($"\n{message}");
    }

    [CommandMethod("TESTBRIDGE")]
    public static void TestBridge()
    {
        if (!_isMonitoring)
        {
            WriteToCommandLine("Command Bridge is not running. Use STARTBRIDGE first.");
            return;
        }

        SendMessage(new BridgeMessage
        {
            Type = MessageType.Test,
            Message = "Test message from AutoCAD",
            Drawing = Application.DocumentManager.MdiActiveDocument?.Name
        });

        WriteToCommandLine("Test message sent to client.");
    }
}
