using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
using Newtonsoft.Json;

namespace FeatureMillwork.CommandBridge
{
    public class CommandMonitor : IExtensionApplication
    {
        private static NamedPipeServerStream pipeServer;
        private static StreamWriter pipeWriter;
        private static bool isMonitoring = false;
        private static Thread monitorThread;
        private static Document activeDoc;

        // Initialize on AutoCAD startup
        public void Initialize()
        {
            // Auto-start monitoring if configured
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
            StopMonitoring();
        }

        [CommandMethod("STARTBRIDGE")]
        public static void StartMonitoring()
        {
            if (isMonitoring)
            {
                WriteToCommandLine("Command Bridge is already running.");
                return;
            }

            try
            {
                // Start named pipe server in background thread
                monitorThread = new Thread(RunPipeServer)
                {
                    IsBackground = true
                };
                monitorThread.Start();

                isMonitoring = true;
                WriteToCommandLine("Command Bridge started successfully.");
                
                // Hook into AutoCAD events
                HookAutoCADEvents();
            }
            catch (System.Exception ex)
            {
                WriteToCommandLine($"Failed to start Command Bridge: {ex.Message}");
            }
        }
        [CommandMethod("STOPBRIDGE")]
        public static void StopMonitoring()
        {
            if (!isMonitoring)
            {
                WriteToCommandLine("Command Bridge is not running.");
                return;
            }

            try
            {
                UnhookAutoCADEvents();
                
                if (pipeWriter != null)
                {
                    SendMessage(new { type = "shutdown", timestamp = DateTime.Now });
                    pipeWriter.Dispose();
                }
                
                if (pipeServer != null)
                {
                    pipeServer.Dispose();
                }

                isMonitoring = false;
                WriteToCommandLine("Command Bridge stopped.");
            }
            catch (System.Exception ex)
            {
                WriteToCommandLine($"Error stopping Command Bridge: {ex.Message}");
            }
        }

        private static void RunPipeServer()
        {
            while (isMonitoring)
            {
                try
                {
                    pipeServer = new NamedPipeServerStream("AutoCADCommandBridge", 
                        PipeDirection.Out, 1, PipeTransmissionMode.Byte);
                    
                    WriteToCommandLine("Waiting for VS Code connection...");
                    pipeServer.WaitForConnection();
                    WriteToCommandLine("VS Code connected!");

                    pipeWriter = new StreamWriter(pipeServer) { AutoFlush = true };
                    
                    // Send initial handshake
                    SendMessage(new 
                    { 
                        type = "connected", 
                        version = "1.0.0",
                        autocadVersion = Application.Version.ToString(),
                        timestamp = DateTime.Now 
                    });

                    // Just keep connection alive - events will send messages
                    while (pipeServer.IsConnected && isMonitoring)
                    {
                        Thread.Sleep(100);
                    }
                }
                catch (System.Exception ex)
                {
                    if (isMonitoring)
                    {
                        WriteToCommandLine($"Pipe error: {ex.Message}");
                        Thread.Sleep(2000); // Wait before retry
                    }
                }
                finally
                {
                    pipeWriter?.Dispose();
                    pipeWriter = null;
                    pipeServer?.Dispose();
                    pipeServer = null;
                }
            }
        }
        private static void HookAutoCADEvents()
        {
            activeDoc = Application.DocumentManager.MdiActiveDocument;
            if (activeDoc == null) return;

            // Hook command events
            activeDoc.CommandWillStart += OnCommandWillStart;
            activeDoc.CommandEnded += OnCommandEnded;
            activeDoc.CommandCancelled += OnCommandCancelled;
            activeDoc.CommandFailed += OnCommandFailed;
            
            // Hook LISP events
            activeDoc.LispWillStart += OnLispWillStart;
            activeDoc.LispEnded += OnLispEnded;
            activeDoc.LispCancelled += OnLispCancelled;
            
            // Hook editor events for prompts/errors
            activeDoc.Editor.PromptingForString += OnPromptingForString;
            activeDoc.Editor.PromptingForPoint += OnPromptingForPoint;
            activeDoc.Editor.PromptingForSelection += OnPromptingForSelection;
        }

        private static void UnhookAutoCADEvents()
        {
            if (activeDoc == null) return;

            activeDoc.CommandWillStart -= OnCommandWillStart;
            activeDoc.CommandEnded -= OnCommandEnded;
            activeDoc.CommandCancelled -= OnCommandCancelled;
            activeDoc.CommandFailed -= OnCommandFailed;
            
            activeDoc.LispWillStart -= OnLispWillStart;
            activeDoc.LispEnded -= OnLispEnded;
            activeDoc.LispCancelled -= OnLispCancelled;
            
            activeDoc.Editor.PromptingForString -= OnPromptingForString;
            activeDoc.Editor.PromptingForPoint -= OnPromptingForPoint;
            activeDoc.Editor.PromptingForSelection -= OnPromptingForSelection;
        }
        // Event handlers
        private static void OnCommandWillStart(object sender, CommandEventArgs e)
        {
            SendMessage(new 
            { 
                type = "command_start",
                command = e.GlobalCommandName,
                timestamp = DateTime.Now
            });
        }

        private static void OnCommandEnded(object sender, CommandEventArgs e)
        {
            SendMessage(new 
            { 
                type = "command_end",
                command = e.GlobalCommandName,
                timestamp = DateTime.Now
            });
        }

