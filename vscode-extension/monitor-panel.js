// Enhanced monitoring panel with real-time statistics and pattern detection
const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

class MonitorPanel {
    constructor(context, outputChannel) {
        this.context = context;
        this.outputChannel = outputChannel;
        this.panel = null;
        this.commandHistory = [];
        this.errorPatterns = new Map();
        this.performanceMetrics = {
            commandCount: 0,
            errorCount: 0,
            avgExecutionTime: 0,
            sessionStart: Date.now(),
            commandTimes: new Map()
        };
    }

    show() {
        if (this.panel) {
            this.panel.reveal();
            return;
        }

        this.panel = vscode.window.createWebviewPanel(
            'autocadMonitor',
            'AutoCAD Monitor',
            vscode.ViewColumn.Two,
            {
                enableScripts: true,
                retainContextWhenHidden: true
            }
        );

        this.panel.webview.html = this.getWebviewContent();

        this.panel.onDidDispose(() => {
            this.panel = null;
        });

        // Set up message passing
        this.panel.webview.onDidReceiveMessage(
            message => this.handleWebviewMessage(message),
            null,
            this.context.subscriptions
        );
    }

    trackCommand(command) {
        const timestamp = Date.now();
        const entry = {
            command: command.command || command.expression,
            type: command.type,
            timestamp: timestamp,
            duration: null,
            status: 'running'
        };

        this.commandHistory.push(entry);
        this.performanceMetrics.commandCount++;
        
        // Store start time for duration calculation
        this.performanceMetrics.commandTimes.set(
            command.command || command.expression, 
            timestamp
        );

        this.updatePanel();
        return entry;
    }
    completeCommand(command, success = true) {
        const startTime = this.performanceMetrics.commandTimes.get(
            command.command || command.expression
        );
        
        if (startTime) {
            const duration = Date.now() - startTime;
            const lastEntry = this.commandHistory[this.commandHistory.length - 1];
            
            if (lastEntry) {
                lastEntry.duration = duration;
                lastEntry.status = success ? 'completed' : 'failed';
            }

            // Update average execution time
            const currentAvg = this.performanceMetrics.avgExecutionTime;
            const count = this.performanceMetrics.commandCount;
            this.performanceMetrics.avgExecutionTime = 
                (currentAvg * (count - 1) + duration) / count;

            if (!success) {
                this.performanceMetrics.errorCount++;
            }

            this.performanceMetrics.commandTimes.delete(
                command.command || command.expression
            );
        }

        this.updatePanel();
    }

    trackError(error) {
        this.performanceMetrics.errorCount++;
        
        // Track error patterns
        const pattern = this.extractErrorPattern(error);
        if (pattern) {
            const count = this.errorPatterns.get(pattern) || 0;
            this.errorPatterns.set(pattern, count + 1);
        }

        this.updatePanel();
    }

    extractErrorPattern(error) {
        // Extract common error patterns
        const patterns = [
            /bad argument type/i,
            /too few arguments/i,
            /null function/i,
            /invalid selection/i,
            /object not found/i
        ];

        for (const pattern of patterns) {
            if (pattern.test(error)) {
                return pattern.source;
            }
        }
        return 'other';
    }
    updatePanel() {
        if (!this.panel) return;

        const stats = this.getStatistics();
        this.panel.webview.postMessage({
            type: 'update',
            data: stats
        });
    }

    getStatistics() {
        const sessionDuration = (Date.now() - this.performanceMetrics.sessionStart) / 1000;
        const commandsPerMinute = (this.performanceMetrics.commandCount / sessionDuration) * 60;
        
        return {
            commandCount: this.performanceMetrics.commandCount,
            errorCount: this.performanceMetrics.errorCount,
            errorRate: this.performanceMetrics.commandCount > 0 
                ? ((this.performanceMetrics.errorCount / this.performanceMetrics.commandCount) * 100).toFixed(1)
                : 0,
            avgExecutionTime: Math.round(this.performanceMetrics.avgExecutionTime),
            commandsPerMinute: commandsPerMinute.toFixed(1),
            sessionDuration: Math.round(sessionDuration),
            recentCommands: this.commandHistory.slice(-10),
            topErrors: Array.from(this.errorPatterns.entries())
                .sort((a, b) => b[1] - a[1])
                .slice(0, 5)
        };
    }

