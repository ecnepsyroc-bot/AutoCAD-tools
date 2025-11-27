#r "nuget: Newtonsoft.Json, 13.0.3"

using System;
using System.IO;
using System.IO.Pipes;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;

Console.WriteLine("=== AutoCAD Bridge Test Server ===");
Console.WriteLine("This simulates the AutoCAD plugin for testing the C# client.\n");

var pipeName = "AutoCADCommandBridge";
var cts = new CancellationTokenSource();

Console.CancelKeyPress += (s, e) => {
    e.Cancel = true;
    cts.Cancel();
    Console.WriteLine("\nShutting down...");
};

while (!cts.Token.IsCancellationRequested)
{
    try
    {
        using var server = new NamedPipeServerStream(pipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous);

        Console.WriteLine($"Waiting for client connection on pipe: {pipeName}...");
        await server.WaitForConnectionAsync(cts.Token);
        Console.WriteLine("Client connected!");

        using var writer = new StreamWriter(server) { AutoFlush = true };
        using var reader = new StreamReader(server);

        // Send connected message
        var connected = new {
            type = "connected",
            version = "2.0.0",
            autocad_version = "25.0.0.0 (AutoCAD 2026 - SIMULATED)",
            timestamp = DateTime.Now
        };
        writer.WriteLine(JsonConvert.SerializeObject(connected));
        Console.WriteLine("Sent: connected");

        // Simulate commands
        var commands = new[] { "LINE", "CIRCLE", "ZOOM", "PAN", "MOVE", "COPY", "ERASE" };
        var random = new Random();
        var commandIndex = 0;

        Console.WriteLine("\nPress keys to simulate events:");
        Console.WriteLine("  1-7: Simulate command (LINE, CIRCLE, ZOOM, PAN, MOVE, COPY, ERASE)");
        Console.WriteLine("  L: Simulate LISP execution");
        Console.WriteLine("  E: Simulate error");
        Console.WriteLine("  T: Send test message");
        Console.WriteLine("  Q: Quit\n");

        // Start reader task
        var readerTask = Task.Run(async () => {
            try {
                while (!cts.Token.IsCancellationRequested && server.IsConnected) {
                    var line = await reader.ReadLineAsync();
                    if (line != null) {
                        Console.WriteLine($"Received from client: {line}");
                    }
                }
            } catch { }
        });

        while (server.IsConnected && !cts.Token.IsCancellationRequested)
        {
            if (Console.KeyAvailable)
            {
                var key = Console.ReadKey(true);

                if (key.Key >= ConsoleKey.D1 && key.Key <= ConsoleKey.D7)
                {
                    var idx = key.Key - ConsoleKey.D1;
                    var cmd = commands[idx];

                    // Command start
                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "command_start",
                        command = cmd,
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine($"Sent: command_start ({cmd})");

                    await Task.Delay(random.Next(50, 500));

                    // Command end
                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "command_end",
                        command = cmd,
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine($"Sent: command_end ({cmd})");
                }
                else if (key.Key == ConsoleKey.L)
                {
                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "lisp_start",
                        first_expression = "(defun c:test () (princ \"Hello\"))",
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine("Sent: lisp_start");

                    await Task.Delay(100);

                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "lisp_end",
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine("Sent: lisp_end");
                }
                else if (key.Key == ConsoleKey.E)
                {
                    var errors = new[] {
                        "bad argument type: numberp nil",
                        "too few arguments",
                        "null function",
                        "syntax error"
                    };
                    var error = errors[random.Next(errors.Length)];

                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "error",
                        message = error,
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine($"Sent: error ({error})");
                }
                else if (key.Key == ConsoleKey.T)
                {
                    writer.WriteLine(JsonConvert.SerializeObject(new {
                        type = "test",
                        message = "Test message from simulated AutoCAD",
                        drawing = "TestDrawing.dwg",
                        timestamp = DateTime.Now
                    }));
                    Console.WriteLine("Sent: test");
                }
                else if (key.Key == ConsoleKey.Q)
                {
                    break;
                }
            }

            await Task.Delay(50);
        }
    }
    catch (OperationCanceledException)
    {
        break;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
        await Task.Delay(1000);
    }
}

Console.WriteLine("Server stopped.");
