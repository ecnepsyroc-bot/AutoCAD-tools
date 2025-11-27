using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Internal;
using SysException = System.Exception;

namespace FeatureMillwork.CommandBridge
{
    /// <summary>
    /// Command Bridge Plugin - Captures ALL command line text via command echo mechanism
    /// Simple purpose: Save copy/paste for AutoCAD tool versioning
    /// </summary>
    public class CommandBridgePlugin : IExtensionApplication
    {
        private static string BridgeFile = @"C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt";
        private static bool IsActive = true;
        private static Editor _editor;
        private static List<string> _lastCapturedLines = new List<string>();
        private static System.Threading.Timer _captureTimer;
        private static object _lockObject = new object();
        private const int CAPTURE_LINE_COUNT = 500; // Capture last 500 lines

        public void Initialize()
        {
            try
            {
                _editor = Application.DocumentManager.MdiActiveDocument?.Editor;
                
                // Subscribe to document events
                Application.DocumentManager.DocumentCreated += OnDocumentCreated;
                Application.DocumentManager.DocumentActivated += OnDocumentActivated;

                // Start timer to capture command line text using command echo mechanism
                // Uses AutoCAD's internal API to read command line history
                _captureTimer = new System.Threading.Timer(CaptureCommandLineEcho, null, 0, 200); // Check every 200ms

                WriteToBridge("=== COMMAND BRIDGE PLUGIN LOADED ===");
            }
            catch (SysException ex)
            {
                System.Diagnostics.Debug.WriteLine($"Command Bridge Error: {ex.Message}");
            }
        }

        public void Terminate()
        {
            try
            {
                IsActive = false;
                _captureTimer?.Dispose();
                WriteToBridge("=== COMMAND BRIDGE PLUGIN UNLOADED ===");
            }
            catch { }
        }

        private void OnDocumentCreated(object sender, DocumentCollectionEventArgs e)
        {
            // Document created - no special actions needed
        }

        private void OnDocumentActivated(object sender, DocumentCollectionEventArgs e)
        {
            _editor = e.Document?.Editor;
        }

        /// <summary>
        /// Capture command line text using AutoCAD's command echo mechanism
        /// Uses GetLastCommandLines to read command line history
        /// This is the core function - captures ALL command line output
        /// </summary>
        private void CaptureCommandLineEcho(object state)
        {
            if (!IsActive) return;

            lock (_lockObject)
            {
                try
                {
                    // Use AutoCAD's internal API to get command line history
                    // This captures ALL text that appears in the command line
                    List<string> currentLines = Utils.GetLastCommandLines(CAPTURE_LINE_COUNT, true);
                    
                    if (currentLines == null || currentLines.Count == 0)
                    {
                        return;
                    }

                    // Find new lines by comparing with last capture
                    List<string> newLines = GetNewLines(_lastCapturedLines, currentLines);
                    
                    // Write new lines to bridge file
                    foreach (string line in newLines)
                    {
                        if (!string.IsNullOrWhiteSpace(line))
                        {
                            WriteToBridge(line.Trim());
                        }
                    }
                    
                    // Update last captured lines
                    _lastCapturedLines = new List<string>(currentLines);
                }
                catch (SysException ex)
                {
                    // Silently handle errors to avoid spam
                    System.Diagnostics.Debug.WriteLine($"Capture Error: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Extract new lines by comparing current capture with previous
        /// </summary>
        private List<string> GetNewLines(List<string> oldLines, List<string> currentLines)
        {
            List<string> newLines = new List<string>();
            
            if (oldLines == null || oldLines.Count == 0)
            {
                // First capture - return all lines
                return currentLines;
            }

            // Find where old lines end in current lines
            int startIndex = 0;
            
            // Try to find the last old line in current lines
            for (int i = currentLines.Count - 1; i >= 0; i--)
            {
                if (oldLines.Count > 0 && currentLines[i] == oldLines[oldLines.Count - 1])
                {
                    // Found match - new lines start after this
                    startIndex = i + 1;
                    break;
                }
            }
            
            // If no match found, check if current has more lines
            if (startIndex == 0 && currentLines.Count > oldLines.Count)
            {
                // Current has more lines - get the difference
                startIndex = oldLines.Count;
            }
            
            // Extract new lines
            for (int i = startIndex; i < currentLines.Count; i++)
            {
                newLines.Add(currentLines[i]);
            }
            
            return newLines;
        }

        private static void WriteToBridge(string message)
        {
            try
            {
                string dir = Path.GetDirectoryName(BridgeFile);
                if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }

                using (StreamWriter writer = new StreamWriter(BridgeFile, true, Encoding.UTF8))
                {
                    writer.WriteLine(message);
                }
            }
            catch { }
        }

        [CommandMethod("BRIDGE-ON")]
        public void BridgeOn()
        {
            IsActive = true;
            if (_editor != null)
            {
                _editor.WriteMessage("\n✅ Command Bridge enabled\n");
            }
        }

        [CommandMethod("BRIDGE-OFF")]
        public void BridgeOff()
        {
            IsActive = false;
            if (_editor != null)
            {
                _editor.WriteMessage("\n✅ Command Bridge disabled\n");
            }
        }
    }
}
