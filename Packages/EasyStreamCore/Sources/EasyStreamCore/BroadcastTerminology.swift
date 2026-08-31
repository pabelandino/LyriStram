import Foundation

/// Broadcast terminology with Spanish UI labels.
public enum BroadcastTerminology {
    /// Preview — what the operator is looking at before going live on program.
    public static let previewShort = "PREV"
    public static let previewName = "Vista previa"

    /// Program — what the audience / stream output receives.
    public static let programShort = "PROG"
    public static let programName = "Programa"

    /// Audio source feeding program output (independent from video switch).
    public static let audioShort = "AUDIO"
    public static let audioName = "Audio de programa"

    /// Instant switch: preview becomes program (broadcast "TAKE", not "cut the connection").
    public static let takeAction = "Al aire"
    public static let takeDescription = "Pasa la vista previa seleccionada al programa"
}
