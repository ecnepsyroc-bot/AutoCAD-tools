namespace Luxify.Core;

/// <summary>
/// Represents the Spec Data (The "Xylem" - Transporting identity).
/// </summary>
public class LeafXylem
{
    /// <summary>
    /// The unique code for the item (e.g., "PL1").
    /// </summary>
    public string Code { get; set; } = string.Empty;

    /// <summary>
    /// The full specification string.
    /// </summary>
    public string FullSpec { get; set; } = string.Empty;

    /// <summary>
    /// A shorthand representation for Legends.
    /// </summary>
    public string Shorthand { get; set; } = string.Empty;
}
