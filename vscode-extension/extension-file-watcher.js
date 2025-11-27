const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const os = require('os');

let outputChannel;
let fileWatcher;
let isMonitoring = false;
let diagnosticCollection;
let statusBarItem;
let logFilePath;
let lastFileSize = 0;

function activate(context) {
    console.log('AutoCAD Command Bridge is now active');
    
    // Create output channel
    outputChannel = vscode.window.createOutputChannel('AutoCAD Commands');
    
    // Create diagnostics collection for errors
    diagnosticCollection = vscode.languages.createDiagnosticCollection('autocad');
    
    // Create status bar item
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBarItem.text = "$(eye) AutoCAD: Not Monitoring";
    statusBarItem.show();
    
    // Register commands
    context.subscriptions.push(
        vscode.commands.registerCommand('autocadBridge.start', startMonitoring),
        vscode.commands.registerCommand('autocadBridge.stop', stopMonitoring),
        vscode.commands.registerCommand('autocadBridge.findLog', findLogFile),
        vscode.commands.registerCommand('autocadBridge.clearLog', clearLog),
        vscode.commands.registerCommand('autocadBridge.loadLisp', loadBridgeLisp)
    );
    
    // Auto-start if configured
    const config = vscode.workspace.getConfiguration('autocadBridge');
    if (config.get('autoConnect')) {
        setTimeout(findLogFile, 2000);
    }
}

function findLogFile() {
    // Look for the most recent log file in temp directory
    const tempDir = os.tmpdir();
    const files = fs.readdirSync(tempDir);
    const logFiles = files.filter(f => f.startsWith('autocad-bridge-') && f.endsWith('.log'));
    
    if (logFiles.length === 0) {
        vscode.window.showWarningMessage('No AutoCAD bridge log file found. Run STARTBRIDGE in AutoCAD first.');
        return;
    }
    
    // Get the most recent log file
    logFiles.sort((a, b) => {
        const statA = fs.statSync(path.join(tempDir, a));
        const statB = fs.statSync(path.join(tempDir, b));
        return statB.mtime - statA.mtime;
    });
    
    logFilePath = path.join(tempDir, logFiles[0]);
    outputChannel.appendLine(`Found log file: ${logFilePath}`);
    startMonitoring();
}
function startMonitoring() {
    if (isMonitoring) {
        vscode.window.showInformationMessage('Already monitoring AutoCAD');
        return;
    }
    
    if (!logFilePath) {
        findLogFile();
        return;
    }
    
    outputChannel.appendLine('Starting AutoCAD monitoring...');
    statusBarItem.text = "$(check) AutoCAD: Monitoring";
    statusBarItem.color = '#00ff00';
    isMonitoring = true;
    
    // Read existing content
    if (fs.existsSync(logFilePath)) {
        lastFileSize = fs.statSync(logFilePath).size;
    }
    
    // Watch for changes using polling (more reliable for network drives)
    fileWatcher = setInterval(() => {
        checkForUpdates();
    }, 500); // Check every 500ms
    
    vscode.window.showInformationMessage('Monitoring AutoCAD commands');
}

