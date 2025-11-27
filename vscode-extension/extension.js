const vscode = require('vscode');
const net = require('net');
const MonitorPanel = require('./monitor-panel');

let outputChannel;
let pipeClient;
let isConnected = false;
let diagnosticCollection;
let statusBarItem;
let monitorPanel;

function activate(context) {
    console.log('AutoCAD Command Bridge is now active');
    
    // Create output channel
    outputChannel = vscode.window.createOutputChannel('AutoCAD Commands');
    
    // Create monitor panel
    monitorPanel = new MonitorPanel(context, outputChannel);
    
    // Create diagnostics collection for errors
    diagnosticCollection = vscode.languages.createDiagnosticCollection('autocad');
    
    // Create status bar item
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBarItem.text = "$(plug) AutoCAD: Disconnected";
    statusBarItem.show();
    
    // Register commands
    context.subscriptions.push(
        vscode.commands.registerCommand('autocadBridge.start', connectToAutoCAD),
        vscode.commands.registerCommand('autocadBridge.stop', disconnect),
        vscode.commands.registerCommand('autocadBridge.sendCommand', sendCommand),
        vscode.commands.registerCommand('autocadBridge.executeLisp', executeLisp),
        vscode.commands.registerCommand('autocadBridge.clearLog', clearLog),
        vscode.commands.registerCommand('autocadBridge.showMonitor', () => {
            monitorPanel.show();
        })
    );
    
    // Auto-connect if enabled
    const config = vscode.workspace.getConfiguration('autocadBridge');
    if (config.get('autoConnect')) {
        setTimeout(connectToAutoCAD, 2000);
    }
}
function connectToAutoCAD() {
    if (isConnected) {
        vscode.window.showInformationMessage('Already connected to AutoCAD');
        return;
    }
    
    outputChannel.appendLine('Connecting to AutoCAD...');
    statusBarItem.text = "$(sync~spin) AutoCAD: Connecting...";
    
    pipeClient = net.createConnection('\\\\.\\pipe\\AutoCADCommandBridge', () => {
        isConnected = true;
        outputChannel.appendLine('Connected to AutoCAD!');
        vscode.window.showInformationMessage('Connected to AutoCAD Command Bridge');
        statusBarItem.text = "$(check) AutoCAD: Connected";
        statusBarItem.color = '#00ff00';
        
        // Auto-show monitor if configured
        const config = vscode.workspace.getConfiguration('autocadBridge');
        if (config.get('autoShowMonitor')) {
            monitorPanel.show();
        }
    });
    
    pipeClient.on('data', (data) => {
        try {
            const messages = data.toString().split('\n').filter(line => line.trim());
            messages.forEach(msg => {
                if (msg.trim()) {
                    const json = JSON.parse(msg);
                    handleAutoCADMessage(json);
                }
            });
        } catch (error) {
            outputChannel.appendLine(`Parse error: ${error.message}`);
        }
    });
    pipeClient.on('error', (error) => {
        outputChannel.appendLine(`Connection error: ${error.message}`);
        if (error.code === 'ENOENT') {
            vscode.window.showErrorMessage('AutoCAD Bridge not running. Run STARTBRIDGE in AutoCAD first.');
        }
        statusBarItem.text = "$(x) AutoCAD: Error";
        statusBarItem.color = '#ff0000';
    });
    
    pipeClient.on('close', () => {
        isConnected = false;
        outputChannel.appendLine('Disconnected from AutoCAD');
        statusBarItem.text = "$(plug) AutoCAD: Disconnected";
        statusBarItem.color = undefined;
    });
}

