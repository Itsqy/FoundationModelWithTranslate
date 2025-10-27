//
//  ReverseTranslationService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/27/25.
//

import Foundation
import NaturalLanguage
import Combine

class ReverseTranslationService: ObservableObject {
    @Published var isTranslating = false
    @Published var errorMessage: String?

    private let dictionaryService: DictionaryService

    init(dictionaryService: DictionaryService) {
        self.dictionaryService = dictionaryService
    }

    func translateSentence(_ sentence: String) async -> String {
        await MainActor.run {
            isTranslating = true
            errorMessage = nil
        }

        do {
            // Tokenize the Javanese sentence into words
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = sentence

            var translatedWords: [String] = []
            var untranslatedWords: [String] = []

            tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { range, _ in
                let word = String(sentence[range])
                let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)

                if let translation = dictionaryService.translateFromJavanese(cleanWord) {
                    translatedWords.append(translation)
                } else {
                    untranslatedWords.append(word)
                    translatedWords.append(word) // Keep original word if not found
                }
                return true
            }

            // Construct an Indonesian sentence
            let translatedSentence = constructIndonesianSentence(from: translatedWords)

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

    private func constructIndonesianSentence(from words: [String]) -> String {
        // Join words back into a sentence
        let sentence = words.joined(separator: " ")
        
        // Basic normalization: capitalize the first letter
        let formatted = sentence.prefix(1).capitalized + sentence.dropFirst()
        return formatted
    }

    func translateWord(_ word: String) -> String? {
        return dictionaryService.translateFromJavanese(word)
    }
}
