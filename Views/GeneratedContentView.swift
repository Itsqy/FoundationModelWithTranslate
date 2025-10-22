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
    @State private var showingContent = false
    
    init(dictionaryService: DictionaryService) {
        _aiService = StateObject(wrappedValue: AIGenerationService(dictionaryService: dictionaryService))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.purple)
                    
                    Text("AI Analisis Bahasa Jawa")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Analisis mendalam dengan AI on-device")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Teks Bahasa Jawa")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Generate Button
                Button(action: generateContent) {
                    HStack {
                        if aiService.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(aiService.isGenerating ? "Menganalisis..." : "Analisis dengan AI")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(aiService.isGenerating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                
                // Generated Content
                if let content = aiService.generatedContent {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Meaning Section
                            ContentSection(
                                title: "Makna",
                                icon: "lightbulb.fill",
                                color: .orange
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(content.meaning.literal)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(content.meaning.contextual)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            // Pronunciation Section
                            ContentSection(
                                title: "Cara Pengucapan",
                                icon: "speaker.wave.2.fill",
                                color: .blue
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(content.pronunciation.phonetic)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    Text(content.pronunciation.intonation)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            // Usage Section
                            ContentSection(
                                title: "Kapan digunakan (situasi penggunaan)",
                                icon: "calendar.badge.clock",
                                color: .green
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(content.usage.situations, id: \.self) { situation in
                                        HStack(alignment: .top) {
                                            Text("•")
                                                .foregroundColor(.green)
                                                .fontWeight(.bold)
                                            Text(situation)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    
                                    if !content.usage.examples.isEmpty {
                                        Text("Contoh situasi:")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.top, 8)
                                        
                                        ForEach(content.usage.examples, id: \.self) { example in
                                            Text(example)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                            }
                            
                            // Conversation Function Section
                            ContentSection(
                                title: "Fungsi Dalam Percakapan",
                                icon: "bubble.left.and.bubble.right.fill",
                                color: .red
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(content.conversationFunction.function)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(content.conversationFunction.equivalent)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if aiService.isGenerating {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("AI sedang menganalisis teks...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Masukkan teks Bahasa Jawa untuk dianalisis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("AI Analisis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateContent() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {
            await aiService.generateContent(for: inputText)
        }
    }
}

struct ContentSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    GeneratedContentView(dictionaryService: DictionaryService())
}
