namespace Luxify.Core;

public class PulseStatus
{
    public bool IsSpecDirty { get; set; }
    public bool IsStockCritical { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class PulseRequest
{
    public string JobId { get; set; } = string.Empty;
    public List<string> Badges { get; set; } = new();
}
