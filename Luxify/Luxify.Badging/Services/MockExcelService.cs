using Luxify.Core;
using System.IO;

namespace Luxify.Badging.Services;

public class MockExcelService : IExcelService
{
    public IEnumerable<LuxifyLeaf> LoadSpecs(string filePath)
    {
        var list = new List<LuxifyLeaf>();

        if (File.Exists(filePath))
        {
            var lines = File.ReadAllLines(filePath);
            // Skip header
            foreach (var line in lines.Skip(1))
            {
                var parts = line.Split(',');
                if (parts.Length >= 10)
                {
                    list.Add(new LuxifyLeaf
                    {
                        Xylem = new LeafXylem
                        {
                            Code = parts[0],
                            FullSpec = parts[1],
                            Shorthand = parts[2]
                        },
                        Phloem = new LeafPhloem
                        {
                            IsSpecDirty = bool.Parse(parts[3]),
                            IsStockCritical = bool.Parse(parts[4])
                        },
                        Label = new LabelData
                        {
                            ElevationLetter = parts[5],
                            Description = parts[6],
                            Note = parts[7],
                            DetailRef = parts[8],
                            ArchSheetRef = parts[9]
                        }
                    });
                }
            }
        }
        else
        {
            // Fallback to mock loop if file not found
            for (int i = 1; i <= 10; i++)
            {
                list.Add(new LuxifyLeaf
                {
                    Xylem = new LeafXylem
                    {
                        Code = $"PL{i}",
                        FullSpec = $"Cabinet Type {i} - 30x30",
                        Shorthand = $"C{i}"
                    },
                    Phloem = new LeafPhloem
                    {
                        IsSpecDirty = i % 3 == 0,
                        IsStockCritical = i % 5 == 0
                    },
                    Label = new LabelData
                    {
                        ElevationLetter = "A",
                        Description = $"Cabinet {i}",
                        Note = "Verify Field Dims",
                        DetailRef = "SK1",
                        ArchSheetRef = "2-AD02"
                    }
                });
            }
        }
        
        return list;
    }

    public void SaveSpecs(string filePath, IEnumerable<LuxifyLeaf> specs)
    {
        var lines = new List<string>();
        // Header
        lines.Add("Code,FullSpec,Shorthand,IsSpecDirty,IsStockCritical,ElevationLetter,Description,Note,DetailRef,ArchSheetRef");

        foreach (var leaf in specs)
        {
            var line = string.Join(",",
                leaf.Xylem.Code,
                leaf.Xylem.FullSpec,
                leaf.Xylem.Shorthand,
                leaf.Phloem.IsSpecDirty,
                leaf.Phloem.IsStockCritical,
                leaf.Label.ElevationLetter,
                leaf.Label.Description,
                leaf.Label.Note,
                leaf.Label.DetailRef,
                leaf.Label.ArchSheetRef
            );
            lines.Add(line);
        }

        File.WriteAllLines(filePath, lines);
    }
}
