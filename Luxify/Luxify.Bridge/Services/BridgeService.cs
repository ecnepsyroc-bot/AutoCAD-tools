using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Luxify.Bridge.Services
{
    public class BridgeService
    {
        private const string BridgeFile = @"C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_bridge.txt";
        private const string CommandFile = @"C:\Users\cory\OneDrive\_Feature_Millwork\Command Bridge\Logs\autocad_commands.txt";
        
        private long _lastPosition = 0;
        private System.Threading.Timer _monitorTimer;
        
        public event EventHandler<string> MessageReceived;

        public BridgeService()
        {
            // Start monitoring
            _monitorTimer = new System.Threading.Timer(CheckForMessages, null, 0, 200);
        }

        public void SendCommand(string command)
        {
            try
            {
                string dir = Path.GetDirectoryName(CommandFile);
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

                // Append command to file
                File.AppendAllLines(CommandFile, new[] { command });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending command: {ex.Message}");
            }
        }

        private void CheckForMessages(object state)
        {
            try
            {
                if (!File.Exists(BridgeFile)) return;

                using (FileStream fs = new FileStream(BridgeFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    if (fs.Length > _lastPosition)
                    {
                        fs.Seek(_lastPosition, SeekOrigin.Begin);
                        using (StreamReader sr = new StreamReader(fs))
                        {
                            string line;
                            while ((line = sr.ReadLine()) != null)
                            {
                                MessageReceived?.Invoke(this, line);
                            }
                            _lastPosition = fs.Position;
                        }
                    }
                    else if (fs.Length < _lastPosition)
                    {
                        // File was reset
                        _lastPosition = 0;
                    }
                }
            }
            catch
            {
                // Ignore read errors (file might be locked)
            }
        }
    }
}
