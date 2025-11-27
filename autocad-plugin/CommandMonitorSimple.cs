using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;

namespace FeatureMillwork.CommandBridge
{
    public class CommandMonitorSimple : IExtensionApplication
    {
        private static NamedPipeServerStream pipeServer;
        private static StreamWriter pipeWriter;
        private static bool isMonitoring = false;
        private static Thread monitorThread;

        public void Initialize()
        {
            try
            {
                StartMonitoring();
            }
            catch (System.Exception ex)  // Fixed: Use System.Exception explicitly
            {
                WriteToCommandLine($"CommandBridge init failed: {ex.Message}");
            }
        }

        public void Terminate()
        {
            StopMonitoring();
        }

        [CommandMethod("STARTBRIDGESIMPLE")]
        public static void StartMonitoring()
        {
            if (isMonitoring)
            {
                WriteToCommandLine("Command Bridge is already running.");
                return;
            }

            try
            {
                monitorThread = new Thread(RunPipeServer)
                {
                    IsBackground = true
                };
                monitorThread.Start();
                isMonitoring = true;
                WriteToCommandLine("Command Bridge started successfully.");
            }
            catch (System.Exception ex)  // Fixed: Use System.Exception explicitly
            {
                WriteToCommandLine($"Failed to start: {ex.Message}");
            }
        }

        [CommandMethod("STOPBRIDGESIMPLE")]
        public static void StopMonitoring()
        {
            if (!isMonitoring) return;
            
            isMonitoring = false;
            pipeWriter?.Dispose();
            pipeServer?.Dispose();
            WriteToCommandLine("Command Bridge stopped.");
        }

        private static void RunPipeServer()
        {
            while (isMonitoring)
            {
                try
                {
                    pipeServer = new NamedPipeServerStream("AutoCADCommandBridge", 
                        PipeDirection.InOut, 1, PipeTransmissionMode.Message);
                    
                    WriteToCommandLine("Waiting for VS Code connection...");
                    pipeServer.WaitForConnection();
                    WriteToCommandLine("VS Code connected!");

                    pipeWriter = new StreamWriter(pipeServer) { AutoFlush = true };
                    
                    // Send simple handshake
                    SendMessage("CONNECTED|AutoCAD 2026");
                    
                    // Hook events
                    var doc = Application.DocumentManager.MdiActiveDocument;
                    doc.CommandWillStart += OnCommandWillStart;
                    doc.CommandEnded += OnCommandEnded;

                    // Keep connection alive
                    while (pipeServer.IsConnected && isMonitoring)
                    {
                        Thread.Sleep(100);
                    }
                    
                    // Unhook
                    doc.CommandWillStart -= OnCommandWillStart;
                    doc.CommandEnded -= OnCommandEnded;
                }
                catch (System.Exception ex)  // Fixed: Use System.Exception explicitly
                {
                    if (isMonitoring)
                    {
                        WriteToCommandLine($"Pipe error: {ex.Message}");
                        Thread.Sleep(2000);
                    }
                }
            }
        }

        private static void OnCommandWillStart(object sender, CommandEventArgs e)
        {
            SendMessage($"CMD_START|{e.GlobalCommandName}|{DateTime.Now:HH:mm:ss}");
        }

        private static void OnCommandEnded(object sender, CommandEventArgs e)
        {
            SendMessage($"CMD_END|{e.GlobalCommandName}|{DateTime.Now:HH:mm:ss}");
        }

        private static void SendMessage(string message)
        {
            if (pipeWriter != null && pipeServer != null && pipeServer.IsConnected)
            {
                try
                {
                    pipeWriter.WriteLine(message);
                }
                catch { }
            }
        }

        private static void WriteToCommandLine(string message)
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            doc?.Editor.WriteMessage($"\n{message}");
        }

        [CommandMethod("TESTBRIDGESIMPLE")]
        public static void TestBridge()
        {
            if (!isMonitoring)
            {
                WriteToCommandLine("Bridge not running. Use STARTBRIDGESIMPLE first.");
                return;
            }
            SendMessage($"TEST|Hello from AutoCAD|{DateTime.Now:HH:mm:ss}");
            WriteToCommandLine("Test message sent to VS Code.");
        }
    }
}