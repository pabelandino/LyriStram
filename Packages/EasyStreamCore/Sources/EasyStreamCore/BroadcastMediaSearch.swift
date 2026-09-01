import Foundation

public enum BroadcastMediaSearch {
    public static func normalize(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    public static func matches(_ query: String, in text: String) -> Bool {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else { return true }
        return text.lowercased().contains(normalizedQuery)
    }
}

public enum BroadcastDisplayNameSanitizer {
    public static func looksLikeGeneratedIdentifier(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        if trimmed.count >= 32, trimmed.allSatisfy({ $0.isHexDigit || $0 == "-" }) {
            return true
        }
        return false
    }

    public static func sanitized(_ displayName: String?, fallbackFileName: String) -> String {
        let trimmed = displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty, !looksLikeGeneratedIdentifier(trimmed) {
            return trimmed
        }

        let fallback = (fallbackFileName as NSString).deletingPathExtension
        if !looksLikeGeneratedIdentifier(fallback) {
            return fallback
        }

        return trimmed.isEmpty ? fallback : trimmed
    }
}

private extension Character {
    var isHexDigit: Bool {
        ("0"..."9").contains(self) || ("a"..."f").contains(self) || ("A"..."F").contains(self)
    }
}
