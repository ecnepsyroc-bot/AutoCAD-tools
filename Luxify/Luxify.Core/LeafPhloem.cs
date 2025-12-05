namespace Luxify.Core;

/// <summary>
/// Represents the Status (The "Phloem" - Transporting nutrients/state).
/// </summary>
public class LeafPhloem
{
    /// <summary>
    /// Indicates if the spec has changed from the source.
    /// Controls the "Triangle" visibility.
    /// </summary>
    public bool IsSpecDirty { get; set; }

    /// <summary>
    /// Indicates if the item is stock critical.
    /// Controls the "Octagon" visibility.
    /// </summary>
    public bool IsStockCritical { get; set; }

    /// <summary>
    /// Indicates provenance status (Triangle).
    /// </summary>
    public bool ProvenanceFlag { get; set; }

    /// <summary>
    /// Indicates availability status (Octagon).
    /// </summary>
    public bool AvailabilityFlag { get; set; }
}
