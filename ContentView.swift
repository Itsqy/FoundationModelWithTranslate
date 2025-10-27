//
//  ContentView.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dictionaryService: DictionaryService
    let reverseService: ReverseTranslationService
    @StateObject private var translationService: TranslationService
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var selectedLevel: JavaneseLevel = .kramaalus
    @State private var showingDictionary = false
    
    init() {
        let dictService = DictionaryService()
        _dictionaryService = StateObject(wrappedValue: dictService)
        reverseService = ReverseTranslationService(dictionaryService: dictService)
        _translationService = StateObject(wrappedValue: TranslationService(dictionaryService: dictService))
    }
    
    var body: some View {
        TabView {
            // Main Translation View
            NavigationView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "globe.asia.australia")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Bahasa Indonesia → Jawa")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Terjemahkan ke Bahasa Jawa")
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
                    
                    // Translate Button
                    Button(action: translateText) {
                        HStack {
                            if translationService.isTranslating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            Text(translationService.isTranslating ? "Menerjemahkan..." : "Terjemahkan")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(translationService.isTranslating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal)
                    
                    // Output Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hasil Terjemahan")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ScrollView {
                            Text(translatedText.isEmpty ? "Hasil terjemahan akan muncul di sini..." : translatedText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .foregroundColor(translatedText.isEmpty ? .secondary : .primary)
                        }
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Dictionary Button
                    Button(action: { showingDictionary = true }) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Kamus")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .navigationTitle("Terjemah Jawa")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingDictionary) {
                    DictionaryView(dictionaryService: dictionaryService)
                }
            }
            .tabItem {
                Image(systemName: "globe.asia.australia")
                Text("Terjemah")
            }
            
            // Word by Word Analysis
            WordByWordView(translationService: translationService)
                .tabItem {
                    Image(systemName: "textformat.abc")
                    Text("Kata per Kata")
                }
            
            // AI Generated Content
            GeneratedContentView(dictionaryService: dictionaryService)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Analisis")
                }
        }
        .onAppear {
            if dictionaryService.dictionaryEntries.isEmpty {
                dictionaryService.loadDictionary()
            }
        }
    }
    
    private func translateText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {
            let result = await translationService.translateSentence(inputText, to: selectedLevel)
            await MainActor.run {
                translatedText = result
            }
        }
    }
}

#Preview {
    ContentView()
}
