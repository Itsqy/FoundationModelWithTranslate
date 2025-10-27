//
//  ReverseNgokoTranslationService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/27/25.
//


//
//  ReverseNgokoTranslationService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/27/25.
//

import Foundation
import NaturalLanguage
import Combine

class ReverseNgokoTranslationService: ObservableObject {
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
            // Tokenize Javanese sentence
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = sentence

            var translatedWords: [String] = []

            tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { range, _ in
                let word = String(sentence[range])
                let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)

                if let translation = dictionaryService.translateFromNgoko(cleanWord) {
                    translatedWords.append(translation)
                } else {
                    translatedWords.append(word) // keep original if not found
                }
                return true
            }

            // Construct Indonesian sentence
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
        let sentence = words.joined(separator: " ")
        let formatted = sentence.prefix(1).capitalized + sentence.dropFirst()
        return formatted
    }

    func translateWord(_ word: String) -> String? {
        return dictionaryService.translateFromNgoko(word)
    }
}
