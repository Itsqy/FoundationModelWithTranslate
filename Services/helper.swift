// MARK: - Output Cleaner Utility (replace your existing LMCleaner with this)

 enum LMCleaner {
    static func clean(_ s: String) -> String {
        var t = s

        // Unwrap code fences & inline code
        t = t.replacingOccurrences(of: "```", with: "")
        t = t.replacingOccurrences(of: "`", with: "")

        // Convert escaped sequences often seen in raw dumps
        t = t.replacingOccurrences(of: "\\n", with: "\n")
             .replacingOccurrences(of: "\\\"", with: "\"")
             .replacingOccurrences(of: "\r", with: "")

        // Strip Markdown headings and blockquotes at line starts
        t = t.replacingOccurrences(
            of: #"(?m)^\s{0,3}#{1,6}\s*"#,
            with: "",
            options: .regularExpression
        )
        t = t.replacingOccurrences(
            of: #"(?m)^\s{0,3}>\s*"#,
            with: "",
            options: .regularExpression
        )

        // Strip bold/italic markers: **text**, *text*, __text__, _text_
        // (Keep content; remove only markers)
        t = t.replacingOccurrences(of: #"\*\*([^*]+)\*\*"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\*([^*]+)\*"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"__([^_]+)__"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"_([^_]+)_"#, with: "$1", options: .regularExpression)

        // Convert Markdown links [text](url) -> text
        t = t.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "$1", options: .regularExpression)

        // Strip residual bullet symbols / numbering at line starts
        t = t.replacingOccurrences(of: #"(?m)^\s*[-*•+]\s*"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?m)^\s*\d+[.)]\s*"#, with: "", options: .regularExpression)

        // Collapse repeated whitespace & blank lines
        t = t.replacingOccurrences(of: #"[ \t]{2,}"#, with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
             .trimmingCharacters(in: .whitespacesAndNewlines)

        return t
    }

    /// Turn a bulleted/numbered paragraph into an array of clean lines.
    static func lines(from s: String) -> [String] {
        clean(s)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Try to extract an IPA transcription delimited by /.../ or [ ... ].
    static func extractIPA(from s: String) -> String? {
        let cleaned = clean(s)
        if let m = cleaned.range(of: #"/[^/]+/"#, options: .regularExpression) {
            return String(cleaned[m])
        }
        if let m = cleaned.range(of: #"\[[^\]]+\]"#, options: .regularExpression) {
            return String(cleaned[m])
        }
        return nil
    }
}
