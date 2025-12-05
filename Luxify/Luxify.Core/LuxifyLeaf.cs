namespace Luxify.Core;

/// <summary>
/// The master container for a Millwork Item (The "Leaf").
/// </summary>
public class LuxifyLeaf
{
    /// <summary>
    /// The Spec Data.
    /// </summary>
    public LeafXylem Xylem { get; set; } = new();

    /// <summary>
    /// The Status Data.
    /// </summary>
    public LeafPhloem Phloem { get; set; } = new();

    /// <summary>
    /// The Label Data (Contract References).
    /// </summary>
    public LabelData Label { get; set; } = new();
}
