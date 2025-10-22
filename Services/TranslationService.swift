//
//  TranslationService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import Foundation
import NaturalLanguage
import Combine

class TranslationService: ObservableObject {
    @Published var isTranslating = false
    @Published var errorMessage: String?
    
    private let dictionaryService: DictionaryService
        
    init(dictionaryService: DictionaryService) {
        self.dictionaryService = dictionaryService
    }
    
    func translateSentence(_ sentence: String, to level: JavaneseLevel) async -> String {
        await MainActor.run {
            isTranslating = true
            errorMessage = nil
        }
        
        do {
            // Tokenize the sentence into words
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = sentence
            
            var translatedWords: [String] = []
            var untranslatedWords: [String] = []
            
            tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { range, _ in
                let word = String(sentence[range])
                let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
                
                if let translation = dictionaryService.translateWord(cleanWord, to: level) {
                    translatedWords.append(translation)
                } else {
                    untranslatedWords.append(word)
                    translatedWords.append(word) // Keep original if no translation found
                }
                return true
            }
            
            // Use Foundation's Natural Language framework for sentence construction
            let translatedSentence = constructJavaneseSentence(from: translatedWords, originalLevel: level)
            
            await MainActor.run {
                isTranslating = false
            }
            
            return translatedSentence
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Translation failed: \(error.localizedDescription)"
                self.isTranslating = false
            }
            return sentence
        }
    }
    
    private func constructJavaneseSentence(from words: [String], originalLevel: JavaneseLevel) -> String {
        // Apply Javanese grammar rules using Foundation's Natural Language framework
        let sentence = words.joined(separator: " ")
        
        // Use NLLanguageRecognizer to help with language processing
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(sentence)
        
        // Apply Javanese-specific grammar adjustments
        var adjustedSentence = sentence
        
        // Basic Javanese grammar adjustments
        switch originalLevel {
        case .kramaalus, .kramainggil:
            // For formal Javanese, ensure proper sentence structure
            adjustedSentence = adjustFormalJavanese(sentence)
        case .ngoko:
            // For informal Javanese, keep more natural flow
            adjustedSentence = adjustInformalJavanese(sentence)
        }
        
        return adjustedSentence
    }
    
    private func adjustFormalJavanese(_ sentence: String) -> String {
        // Apply formal Javanese grammar rules
        var adjusted = sentence
        
        // Add common formal prefixes/suffixes if needed
        // This is a simplified version - in a real app, you'd have more sophisticated grammar rules
        
        return adjusted
    }
    
    private func adjustInformalJavanese(_ sentence: String) -> String {
        // Apply informal Javanese grammar rules
        var adjusted = sentence
        
        // Add common informal adjustments
        // This is a simplified version - in a real app, you'd have more sophisticated grammar rules
        
        return adjusted
    }
    
    func translateWord(_ word: String, to level: JavaneseLevel) -> String? {
        return dictionaryService.translateWord(word, to: level)
    }
}
