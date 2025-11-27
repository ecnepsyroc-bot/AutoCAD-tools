# AUTOCAD COMMAND BRIDGE - QUICK START
## Working Version - November 7, 2024

### TO START MONITORING:

#### In AutoCAD:
```
NETLOAD
Browse to: G:\My Drive\_Feature\_Millwork_Projects\autocad-command-bridge\autocad-plugin\bin\Release\net8.0\FeatureMillwork.CommandBridge.dll
```
(You'll see "Command Bridge started successfully")

#### In PowerShell:
```
cd "G:\My Drive\_Feature\_Millwork_Projects\autocad-command-bridge\vscode-extension"
node -e "const net = require('net'); function connect() { const client = net.createConnection('\\\\.\\pipe\\AutoCADCommandBridge', () => { console.log('Connected to AutoCAD!'); }); client.on('data', (data) => { console.log(data.toString()); }); client.on('end', () => { console.log('Disconnected. Reconnecting...'); setTimeout(connect, 1000); }); client.on('error', (err) => { console.log('Error:', err.message); setTimeout(connect, 1000); }); } connect();"
```

#### Test It:
In AutoCAD: `TESTBRIDGE`

### WHAT IT DOES:
- Shows every AutoCAD command in real-time
- Tracks execution times with timestamps
- Displays LISP errors instantly
- Monitors badge system operations

### KEY FILES:
- DLL: `autocad-plugin\bin\Release\net8.0\FeatureMillwork.CommandBridge.dll`
- Monitor: `vscode-extension\extension.js`
- Tests: `test-bridge.lsp`

### BUILT WITH:
- AutoCAD 2026
- .NET 8.0
- Named Pipe: \\.\pipe\AutoCADCommandBridge

### IF CONNECTION FAILS:
1. In AutoCAD: Run `STARTBRIDGE`
2. If command unknown: NETLOAD the DLL again

---
This tool is your 20x productivity multiplier for badge system development!