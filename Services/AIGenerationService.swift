//
//  AIGenerationService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import Foundation
import SwiftUI
import NaturalLanguage
import Combine
import FoundationModels

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

class AIGenerationService: ObservableObject {
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var generatedContent: GeneratedContent?
    
    private let dictionaryService: DictionaryService
    private var languageModelSession: LanguageModelSession?
    
    init(dictionaryService: DictionaryService) {
        self.dictionaryService = dictionaryService
        setupFoundationModels()
    }
    
    private func setupFoundationModels() {
        languageModelSession = LanguageModelSession()
    }
    
    func generateContent(for javaneseText: String) async {
        await MainActor.run {
            isGenerating = true
            errorMessage = nil
            generatedContent = nil
        }
        
        do {
            let content = try await analyzeWithFoundationModels(javaneseText)
            await MainActor.run {
                self.generatedContent = content
                self.isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate content: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    private func analyzeWithFoundationModels(_ text: String) async throws -> GeneratedContent {
        guard let session = languageModelSession else {
            throw NSError(domain: "AIGenerationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Foundation Models not available"])
        }
        
        let meaning = try await generateMeaningWithFoundationModels(for: text, session: session)
        let pronunciation = try await generatePronunciationWithFoundationModels(for: text, session: session)
        let usage = try await generateUsageWithFoundationModels(for: text, session: session)
        let conversationFunction = try await generateConversationFunctionWithFoundationModels(for: text, session: session)
        
        return GeneratedContent(
            inputText: text,
            meaning: meaning,
            pronunciation: pronunciation,
            usage: usage,
            conversationFunction: conversationFunction
        )
    }
    
    // MARK: - Meaning
    
    private func generateMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Meaning {
        let literal = try await generateLiteralMeaningWithFoundationModels(for: text, session: session)
        let contextual = try await generateContextualMeaningWithFoundationModels(for: text, session: session)
        return Meaning(literal: literal, contextual: contextual)
    }
    
    private func generateLiteralMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze this Javanese text: "\(text)"
        Provide literal meaning by breaking down each word:
        - Word by word translation
        - Literal meaning explanation
        Format: Word = meaning, Word = meaning
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("literal response : \(cleaned)")
        return "Literal:\n\(cleaned)\n\nJadi secara harfiah: \"\(text)\""
    }
    
    private func generateContextualMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze this Javanese text: "\(text)"
        Provide contextual meaning:
        - What does this phrase mean in context?
        - When would someone use this?
        - What is the cultural context?
        Respond with a clear contextual explanation.
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("kontekstual response : \(cleaned)")
        return "Kontekstual:\n\(cleaned)"
    }
    
    // MARK: - Pronunciation
    
    private func generatePronunciationWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Pronunciation {
        let phonetic = try await generatePhoneticTranscriptionWithFoundationModels(for: text, session: session)
        let intonation = try await generateIntonationNotesWithFoundationModels(for: text, session: session)
        return Pronunciation(phonetic: phonetic, intonation: intonation)
    }
    
    private func generatePhoneticTranscriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Provide phonetic transcription for this Javanese text: "\(text)"
        Use IPA (International Phonetic Alphabet) notation:
        - Show syllable breaks with dots
        - Include stress markers if needed
        - Use standard IPA symbols
        Format: /phonetic.transcription/
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.extractIPA(from: response.content) ?? LMCleaner.clean(response.content)
        print("transcription response : \(cleaned)")
        return cleaned
    }
    
    private func generateIntonationNotesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze the intonation pattern for this Javanese text: "\(text)"
        Provide intonation guidance:
        - How should the pitch rise and fall?
        - Where should emphasis be placed?
        - What is the emotional tone?
        Respond with clear intonation instructions.
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("intonation response : \(cleaned)")
        return cleaned
    }
    
    // MARK: - Usage
    
    private func generateUsageWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Usage {
        let situations = try await generateUsageSituationsWithFoundationModels(for: text, session: session)
        let examples = try await generateUsageExamplesWithFoundationModels(for: text, session: session)
        return Usage(situations: situations, examples: examples)
    }
    
    private func generateUsageSituationsWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        let prompt = """
        Analyze usage situations for this Javanese text: "\(text)"
        Provide 2-3 specific situations when this phrase would be used:
        - When would someone say this?
        - In what contexts is this appropriate?
        - What social situations call for this expression?
        Respond with bullet points of specific situations.
        """
        let response = try await session.respond(to: prompt)
        let items = LMCleaner.lines(from: response.content)
        print("situation response : \(items.joined(separator: " | "))")
        return items
    }
    
    private func generateUsageExamplesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        let prompt = """
        Provide usage examples for this Javanese text: "\(text)"
        Give 2-3 specific example scenarios:
        - Concrete situations where this would be said
        - Real-world examples of usage
        - Specific contexts and scenarios
        Respond with specific example situations.
        """
        let response = try await session.respond(to: prompt)
        let items = LMCleaner.lines(from: response.content)
        print("usage example response : \(items.joined(separator: " | "))")
        return items
    }
    
    // MARK: - Conversation Function
    
    private func generateConversationFunctionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> ConversationFunction {
        let function = try await generateFunctionDescriptionWithFoundationModels(for: text, session: session)
        let equivalent = try await generateEquivalentExpressionWithFoundationModels(for: text, session: session)
        return ConversationFunction(function: function, equivalent: equivalent)
    }
    
    private func generateFunctionDescriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze the conversational function of this Javanese text: "\(text)"
        Explain its function in conversation:
        - What role does this phrase play in communication?
        - How does it function in social interaction?
        - What is its purpose in conversation?
        Respond with a clear description of its conversational function.
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("description response : \(cleaned)")
        return cleaned
    }
    
    private func generateEquivalentExpressionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Find equivalent expressions for this Javanese text: "\(text)"
        Provide equivalent expressions in Indonesian:
        - What would be the Indonesian equivalent?
        - How would you say this in Indonesian?
        - What's the closest Indonesian phrase?
        Respond with the Indonesian equivalent.
        """
        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("equivalent expression response : \(cleaned)")
        return cleaned
    }
}

// MARK: - Output Cleaner Utility


