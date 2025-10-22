//
//  helper.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/22/25.
//


private func normalizedList(from text: String) -> [String] {
    var seen = Set<String>()
    var result: [String] = []
    text
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .map { line in
            // strip bullet prefixes like "- ", "• ", "1. "
            var s = line.replacingOccurrences(of: #"^[-*•]\s*"#, with: "", options: .regularExpression)
            s = s.replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression)
            return s
        }
        .filter { !$0.isEmpty }
        .forEach { item in
            if !seen.contains(item) {
                seen.insert(item)
                result.append(item)
            }
        }
    return result
}