function handleAutoCADMessage(message) {
    const config = vscode.workspace.getConfiguration('autocadBridge');
    const showTimestamps = config.get('showTimestamps');
    
    // Track in monitor panel
    switch (message.type) {
        case 'command_start':
        case 'lisp_start':
            monitorPanel.trackCommand(message);
            break;
        case 'command_end':
        case 'lisp_end':
            monitorPanel.completeCommand(message, true);
            break;
        case 'command_failed':
        case 'lisp_cancelled':
            monitorPanel.completeCommand(message, false);
            monitorPanel.trackError(message.error || 'Command failed');
            break;
        case 'error':
            monitorPanel.trackError(message.message);
            break;
    }
    let output = '';
    if (showTimestamps && message.timestamp) {
        const time = new Date(message.timestamp).toLocaleTimeString();
        output = `[${time}] `;
    }
    
    switch (message.type) {
        case 'connected':
            output += `✅ Connected to AutoCAD ${message.autocadVersion}`;
            break;
            
        case 'command_start':
            output += `▶️  Command: ${message.command}`;
            break;
            
        case 'command_end':
            output += `✓ Command completed: ${message.command}`;
            break;
            
        case 'command_failed':
            output += `❌ Command failed: ${message.command} - ${message.error}`;
            highlightError(message.error);
            break;
            
        case 'lisp_start':
            output += `🔵 LISP: ${message.firstExpression}`;
            break;
            
        case 'lisp_end':
            output += `✓ LISP completed`;
            break;            
        case 'lisp_cancelled':
            output += `⚠️  LISP cancelled`;
            break;
            
        case 'prompt_string':
        case 'prompt_point':
        case 'prompt_selection':
            output += `💬 ${message.message || 'Prompting...'}`;
            break;
            
        case 'error':
            output += `❌ Error: ${message.message}`;
            highlightError(message.message);
            break;
            
        case 'test':
            output += `🧪 Test: ${message.message} (Drawing: ${message.drawing})`;
            break;
            
        case 'sysvar':
            output += `📋 ${message.variable} = ${message.value}`;
            break;
            
        default:
            output += JSON.stringify(message);
    }
    
    outputChannel.appendLine(output);
    
    // Auto-show output on errors
    if (message.type === 'error' || message.type === 'command_failed') {
        outputChannel.show(true);
    }
}
function highlightError(errorMessage) {
    const config = vscode.workspace.getConfiguration('autocadBridge');
    if (!config.get('highlightErrors')) return;
    
    const activeEditor = vscode.window.activeTextEditor;
    if (!activeEditor || !activeEditor.document.fileName.endsWith('.lsp')) return;
    
    const diagnostics = [];
    
    // Common AutoCAD/LISP error patterns
    const patterns = [
        /error: (.+) at line (\d+)/i,
        /; error: (.+)/i,
        /bad argument type: (.+)/i,
        /too few arguments/i,
        /too many arguments/i,
        /null function/i
    ];
    
    patterns.forEach(pattern => {
        const match = errorMessage.match(pattern);
        if (match) {
            const line = match[2] ? parseInt(match[2]) - 1 : 0;
            const diagnostic = new vscode.Diagnostic(
                new vscode.Range(line, 0, line, 999),
                errorMessage,
                vscode.DiagnosticSeverity.Error
            );
            diagnostics.push(diagnostic);
        }
    });
    
    if (diagnostics.length > 0) {
        diagnosticCollection.set(activeEditor.document.uri, diagnostics);
    }
}
function sendCommand() {
    if (!isConnected) {
        vscode.window.showErrorMessage('Not connected to AutoCAD. Run "AutoCAD Bridge: Connect" first.');
        return;
    }
    
    vscode.window.showInputBox({
        prompt: 'Enter AutoCAD command',
        placeHolder: 'LINE, CIRCLE, ZOOM E, etc.'
    }).then(command => {
        if (command) {
            const message = JSON.stringify({
                type: 'execute',
                command: command
            });
            pipeClient.write(message + '\n');
            outputChannel.appendLine(`➡️  Sent: ${command}`);
        }
    });
}

function executeLisp() {
    if (!isConnected) {
        vscode.window.showErrorMessage('Not connected to AutoCAD. Run "AutoCAD Bridge: Connect" first.');
        return;
    }
    
    const activeEditor = vscode.window.activeTextEditor;
    if (!activeEditor) {
        vscode.window.showErrorMessage('No active editor');
        return;
    }    
    let code;
    const selection = activeEditor.selection;
    
    if (selection && !selection.isEmpty) {
        // Execute selected text
        code = activeEditor.document.getText(selection);
    } else {
        // Execute entire file
        code = activeEditor.document.getText();
    }
    
    if (code) {
        const message = JSON.stringify({
            type: 'lisp',
            expression: code
        });
        pipeClient.write(message + '\n');
        outputChannel.appendLine(`➡️  Executing LISP code (${code.length} characters)`);
    }
}

function disconnect() {
    if (pipeClient) {
        pipeClient.end();
        isConnected = false;
        outputChannel.appendLine('Disconnected from AutoCAD');
    }
}

function clearLog() {
    outputChannel.clear();
    diagnosticCollection.clear();
}

function deactivate() {
    if (pipeClient) {
        pipeClient.end();
    }
    if (statusBarItem) {
        statusBarItem.dispose();
    }
}

module.exports = {
    activate,
    deactivate
}