//
//  WordByWordView.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import SwiftUI
import NaturalLanguage

struct WordByWordView: View {
    @ObservedObject var translationService: TranslationService
    @State private var inputText = ""
    @State private var selectedLevel: JavaneseLevel = .kramaalus
    @State private var wordTranslations: [WordTranslation] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "textformat.abc")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                    
                    Text("Terjemahan Kata per Kata")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Lihat terjemahan setiap kata")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Language Level Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tingkat Bahasa Jawa")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Tingkat Bahasa", selection: $selectedLevel) {
                        ForEach(JavaneseLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Teks Indonesia")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 80)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Analyze Button
                Button(action: analyzeWords) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Analisis Kata")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .mint]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                
                // Word Translations List
                if !wordTranslations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hasil Analisis Kata")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(wordTranslations, id: \.originalWord) { wordTranslation in
                                    WordTranslationCard(
                                        wordTranslation: wordTranslation,
                                        selectedLevel: selectedLevel
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if !inputText.isEmpty {
                    VStack {
                        Image(systemName: "textformat.abc")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Tekan 'Analisis Kata' untuk melihat terjemahan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Kata per Kata")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedLevel) { _ in
            if !wordTranslations.isEmpty {
                analyzeWords()
            }
        }
    }
    
    private func analyzeWords() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Tokenize the sentence into words using Natural Language framework
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = inputText
        
        var translations: [WordTranslation] = []
        
        tokenizer.enumerateTokens(in: inputText.startIndex..<inputText.endIndex) { range, _ in
            let word = String(inputText[range])
            let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
            
            let translation = translationService.translateWord(cleanWord, to: selectedLevel)
            
            let wordTranslation = WordTranslation(
                originalWord: word,
                cleanWord: cleanWord,
                translation: translation,
                hasTranslation: translation != nil
            )
            
            translations.append(wordTranslation)
            return true
        }
        
        wordTranslations = translations
    }
}

struct WordTranslation: Identifiable {
    let id = UUID()
    let originalWord: String
    let cleanWord: String
    let translation: String?
    let hasTranslation: Bool
}

struct WordTranslationCard: View {
    let wordTranslation: WordTranslation
    let selectedLevel: JavaneseLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(wordTranslation.originalWord)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if wordTranslation.hasTranslation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            if let translation = wordTranslation.translation {
                HStack {
                    Text("→")
                        .foregroundColor(.secondary)
                    Text(translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            } else {
                Text("Tidak ditemukan dalam kamus")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    wordTranslation.hasTranslation ? Color.green.opacity(0.3) : Color.orange.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    WordByWordView(translationService: TranslationService(dictionaryService: DictionaryService()))
}