        private static void OnCommandCancelled(object sender, CommandEventArgs e)
        {
            SendMessage(new 
            { 
                type = "command_cancelled",
                command = e.GlobalCommandName,
                timestamp = DateTime.Now
            });
        }

        private static void OnCommandFailed(object sender, CommandEventArgs e)
        {
            SendMessage(new 
            { 
                type = "command_failed",
                command = e.GlobalCommandName,
                error = "Command execution failed",
                timestamp = DateTime.Now
            });
        }
        private static void OnLispWillStart(object sender, LispWillStartEventArgs e)
        {
            SendMessage(new 
            { 
                type = "lisp_start",
                timestamp = DateTime.Now
            });
        }

        private static void OnLispEnded(object sender, EventArgs e)
        {
            SendMessage(new 
            { 
                type = "lisp_end",
                timestamp = DateTime.Now
            });
        }

        private static void OnLispCancelled(object sender, EventArgs e)
        {
            SendMessage(new 
            { 
                type = "lisp_cancelled",
                timestamp = DateTime.Now
            });
        }

        private static void OnPromptingForString(object sender, PromptStringOptionsEventArgs e)
        {
            SendMessage(new 
            { 
                type = "prompt_string",
                message = e.Options.Message,
                defaultValue = e.Options.DefaultValue,
                timestamp = DateTime.Now
            });
        }
        private static void OnPromptingForPoint(object sender, PromptPointOptionsEventArgs e)
        {
            SendMessage(new 
            { 
                type = "prompt_point",
                message = e.Options.Message,
                timestamp = DateTime.Now
            });
        }

        private static void OnPromptingForSelection(object sender, PromptSelectionOptionsEventArgs e)
        {
            SendMessage(new 
            { 
                type = "prompt_selection",
                message = e.Options.MessageForAdding,
                timestamp = DateTime.Now
            });
        }

        // Process commands received from VS Code
        private static void ProcessVSCodeCommand(string jsonMessage)
        {
            try
            {
                dynamic cmd = JsonConvert.DeserializeObject(jsonMessage);
                string cmdType = cmd.type;
                
                switch (cmdType)
                {
                    case "execute":
                        ExecuteCommand(cmd.command.ToString());
                        break;
                    case "lisp":
                        ExecuteLisp(cmd.expression.ToString());
                        break;
                    case "getvar":
                        GetSystemVariable(cmd.variable.ToString());
                        break;
                    case "setvar":
                        SetSystemVariable(cmd.variable.ToString(), cmd.value.ToString());
                        break;
                    case "ping":
                        SendMessage(new { type = "pong", timestamp = DateTime.Now });
                        break;
                }
            }
            catch (System.Exception ex)
            {
                SendMessage(new 
                { 
                    type = "error",
                    message = $"Failed to process command: {ex.Message}",
                    timestamp = DateTime.Now
                });
            }
        }
        // Command execution helpers
        private static void ExecuteCommand(string command)
        {
            Application.DocumentManager.MdiActiveDocument.SendStringToExecute(
                command + "\n", true, false, true);
        }

        private static void ExecuteLisp(string expression)
        {
            Application.DocumentManager.MdiActiveDocument.SendStringToExecute(
                expression + "\n", false, false, false);
        }

        private static void GetSystemVariable(string varName)
        {
            try
            {
                var value = Application.GetSystemVariable(varName);
                SendMessage(new 
                { 
                    type = "sysvar",
                    variable = varName,
                    value = value,
                    timestamp = DateTime.Now
                });
            }
            catch (System.Exception ex)
            {
                SendMessage(new 
                { 
                    type = "error",
                    message = $"Failed to get {varName}: {ex.Message}",
                    timestamp = DateTime.Now
                });
            }
        }

        private static void SetSystemVariable(string varName, object value)
        {
            try
            {
                Application.SetSystemVariable(varName, value);
                SendMessage(new 
                { 
                    type = "sysvar_set",
                    variable = varName,
                    value = value,
                    timestamp = DateTime.Now
                });
            }
            catch (System.Exception ex)
            {
                SendMessage(new 
                { 
                    type = "error",
                    message = $"Failed to set {varName}: {ex.Message}",
                    timestamp = DateTime.Now
                });
            }
        }
        // Utility methods
        private static void SendMessage(object messageObj)
        {
            if (pipeWriter != null && pipeServer != null && pipeServer.IsConnected)
            {
                try
                {
                    string json = JsonConvert.SerializeObject(messageObj);
                    pipeWriter.WriteLine(json);
                }
                catch (System.Exception ex)
                {
                    WriteToCommandLine($"Failed to send message: {ex.Message}");
                }
            }
        }

        private static void WriteToCommandLine(string message)
        {
            if (Application.DocumentManager.MdiActiveDocument != null)
            {
                Application.DocumentManager.MdiActiveDocument.Editor.WriteMessage($"\n{message}");
            }
        }

        [CommandMethod("TESTBRIDGE")]
        public static void TestBridge()
        {
            if (!isMonitoring)
            {
                WriteToCommandLine("Command Bridge is not running. Use STARTBRIDGE first.");
                return;
            }

            SendMessage(new 
            { 
                type = "test",
                message = "Test message from AutoCAD",
                drawing = Application.DocumentManager.MdiActiveDocument.Name,
                timestamp = DateTime.Now
            });
            
            WriteToCommandLine("Test message sent to VS Code.");
        }
    }
}