    handleWebviewMessage(message) {
        switch (message.command) {
            case 'export':
                this.exportHistory();
                break;
            case 'clear':
                this.clearHistory();
                break;
            case 'refresh':
                this.updatePanel();
                break;
        }
    }
    exportHistory() {
        const exportData = {
            session: {
                start: new Date(this.performanceMetrics.sessionStart).toISOString(),
                duration: Math.round((Date.now() - this.performanceMetrics.sessionStart) / 1000),
                commandCount: this.performanceMetrics.commandCount,
                errorCount: this.performanceMetrics.errorCount
            },
            commands: this.commandHistory,
            errorPatterns: Object.fromEntries(this.errorPatterns),
            metrics: this.performanceMetrics
        };

        const filePath = path.join(
            vscode.workspace.rootPath || process.cwd(),
            `autocad-session-${Date.now()}.json`
        );

        fs.writeFileSync(filePath, JSON.stringify(exportData, null, 2));
        vscode.window.showInformationMessage(`Session exported to ${filePath}`);
    }

    clearHistory() {
        this.commandHistory = [];
        this.errorPatterns.clear();
        this.performanceMetrics.commandCount = 0;
        this.performanceMetrics.errorCount = 0;
        this.performanceMetrics.avgExecutionTime = 0;
        this.performanceMetrics.commandTimes.clear();
        this.updatePanel();
    }
    getWebviewContent() {
        return `<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            padding: 20px;
            background: #1e1e1e;
            color: #cccccc;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        h1 {
            color: #4ec9b0;
            margin: 0;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #252526;
            padding: 15px;
            border-radius: 5px;
            border-left: 3px solid #4ec9b0;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #4ec9b0;
        }
        .stat-label {
            font-size: 12px;
            color: #858585;
            text-transform: uppercase;
            margin-top: 5px;
        }        .command-list {
            background: #252526;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .command-item {
            display: flex;
            justify-content: space-between;
            padding: 8px;
            border-bottom: 1px solid #3e3e42;
        }
        .command-item:last-child {
            border-bottom: none;
        }
        .command-name {
            color: #d4d4d4;
        }
        .command-time {
            color: #858585;
            font-size: 12px;
        }
        .error-item {
            color: #f48771;
        }
        .success-item {
            color: #89d185;
        }
        button {
            background: #0e639c;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
        }
        button:hover {
            background: #1177bb;
        }
    </style>
</head><body>
    <div class="header">
        <h1>🔧 AutoCAD Command Monitor</h1>
        <div>
            <button onclick="exportData()">📊 Export</button>
            <button onclick="clearData()">🗑️ Clear</button>
            <button onclick="refresh()">🔄 Refresh</button>
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-value" id="commandCount">0</div>
            <div class="stat-label">Commands</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="errorRate">0%</div>
            <div class="stat-label">Error Rate</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="avgTime">0ms</div>
            <div class="stat-label">Avg Time</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="cpm">0</div>
            <div class="stat-label">Cmds/Min</div>
        </div>
    </div>

    <h3>Recent Commands</h3>
    <div class="command-list" id="recentCommands">
        <div style="color: #858585;">No commands yet...</div>
    </div>
    <h3>Top Errors</h3>
    <div class="command-list" id="topErrors">
        <div style="color: #858585;">No errors detected</div>
    </div>

    <script>
        const vscode = acquireVsCodeApi();

        function exportData() {
            vscode.postMessage({ command: 'export' });
        }

        function clearData() {
            vscode.postMessage({ command: 'clear' });
        }

        function refresh() {
            vscode.postMessage({ command: 'refresh' });
        }

        window.addEventListener('message', event => {
            const message = event.data;
            if (message.type === 'update') {
                updateDisplay(message.data);
            }
        });

        function updateDisplay(data) {
            document.getElementById('commandCount').textContent = data.commandCount;
            document.getElementById('errorRate').textContent = data.errorRate + '%';
            document.getElementById('avgTime').textContent = data.avgExecutionTime + 'ms';
            document.getElementById('cpm').textContent = data.commandsPerMinute;
            // Update recent commands
            const commandsDiv = document.getElementById('recentCommands');
            if (data.recentCommands.length > 0) {
                commandsDiv.innerHTML = data.recentCommands.map(cmd => \`
                    <div class="command-item \${cmd.status === 'failed' ? 'error-item' : 'success-item'}">
                        <span class="command-name">\${cmd.command}</span>
                        <span class="command-time">\${cmd.duration ? cmd.duration + 'ms' : 'running'}</span>
                    </div>
                \`).join('');
            }

            // Update top errors
            const errorsDiv = document.getElementById('topErrors');
            if (data.topErrors.length > 0) {
                errorsDiv.innerHTML = data.topErrors.map(([pattern, count]) => \`
                    <div class="command-item error-item">
                        <span>\${pattern}</span>
                        <span>\${count} occurrences</span>
                    </div>
                \`).join('');
            }
        }
    </script>
</body>
</html>`;
    }
}

module.exports = MonitorPanel;