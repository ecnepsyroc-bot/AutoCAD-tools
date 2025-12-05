using Luxify.Core;

namespace Luxify.Badging.Services;

public interface IExcelService
{
    IEnumerable<LuxifyLeaf> LoadSpecs(string filePath);
    void SaveSpecs(string filePath, IEnumerable<LuxifyLeaf> specs);
}
