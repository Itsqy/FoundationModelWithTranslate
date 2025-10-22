import Foundation
import SwiftUI
import Combine
import FoundationModels
import Translation

@MainActor
final class AIGenerationService: ObservableObject {
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var generatedContent: GeneratedContent?
    
    private let dictionaryService: DictionaryService
    private var languageModelSession: LanguageModelSession?
    private let translator: SystemTranslator?
    
    init(dictionaryService: DictionaryService, translator: SystemTranslator? = nil) {
        self.dictionaryService = dictionaryService
        self.translator = translator
        setupFoundationModels()
    }
    
    private func setupFoundationModels() {
        languageModelSession = LanguageModelSession()
    }
    
    // MARK: - Translation Helper
    
    private func translateToIndonesian(_ text: String) async -> String {
        guard #available(iOS 18, *),
              let translator = translator,
              translator.isAvailable,          // 👈 skip if not available
              !text.isEmpty
        else { return text }
        return await translator.translateToIndonesian(text)
    }

    /// Safely extract plain text from a LanguageModelSession response.
    private func extractText<R>(_ response: R) -> String {
        if let s = response as? String { return s }
        let mirror = Mirror(reflecting: response)
        for child in mirror.children {
            if let s = child.value as? String { return s }
        }
        return String(describing: response)
    }
    
    // MARK: - Normalization Helper
    
    /// Cleans and deduplicates bullet-style or repeated lines for safe SwiftUI rendering.
    private func normalizedList(from text: String) -> [String] {
        var seen = Set<String>()
        var results: [String] = []
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map {
                var s = $0.replacingOccurrences(of: #"^[-*•]\s*"#, with: "", options: .regularExpression)
                s = s.replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression)
                return s
            }
            .filter { !$0.isEmpty }
            .forEach { line in
                if !seen.contains(line) {
                    seen.insert(line)
                    results.append(line)
                }
            }
        return results
    }
    
    // MARK: - Content Generation
    
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
                self.errorMessage = "Gagal menghasilkan konten: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    private func analyzeWithFoundationModels(_ text: String) async throws -> GeneratedContent {
        guard let session = languageModelSession else {
            throw NSError(domain: "AIGenerationService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Foundation Models tidak tersedia"])
        }
        
        async let meaning = generateMeaningWithFoundationModels(for: text, session: session)
        async let pronunciation = generatePronunciationWithFoundationModels(for: text, session: session)
        async let usage = generateUsageWithFoundationModels(for: text, session: session)
        async let conversationFunction = generateConversationFunctionWithFoundationModels(for: text, session: session)
        
        return GeneratedContent(
            inputText: text,
            meaning: try await meaning,
            pronunciation: try await pronunciation,
            usage: try await usage,
            conversationFunction: try await conversationFunction
        )
    }
    
    // MARK: - Foundation Models Implementation
    
    private func generateMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Meaning {
        async let literal = generateLiteralMeaningWithFoundationModels(for: text, session: session)
        async let contextual = generateContextualMeaningWithFoundationModels(for: text, session: session)
        return Meaning(literal: try await literal, contextual: try await contextual)
    }
    
    private func generateLiteralMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze this Javanese text: "\(text)"
        Provide literal meaning by breaking down each word.
        Format: Word = meaning, Word = meaning
        """
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        let translated = await translateToIndonesian(raw)
        return "Makna Harfiah: \(translated)\nSecara harfiah: \"\(text)\""
    }
    
    private func generateContextualMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = """
        Analyze this Javanese text: "\(text)"
        Provide contextual meaning and cultural usage.
        """
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        let translated = await translateToIndonesian(raw)
        return "Makna Kontekstual: \(translated)"
    }
    
    private func generatePronunciationWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Pronunciation {
        async let phonetic = generatePhoneticTranscriptionWithFoundationModels(for: text, session: session)
        async let intonation = generateIntonationNotesWithFoundationModels(for: text, session: session)
        return Pronunciation(phonetic: try await phonetic, intonation: try await intonation)
    }
    
    private func generatePhoneticTranscriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = "Provide phonetic transcription (IPA) for: \(text)"
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        return raw.contains("/") ? raw : await translateToIndonesian(raw)
    }
    
    private func generateIntonationNotesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = "Describe intonation and emotional tone for: \(text)"
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        return await translateToIndonesian(raw)
    }
    
    private func generateUsageWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Usage {
        async let situations = generateUsageSituationsWithFoundationModels(for: text, session: session)
        async let examples = generateUsageExamplesWithFoundationModels(for: text, session: session)
        return Usage(situations: try await situations, examples: try await examples)
    }
    
    private func generateUsageSituationsWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        let prompt = """
        Analyze usage situations for "\(text)" and provide bullet points of when it's used.
        """
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        let translated = await translateToIndonesian(raw)
        return normalizedList(from: translated) // ✅ normalized here
    }
    
    private func generateUsageExamplesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        let prompt = """
        Provide 2–3 example situations for "\(text)" with real conversational usage.
        """
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        let translated = await translateToIndonesian(raw)
        return normalizedList(from: translated) // ✅ normalized here
    }
    
    private func generateConversationFunctionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> ConversationFunction {
        async let function = generateFunctionDescriptionWithFoundationModels(for: text, session: session)
        async let equivalent = generateEquivalentExpressionWithFoundationModels(for: text, session: session)
        return ConversationFunction(function: try await function, equivalent: try await equivalent)
    }
    
    private func generateFunctionDescriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = "Analyze the conversational function of \(text)"
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        return await translateToIndonesian(raw)
    }
    
    private func generateEquivalentExpressionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        let prompt = "Find equivalent Indonesian expressions for \(text)"
        let resp = try await session.respond(to: prompt)
        let raw = extractText(resp)
        return await translateToIndonesian(raw)
    }
}
