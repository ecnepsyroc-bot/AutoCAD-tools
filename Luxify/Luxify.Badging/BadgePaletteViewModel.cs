using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using System.Threading.Tasks;
using System.Windows;
using System.Collections.Generic;
using Luxify.Core;
using Luxify.Badging.Services;

namespace Luxify.Badging;

public class BadgePaletteViewModel : INotifyPropertyChanged
{
    private readonly IExcelService _excelService;
    private readonly IApiService _apiService;
    private ObservableCollection<LuxifyLeaf> _badges = new();

    public ObservableCollection<LuxifyLeaf> Badges
    {
        get => _badges;
        set { _badges = value; OnPropertyChanged(); }
    }

    public ICommand LoadCommand { get; }
    public ICommand PulseCommand { get; }
    public ICommand PlaceCommand { get; }
    public ICommand SaveCommand { get; }

    public BadgePaletteViewModel()
    {
        _excelService = new MockExcelService();
        _apiService = new MockApiService(); // In real app, inject this
        
        LoadCommand = new RelayCommand(LoadData);
        PulseCommand = new RelayCommand(async () => await PulseAsync());
        PlaceCommand = new RelayCommand<LuxifyLeaf>(PlaceBadge);
        SaveCommand = new RelayCommand(SaveData);
        
        // Load initial data
        LoadData();
    }

    private void SaveData()
    {
        string csvPath = @"C:\Dev\AutoCAD-tools\Luxify\SampleJob\fo-sample.csv";
        _excelService.SaveSpecs(csvPath, Badges);
    }

    private void PlaceBadge(LuxifyLeaf badge)
    {
        if (badge == null) return;
        BadgingCommands.ActiveBadge = badge;
        
        // Send command to AutoCAD
        Autodesk.AutoCAD.ApplicationServices.Application.DocumentManager.MdiActiveDocument.SendStringToExecute("LUX_PLACE_BADGE ", true, false, false);
    }

    private void LoadData()
    {
        // Temporary Data for Template Build
        var mockData = new List<LuxifyLeaf>();

        // Item 1: Standard
        mockData.Add(new LuxifyLeaf
        {
            Xylem = new LeafXylem 
            { 
                Code = "PL1", 
                FullSpec = "Plastic Laminate, Matte Finish, 4x8 Sheet, Wilsonart 1573-60", 
                Shorthand = "PL-1 Matte" 
            },
            Phloem = new LeafPhloem 
            { 
                IsSpecDirty = false, 
                IsStockCritical = false,
                ProvenanceFlag = true,
                AvailabilityFlag = true
            }
        });

        // Item 2: Critical Stock
        mockData.Add(new LuxifyLeaf
        {
            Xylem = new LeafXylem 
            { 
                Code = "WD1", 
                FullSpec = "Solid Wood, White Oak, Plain Sawn, Clear Grade", 
                Shorthand = "W-Oak Clear" 
            },
            Phloem = new LeafPhloem 
            { 
                IsSpecDirty = false, 
                IsStockCritical = true,
                ProvenanceFlag = true,
                AvailabilityFlag = false
            }
        });

        // Item 3: Changed Spec
        mockData.Add(new LuxifyLeaf
        {
            Xylem = new LeafXylem 
            { 
                Code = "MT1", 
                FullSpec = "Metal, Stainless Steel, Brushed #4, 16 Gauge", 
                Shorthand = "SS #4" 
            },
            Phloem = new LeafPhloem 
            { 
                IsSpecDirty = true, 
                IsStockCritical = false,
                ProvenanceFlag = false,
                AvailabilityFlag = true
            }
        });

        Badges = new ObservableCollection<LuxifyLeaf>(mockData);
    }

    private async Task PulseAsync()
    {
        if (Badges == null || Badges.Count == 0) return;

        // 1. Create Request
        var request = new PulseRequest
        {
            JobId = "123456",
            Badges = new List<string>()
        };

        foreach (var b in Badges)
        {
            request.Badges.Add(b.Xylem.Code);
        }

        // 2. Call API
        try 
        {
            var result = await _apiService.CheckPulseAsync(request);

            // 3. Update Models
            foreach (var badge in Badges)
            {
                if (result.TryGetValue(badge.Xylem.Code, out var status))
                {
                    badge.Phloem.IsSpecDirty = status.IsSpecDirty;
                    badge.Phloem.IsStockCritical = status.IsStockCritical;
                    // Note: In a full MVVM app, we'd raise PropertyChanged on the badge itself
                    // or replace the item to trigger UI update.
                    // For now, the DataGrid might not update unless we force it or if LuxifyLeaf implements INotifyPropertyChanged.
                    // Let's assume we need to refresh the view or the properties are bound.
                }
            }
            
            // 4. Update AutoCAD Overlays
            // Must run on main thread with document lock
            Application.Current.Dispatcher.Invoke(() => 
            {
                var doc = Autodesk.AutoCAD.ApplicationServices.Application.DocumentManager.MdiActiveDocument;
                if (doc != null)
                {
                    using (doc.LockDocument())
                    {
                        BadgingCommands.UpdateOverlays(Badges);
                    }
                }
            });
        }
        catch (Exception ex)
        {
            System.Windows.MessageBox.Show($"Pulse Failed: {ex.Message}");
        }
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
    public event EventHandler? CanExecuteChanged;
}

public class RelayCommand<T> : ICommand
{
    private readonly Action<T> _execute;
    private readonly Predicate<T>? _canExecute;

    public RelayCommand(Action<T> execute, Predicate<T>? canExecute = null)
    {
        _execute = execute;
        _canExecute = canExecute;
    }

    public bool CanExecute(object? parameter) => _canExecute == null || _canExecute((T)parameter);
    public void Execute(object? parameter) => _execute((T)parameter);
    public event EventHandler? CanExecuteChanged;
}
