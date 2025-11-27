using System.IO.Pipes;
using FeatureMillwork.CommandBridge.Shared;
using FeatureMillwork.CommandBridge.Shared.Messages;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

Console.WriteLine("╔════════════════════════════════════════════╗");
Console.WriteLine("║   AutoCAD Command Bridge - Test Server     ║");
Console.WriteLine("║   Simulates AutoCAD for testing C# client  ║");
Console.WriteLine("╚════════════════════════════════════════════╝");
Console.WriteLine();

var settings = new BridgeSettings();
var jsonSettings = new JsonSerializerSettings
{
    ContractResolver = new DefaultContractResolver
    {
        NamingStrategy = new SnakeCaseNamingStrategy()
    },
    NullValueHandling = NullValueHandling.Ignore
};

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

await RunServerAsync(cts.Token);

async Task RunServerAsync(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        try
        {
            using var server = new NamedPipeServerStream(
                settings.PipeName,
                PipeDirection.InOut,
                1,
                PipeTransmissionMode.Byte,
                PipeOptions.Asynchronous);

            Console.WriteLine($"Waiting for client on pipe: {settings.PipeName}...");
            await server.WaitForConnectionAsync(ct);
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Client connected!");
            Console.ResetColor();

            using var writer = new StreamWriter(server) { AutoFlush = true };
            using var reader = new StreamReader(server);

            // Send connected message
            SendMessage(writer, new BridgeMessage
            {
                Type = MessageType.Connected,
                Version = settings.Version,
                AutoCADVersion = "25.0.0.0 (AutoCAD 2026 - SIMULATED)"
            });

            Console.WriteLine();
            Console.WriteLine("Commands:");
            Console.WriteLine("  1-7  : Simulate command (LINE, CIRCLE, ZOOM, PAN, MOVE, COPY, ERASE)");
            Console.WriteLine("  L    : Simulate LISP execution");
            Console.WriteLine("  E    : Simulate error");
            Console.WriteLine("  F    : Simulate command failure");
            Console.WriteLine("  T    : Send test message");
            Console.WriteLine("  A    : Auto-run (continuous simulation)");
            Console.WriteLine("  Q    : Quit");
            Console.WriteLine();

            // Start reader task
            _ = Task.Run(async () =>
            {
                try
                {
                    while (!ct.IsCancellationRequested && server.IsConnected)
                    {
                        var line = await reader.ReadLineAsync(ct);
                        if (line != null)
                        {
                            Console.ForegroundColor = ConsoleColor.Cyan;
                            Console.WriteLine($"← Received: {line}");
                            Console.ResetColor();
                        }
                    }
                }
                catch { }
            }, ct);

            var commands = new[] { "LINE", "CIRCLE", "ZOOM", "PAN", "MOVE", "COPY", "ERASE" };
            var errors = new[] { "bad argument type: numberp nil", "too few arguments", "null function", "syntax error" };
            var random = new Random();
            var autoRun = false;

            while (server.IsConnected && !ct.IsCancellationRequested)
            {
                if (autoRun)
                {
                    var cmd = commands[random.Next(commands.Length)];
                    await SimulateCommandAsync(writer, cmd, random);

                    if (random.NextDouble() < 0.1) // 10% chance of error
                    {
                        SendError(writer, errors[random.Next(errors.Length)]);
                    }

                    await Task.Delay(random.Next(500, 2000), ct);
                }

                if (Console.KeyAvailable)
                {
                    var key = Console.ReadKey(true);

                    if (key.Key >= ConsoleKey.D1 && key.Key <= ConsoleKey.D7)
                    {
                        var idx = key.Key - ConsoleKey.D1;
                        await SimulateCommandAsync(writer, commands[idx], random);
                    }
                    else if (key.Key == ConsoleKey.L)
                    {
                        await SimulateLispAsync(writer, random);
                    }
                    else if (key.Key == ConsoleKey.E)
                    {
                        SendError(writer, errors[random.Next(errors.Length)]);
                    }
                    else if (key.Key == ConsoleKey.F)
                    {
                        await SimulateFailedCommandAsync(writer, commands[random.Next(commands.Length)], random);
                    }
                    else if (key.Key == ConsoleKey.T)
                    {
                        SendMessage(writer, new BridgeMessage
                        {
                            Type = MessageType.Test,
                            Message = "Test message from simulated AutoCAD",
                            Drawing = "TestDrawing.dwg"
                        });
                    }
                    else if (key.Key == ConsoleKey.A)
                    {
                        autoRun = !autoRun;
                        Console.WriteLine(autoRun ? "Auto-run ENABLED" : "Auto-run DISABLED");
                    }
                    else if (key.Key == ConsoleKey.Q)
                    {
                        break;
                    }
                }

                await Task.Delay(50, ct);
            }

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Client disconnected.");
            Console.ResetColor();
        }
        catch (OperationCanceledException)
        {
            break;
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Error: {ex.Message}");
            Console.ResetColor();
            await Task.Delay(1000, ct);
        }
    }

    Console.WriteLine("Server stopped.");
}

async Task SimulateCommandAsync(StreamWriter writer, string command, Random random)
{
    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.CommandStart,
        Command = command
    });

    await Task.Delay(random.Next(50, 300));

    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.CommandEnd,
        Command = command
    });
}

async Task SimulateFailedCommandAsync(StreamWriter writer, string command, Random random)
{
    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.CommandStart,
        Command = command
    });

    await Task.Delay(random.Next(50, 200));

    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.CommandFailed,
        Command = command,
        Error = "Command execution failed"
    });
}

async Task SimulateLispAsync(StreamWriter writer, Random random)
{
    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.LispStart,
        FirstExpression = "(defun c:test () (princ \"Hello\"))"
    });

    await Task.Delay(random.Next(50, 200));

    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.LispEnd
    });
}

void SendError(StreamWriter writer, string error)
{
    SendMessage(writer, new BridgeMessage
    {
        Type = MessageType.Error,
        Message = error
    });
}

void SendMessage(StreamWriter writer, BridgeMessage message)
{
    var json = JsonConvert.SerializeObject(message, jsonSettings);
    writer.WriteLine(json);

    var color = message.Type switch
    {
        MessageType.Error or MessageType.CommandFailed => ConsoleColor.Red,
        MessageType.CommandStart or MessageType.LispStart => ConsoleColor.White,
        MessageType.CommandEnd or MessageType.LispEnd => ConsoleColor.Green,
        MessageType.Connected => ConsoleColor.Cyan,
        _ => ConsoleColor.Gray
    };

    Console.ForegroundColor = color;
    Console.WriteLine($"→ Sent: {message.Type} {message.Command}{message.Message}");
    Console.ResetColor();
}
