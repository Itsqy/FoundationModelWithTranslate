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

// MARK: - Output Cleaner Utility

enum LMCleaner {
    static func clean(_ s: String) -> String {
        var t = s
        t = t.replacingOccurrences(of: "```", with: "")
        t = t.replacingOccurrences(of: "`", with: "")
        t = t.replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\r", with: "")
        t = t.replacingOccurrences(of: #"(?m)^\s{0,3}#{1,6}\s*"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?m)^\s{0,3}>\s*"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\*\*([^*]+)\*\*"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\*([^*]+)\*"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"__([^_]+)__"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"_([^_]+)_"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "$1", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?m)^\s*[-*•+]\s*"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"(?m)^\s*\d+[.)]\s*"#, with: "", options: .regularExpression)
        t = t.replacingOccurrences(of: #"[ \t]{2,}"#, with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return t
    }

    static func lines(from s: String) -> [String] {
        clean(s)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

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

// MARK: - AI Generation Service

class AIGenerationService: ObservableObject {
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var generatedContent: GeneratedContent?

    private let dictionaryService: DictionaryService

    init(dictionaryService: DictionaryService) {
        self.dictionaryService = dictionaryService
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
        let meaning = try await generateMeaningWithFoundationModels(for: text)
        let pronunciation = try await generatePronunciationWithFoundationModels(for: text)
        let usage = try await generateUsageWithFoundationModels(for: text)
        let conversationFunction = try await generateConversationFunctionWithFoundationModels(for: text)

        return GeneratedContent(
            inputText: text,
            meaning: meaning,
            pronunciation: pronunciation,
            usage: usage,
            conversationFunction: conversationFunction
        )
    }

    // MARK: - Meaning

    private func generateMeaningWithFoundationModels(for text: String) async throws -> Meaning {
        let literal = try await generateLiteralMeaningWithFoundationModels(for: text)
        let contextual = try await generateContextualMeaningWithFoundationModels(for: text)
        return Meaning(literal: literal, contextual: contextual)
    }

    private func generateLiteralMeaningWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Analyze this text/sentences : "\(text)"
        Provide literal meaning by breaking down each word:
        - Word by word translation
        - Literal meaning explanation
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "generate one usecase to use that word/sentences and translate it to indonesia"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("literal response : \(cleaned)")
        return "Literal:\n\(cleaned)\n\nJadi secara harfiah: \"\(text)\""
    }

    private func generateContextualMeaningWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Analyze this text/sentences : "\(text)"
        Provide contextual meaning:
        - Explain its implied or cultural meaning
        - Describe when or how it is used
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "generate explanation in simple Indonesian about its contextual meaning"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("contextual response : \(cleaned)")
        return "Kontekstual:\n\(cleaned)"
    }

    // MARK: - Pronunciation

    private func generatePronunciationWithFoundationModels(for text: String) async throws -> Pronunciation {
        let phonetic = try await generatePhoneticTranscriptionWithFoundationModels(for: text)
        let intonation = try await generateIntonationNotesWithFoundationModels(for: text)
        return Pronunciation(phonetic: phonetic, intonation: intonation)
    }

    private func generatePhoneticTranscriptionWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Provide phonetic transcription for this text/sentences : "\(text)"
        Use IPA (International Phonetic Alphabet) notation:
        - Show syllable breaks with dots
        - Include stress markers if needed
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "return only the phonetic transcription using IPA format like /ma.dhaŋ/"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.extractIPA(from: response.content) ?? LMCleaner.clean(response.content)
        print("transcription response : \(cleaned)")
        return cleaned
    }

    private func generateIntonationNotesWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Analyze the intonation pattern for this text/sentences : "\(text)"
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "describe the pitch pattern, emphasis, and tone (e.g. polite, casual, emotional)"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("intonation response : \(cleaned)")
        return cleaned
    }

    // MARK: - Usage

    private func generateUsageWithFoundationModels(for text: String) async throws -> Usage {
        let situations = try await generateUsageSituationsWithFoundationModels(for: text)
        let examples = try await generateUsageExamplesWithFoundationModels(for: text)
        return Usage(situations: situations, examples: examples)
    }

    private func generateUsageSituationsWithFoundationModels(for text: String) async throws -> [String] {
        let instructions = """
        Analyze usage situations for this text/sentences : "\(text)"
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "generate 1 specific situations when this phrase would be used, in Indonesian"

        let response = try await session.respond(to: prompt)
        let items = LMCleaner.lines(from: response.content)
        print("situation response : \(items.joined(separator: " | "))")
        return items
    }

    private func generateUsageExamplesWithFoundationModels(for text: String) async throws -> [String] {
        let instructions = """
        Analyze this text/sentences : "\(text)"
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "generate 1 example use cases in conversation and translate them into Indonesian"

        let response = try await session.respond(to: prompt)
        let items = LMCleaner.lines(from: response.content)
        print("usage example response : \(items.joined(separator: " | "))")
        return items
    }

    // MARK: - Conversation Function

    private func generateConversationFunctionWithFoundationModels(for text: String) async throws -> ConversationFunction {
        let function = try await generateFunctionDescriptionWithFoundationModels(for: text)
        let equivalent = try await generateEquivalentExpressionWithFoundationModels(for: text)
        return ConversationFunction(function: function, equivalent: equivalent)
    }

    private func generateFunctionDescriptionWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Analyze the conversational function of this text/sentences : "\(text)"
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "explain what this expression does in a conversation (e.g. greeting, apology, showing respect)"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("description response : \(cleaned)")
        return cleaned
    }

    private func generateEquivalentExpressionWithFoundationModels(for text: String) async throws -> String {
        let instructions = """
        Find equivalent expressions for this text/sentences : "\(text)"
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "provide equivalent expressions in Indonesian that carry the same meaning"

        let response = try await session.respond(to: prompt)
        let cleaned = LMCleaner.clean(response.content)
        print("equivalent expression response : \(cleaned)")
        return cleaned
    }
}
