//
//  JavaneseTranslator.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/24/25.
//


import FoundationModels
import Observation

@Observable
@MainActor
final class JavaneseTranslator {
    private(set) var translation: Translation.PartiallyGenerated?
    private let session: LanguageModelSession
    private let glossaryTool: GlossaryLookupTool?  // optional, see section 3

    var error: Error?

    init(glossaryTool: GlossaryLookupTool? = nil) {
        self.glossaryTool = glossaryTool

        // === SYSTEM / DEVELOPER INSTRUCTIONS (persistent) ===
        self.session = LanguageModelSession(
            tools: glossaryTool.map { [$0] } ?? [],
            instructions: Instructions {
                // Role & output contract
                """
                You are a careful Indonesian → Javanese translator for a language-learning app.
                Always output ONLY the structured fields of the Translation schema.
                Avoid extra chit-chat, disclaimers, or markdown.
                """

                // Register rules (crucial for quality)
                """
                Registers (top to bottom, more formal to casual): Krama Inggil > Krama > Ngoko Alus > Ngoko.
                When a register is provided, strictly use it.
                If not provided, default to Ngoko Alus for polite but approachable tone.
                """

                // Terminology & named entities
                """
                Preserve named entities (people, brands, places) in Latin script.
                For untranslatable tech terms, prefer common Javanese borrowing or Indonesian if widely used.
                """

                // Style & orthography
                """
                Prefer modern Latin orthography for Javanese (e.g., 'kowe', 'sampeyan', 'panjenengan').
                Avoid mixing registers in one sentence unless notes explain a reason.
                Keep sentences compact and natural in the chosen register.
                """

                // Pedagogical fields
                """
                'notes' should mention ambiguity, register swaps, and key choices (≤3 bullets).
                'wordByWord' should include only the most relevant mappings (≤6 items).
                'examples' should be short, natural, same register, and reuse vocabulary.
                'hanacaraka' stays empty unless the request explicitly asks for Aksara Jawa.
                """

                // Tooling policy (if tool exists)
                if glossaryTool != nil {
                    """
                    If user provides a glossary or key terms, call the glossary tool BEFORE finalizing 'target'.
                    """
                }

                // Few-shot (mini) — stable anchors for tone & register (kept tiny)
                ExamplePairs.fewShot1
                ExamplePairs.fewShot2
            }
        )
    }

    func streamTranslate(
        source: String,
        register: String? = nil,
        forceHanacaraka: Bool = false,
        maxGlossItems: Int = 4
    ) async throws {
        // === PER-REQUEST PROMPT (dynamic) ===
        let stream = session.streamResponse(
            generating: Translation.self,
            includeSchemaInPrompt: true,
            options: GenerationOptions(
                temperature: 0.2
            )
        ) {
            // Task framing
            "Translate the Indonesian text to Javanese."

            // Hard constraints
            """
            STRICT RULES:
            - Fill ALL fields of Translation schema.
            - Do NOT include any markdown or commentary outside the schema.
            - Use the requested register if provided, else Ngoko Alus.
            - Limit 'wordByWord' to \(maxGlossItems) most useful mappings.
            - If \(forceHanacaraka ? "yes" : "no") then include 'hanacaraka' with Aksara Jawa; else leave empty.
            """

            // Input payload (keep it explicit to avoid leakage)
            "Source text:\n\(source)"

            if let reg = register, !reg.isEmpty {
                "Requested register: \(reg)"
            }

            // Optional tool nudge
            if glossaryTool != nil {
                """
                If uncertain about domain terms, call the 'glossaryLookup' tool with a short comma-separated list \
                of key terms from the source text, then align choices accordingly.
                """
            }

            // Gentle shaping
            """
            Prioritize naturalness over literalness in 'target', but capture tricky bits in 'notes'.
            If a sentence is culture-bound, adapt idiomatically and explain briefly in 'notes'.
            """
        }

        for try await partial in stream {
            translation = partial.content
        }
    }

    func prewarm() { session.prewarm() }
}

// ====== Minimal few-shot anchors ======
enum ExamplePairs {
    static let fewShot1 =
    """
    Indonesian: "Permisi, apakah Bapak sudah makan?"
    Register: Krama
    Target (Javanese): "Nuwun sewu, menapa Panjenengan sampun nedha?"
    Notes: ["Sapaan hormat 'Panjenengan', verba krama 'nedha'."]
    WordByWord: [
      {id:1, indo:"Permisi", jawa:"Nuwun sewu", pos:"expr"},
      {id:2, indo:"Bapak", jawa:"Panjenengan", pos:"n."}
    ]
    Examples: ["Menapa Panjenengan badhe dhahar sakmenika?",
               "Mangga lenggah rumiyin."]
    Hanacaraka: ""
    """

    static let fewShot2 =
    """
    Indonesian: "Kamu sudah siap berangkat?"
    Register: Ngoko Alus
    Target (Javanese): "Sampeyan wis siyap mangkat durung?"
    Notes: ["'Sampeyan' alus; susunan tanya natural."]
    WordByWord: [
      {id:1, indo:"kamu", jawa:"sampeyan", pos:"pron"},
      {id:2, indo:"berangkat", jawa:"mangkat", pos:"v."}
    ]
    Examples: ["Sampeyan wis sarapan durung?",
               "Ayo mangkat saiki."]
    Hanacaraka: ""
    """
}
