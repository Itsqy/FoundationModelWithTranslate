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
import Translation

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
        // Initialize Apple's Foundation Models framework
        languageModelSession = LanguageModelSession()
    }
    
    // MARK: - Translation Helper
    
    private func translateToIndonesian(_ text: String) async -> String {
        // Use Apple's Translation framework (iOS 18+)
        do {
            let session = TranslationSession(installedSource: .init(identifier: "en"), target: .init(identifier: "id"))
            let result = try await session.translate(text)
            return result.description
        } catch {
            print("Translation failed: \(error)")
            return text // Return original text if translation fails
        }
    }
    
    func generateContent(for javaneseText: String) async {
        await MainActor.run {
            isGenerating = true
            errorMessage = nil
            generatedContent = nil
        }
        
        do {
            // Use Apple's Foundation Models for comprehensive analysis
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
        
        // Use Apple's Foundation Models for comprehensive analysis
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
    
    // MARK: - Foundation Models Implementation
    
    private func generateMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Meaning {
        // Use Apple's Foundation Models for meaning analysis
        let literal = try await generateLiteralMeaningWithFoundationModels(for: text, session: session)
        let contextual = try await generateContextualMeaningWithFoundationModels(for: text, session: session)
        
        return Meaning(literal: literal, contextual: contextual)
    }
    
    private func generateLiteralMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for literal meaning analysis
        let prompt = """
        Analyze this Javanese text: "\(text)"
        
        Provide literal meaning by breaking down each word:
        - Word by word translation
        - Literal meaning explanation
        
        Format: Word = meaning, Word = meaning
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return "Literal: \(translatedResponse)\nJadi secara harfiah: \"\(text)\""
    }
    
    private func generateContextualMeaningWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for contextual meaning analysis
        let prompt = """
        Analyze this Javanese text: "\(text)"
        
        Provide contextual meaning:
        - What does this phrase mean in context?
        - When would someone use this?
        - What is the cultural context?
        
        Respond with a clear contextual explanation.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return "Kontekstual: \(translatedResponse)"
    }
    
    private func generatePronunciationWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Pronunciation {
        // Use Apple's Foundation Models for dynamic pronunciation generation
        let phonetic = try await generatePhoneticTranscriptionWithFoundationModels(for: text, session: session)
        let intonation = try await generateIntonationNotesWithFoundationModels(for: text, session: session)
        
        return Pronunciation(phonetic: phonetic, intonation: intonation)
    }
    
    private func generatePhoneticTranscriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for dynamic phonetic transcription
        let prompt = """
        Provide phonetic transcription for this Javanese text: "\(text)"
        
        Use IPA (International Phonetic Alphabet) notation:
        - Show syllable breaks with dots
        - Include stress markers if needed
        - Use standard IPA symbols
        
        Format: /phonetic.transcription/
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse
    }
    
    private func generateIntonationNotesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for intonation analysis
        let prompt = """
        Analyze the intonation pattern for this Javanese text: "\(text)"
        
        Provide intonation guidance:
        - How should the pitch rise and fall?
        - Where should emphasis be placed?
        - What is the emotional tone?
        
        Respond with clear intonation instructions.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse
    }
    
    private func generateUsageWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> Usage {
        // Use Apple's Foundation Models for usage analysis
        let situations = try await generateUsageSituationsWithFoundationModels(for: text, session: session)
        let examples = try await generateUsageExamplesWithFoundationModels(for: text, session: session)
        
        return Usage(situations: situations, examples: examples)
    }
    
    private func generateUsageSituationsWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        // Use Apple's Foundation Models for situation analysis
        let prompt = """
        Analyze usage situations for this Javanese text: "\(text)"
        
        Provide 2-3 specific situations when this phrase would be used:
        - When would someone say this?
        - In what contexts is this appropriate?
        - What social situations call for this expression?
        
        Respond with bullet points of specific situations.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    private func generateUsageExamplesWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> [String] {
        // Use Apple's Foundation Models for example generation
        let prompt = """
        Provide usage examples for this Javanese text: "\(text)"
        
        Give 2-3 specific example scenarios:
        - Concrete situations where this would be said
        - Real-world examples of usage
        - Specific contexts and scenarios
        
        Respond with specific example situations.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    private func generateConversationFunctionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> ConversationFunction {
        // Use Apple's Foundation Models for conversation analysis
        let function = try await generateFunctionDescriptionWithFoundationModels(for: text, session: session)
        let equivalent = try await generateEquivalentExpressionWithFoundationModels(for: text, session: session)
        
        return ConversationFunction(function: function, equivalent: equivalent)
    }
    
    private func generateFunctionDescriptionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for function analysis
        let prompt = """
        Analyze the conversational function of this Javanese text: "\(text)"
        
        Explain its function in conversation:
        - What role does this phrase play in communication?
        - How does it function in social interaction?
        - What is its purpose in conversation?
        
        Respond with a clear description of its conversational function.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse
    }
    
    private func generateEquivalentExpressionWithFoundationModels(for text: String, session: LanguageModelSession) async throws -> String {
        // Use Apple's Foundation Models for equivalent analysis
        let prompt = """
        Find equivalent expressions for this Javanese text: "\(text)"
        
        Provide equivalent expressions in Indonesian:
        - What would be the Indonesian equivalent?
        - How would you say this in Indonesian?
        - What's the closest Indonesian phrase?
        
        Respond with the Indonesian equivalent.
        """
        
        let response = try await session.respond(to: prompt)
        let translatedResponse = await translateToIndonesian(response.description)
        return translatedResponse
    }
    
}