function checkForUpdates() {
    if (!fs.existsSync(logFilePath)) {
        return;
    }
    
    const stats = fs.statSync(logFilePath);
    if (stats.size > lastFileSize) {
        // Read new content
        const stream = fs.createReadStream(logFilePath, {
            start: lastFileSize,
            end: stats.size
        });
        
        let buffer = '';
        stream.on('data', (chunk) => {
            buffer += chunk.toString();
        });
        
        stream.on('end', () => {
            const lines = buffer.split('\n').filter(line => line.trim());
            lines.forEach(line => {
                try {
                    const json = JSON.parse(line);
                    handleAutoCADMessage(json);
                } catch (e) {
                    // Not JSON, just output as is
                    if (line.trim()) {
                        outputChannel.appendLine(line);
                    }
                }
            });
        });
        
        lastFileSize = stats.size;
    }
}
function handleAutoCADMessage(message) {
    const config = vscode.workspace.getConfiguration('autocadBridge');
    const showTimestamps = config.get('showTimestamps');
    
    let output = '';
    if (showTimestamps && message.timestamp) {
        output = `[${message.timestamp}] `;
    }
    
    // Add icon based on message type
    const icons = {
        'CONNECTED': '✅',
        'DISCONNECTED': '🔌',
        'CMD_START': '▶️',
        'CMD_END': '✓',
        'CMD_CANCEL': '⚠️',
        'CMD_FAILED': '❌',
        'LISP_START': '🔵',
        'LISP_END': '✓',
        'LISP_CANCEL': '⚠️',
        'ERROR': '❌',
        'TEST': '🧪',
        'SYSVAR': '📋',
        'EXEC': '⚡',
        'UNKNOWN_CMD': '❓'
    };
    
    const icon = icons[message.type] || '•';
    output += `${icon} ${message.type}: ${message.message}`;
    
    if (message.drawing) {
        output += ` [${message.drawing}]`;
    }
    
    outputChannel.appendLine(output);
    
    // Handle errors
    if (message.type === 'ERROR' || message.type === 'CMD_FAILED') {
        highlightError(message.message);
    }
}

function highlightError(errorMessage) {
    const config = vscode.workspace.getConfiguration('autocadBridge');
    if (!config.get('highlightErrors')) return;
    
    const activeEditor = vscode.window.activeTextEditor;
    if (!activeEditor || !activeEditor.document.fileName.endsWith('.lsp')) return;
    
    const diagnostics = [];
    
    // Parse error patterns
    const patterns = [
        /; error: (.+) at line (\d+)/i,
        /; error: (.+)/i,
        /bad argument type: (.+)/i,
        /too few arguments/i,
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
function stopMonitoring() {
    if (!isMonitoring) {
        vscode.window.showInformationMessage('Not currently monitoring');
        return;
    }
    
    if (fileWatcher) {
        clearInterval(fileWatcher);
        fileWatcher = null;
    }
    
    isMonitoring = false;
    statusBarItem.text = "$(eye) AutoCAD: Not Monitoring";
    statusBarItem.color = undefined;
    outputChannel.appendLine('Stopped monitoring AutoCAD');
}

function clearLog() {
    outputChannel.clear();
    diagnosticCollection.clear();
}

function loadBridgeLisp() {
    // Copy bridge.lsp to clipboard for easy loading
    const lispPath = path.join(__dirname, '..', 'bridge.lsp');
    if (fs.existsSync(lispPath)) {
        const loadCommand = `(load "${lispPath.replace(/\\/g, '/')}")`;
        vscode.env.clipboard.writeText(loadCommand);
        vscode.window.showInformationMessage(
            'Load command copied to clipboard. Paste in AutoCAD command line.',
            'Show Instructions'
        ).then(selection => {
            if (selection === 'Show Instructions') {
                outputChannel.clear();
                outputChannel.appendLine('=== AutoCAD Setup Instructions ===');
                outputChannel.appendLine('');
                outputChannel.appendLine('1. In AutoCAD command line, paste:');
                outputChannel.appendLine(`   ${loadCommand}`);
                outputChannel.appendLine('');
                outputChannel.appendLine('2. Run STARTBRIDGE to begin monitoring');
                outputChannel.appendLine('');
                outputChannel.appendLine('3. In VS Code, run "AutoCAD Bridge: Find Log"');
                outputChannel.appendLine('');
                outputChannel.appendLine('Available AutoCAD commands:');
                outputChannel.appendLine('  STARTBRIDGE    - Start monitoring');
                outputChannel.appendLine('  STOPBRIDGE     - Stop monitoring');
                outputChannel.appendLine('  TESTBRIDGE     - Test connection');
                outputChannel.appendLine('  BRIDGE-STATUS  - Show status');
                outputChannel.appendLine('  BRIDGE-CLEAR   - Clear log');
                outputChannel.show();
            }
        });
    } else {
        vscode.window.showErrorMessage('bridge.lsp not found');
    }
}

function deactivate() {
    stopMonitoring();
    if (statusBarItem) {
        statusBarItem.dispose();
    }
}

module.exports = {
    activate,
    deactivate
}