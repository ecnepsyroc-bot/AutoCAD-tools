using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using System.Windows;
using Luxify.Bridge.Services;

namespace Luxify.Bridge.ViewModels
{
    public class BridgeMonitorViewModel : INotifyPropertyChanged
    {
        private readonly BridgeService _bridgeService;
        private string _commandInput = string.Empty;
        private ObservableCollection<string> _logs = new ObservableCollection<string>();

        public ObservableCollection<string> Logs
        {
            get => _logs;
            set { _logs = value; OnPropertyChanged(); }
        }

        public string CommandInput
        {
            get => _commandInput;
            set { _commandInput = value; OnPropertyChanged(); }
        }

        public ICommand SendCommand { get; }
        public ICommand ClearLogsCommand { get; }

        public BridgeMonitorViewModel()
        {
            _bridgeService = new BridgeService();
            _bridgeService.MessageReceived += OnMessageReceived;

            SendCommand = new RelayCommand(ExecuteCommand, () => !string.IsNullOrWhiteSpace(CommandInput));
            ClearLogsCommand = new RelayCommand(() => Logs.Clear());
        }

        private void OnMessageReceived(object? sender, string message)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                Logs.Add(message);
                // Auto-scroll logic would go here or in View code-behind
            });
        }

        private void ExecuteCommand()
        {
            if (string.IsNullOrWhiteSpace(CommandInput)) return;

            _bridgeService.SendCommand(CommandInput);
            Logs.Add($">>> {CommandInput}"); // Local echo
            CommandInput = string.Empty;
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }

    public class RelayCommand : ICommand
    {
        private readonly Action _execute;
        private readonly Func<bool>? _canExecute;

        public RelayCommand(Action execute, Func<bool>? canExecute = null)
        {
            _execute = execute;
            _canExecute = canExecute;
        }

        public bool CanExecute(object? parameter) => _canExecute == null || _canExecute();
        public void Execute(object? parameter) => _execute();
        public event EventHandler? CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }
    }
}
