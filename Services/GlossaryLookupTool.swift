//
//  GlossaryLookupTool.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/24/25.
//


import FoundationModels
import Foundation

@Observable
final class GlossaryLookupTool: Tool {
    let name = "glossaryLookup"
    let description = "Looks up preferred Javanese equivalents for key Indonesian terms."
    private var store: [String: String] = [
        // seed with a few; later load from your DB
        "makan": "nedha / dhahar / mangan",
        "pergi": "mangkat / tindak",
        "kamu": "sampeyan / kowe / panjenengan"
    ]

    @Generable
    struct Arguments {
        @Guide(description: "Comma-separated Indonesian terms to check.")
        let terms: String
    }

    func call(arguments: Arguments) async throws -> String {
        let keys = arguments.terms
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let pairs = keys.map { key in
            let val = store[key] ?? "(tidak ada entri)"
            return "\(key)=\(val)"
        }
        return "Glossary: " + pairs.joined(separator: "; ")
    }
}
