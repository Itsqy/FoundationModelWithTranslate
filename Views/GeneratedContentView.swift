//
//  GeneratedContentView.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import SwiftUI

struct GeneratedContentView: View {
    @StateObject private var aiService: AIGenerationService
    @State private var inputText = ""
    @State private var showErrorAlert = false

    private let translator: SystemTranslator? = {
        if #available(iOS 18, *) {
            return SystemTranslator()
        } else {
            return nil
        }
    }()

    init(dictionaryService: DictionaryService) {
        _aiService = StateObject(
            wrappedValue: AIGenerationService(
                dictionaryService: dictionaryService,
                translator: GeneratedContentView.translatorForCurrentPlatform
            )
        )
    }

    private static var translatorForCurrentPlatform: SystemTranslator? {
        if #available(iOS 18, *) {
            return SystemTranslator()
        } else {
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 🧠 header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.purple)
                    Text("AI Analisis Bahasa Jawa")
                        .font(.title2).bold()
                    Text("Analisis mendalam dengan AI on-device")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // ✍️ input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Teks Bahasa Jawa").font(.headline)
                    TextEditor(text: $inputText)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // ⚡ button
                Button(action: generateContent) {
                    HStack {
                        if aiService.isGenerating {
                            ProgressView()
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(aiService.isGenerating ? "Menganalisis..." : "Analisis dengan AI")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
                }
                .disabled(aiService.isGenerating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)

                // 📄 results
                if let content = aiService.generatedContent {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(content.meaning.literal)
                            Text(content.meaning.contextual)
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .navigationTitle("AI Analisis")
            .background(
                Group {
                    if #available(iOS 18, *), let t = self.translator {
                        TranslationHostView(translator: t)
                    } else {
                        Color.clear
                    }
                }
            )
        }
    }

    private func generateContent() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Task { await aiService.generateContent(for: text) }
    }
}

#Preview {
    GeneratedContentView(dictionaryService: DictionaryService())
}
