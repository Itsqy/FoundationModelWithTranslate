import SwiftUI

struct ContentView: View {
    @StateObject private var translator = JavaneseTranslator()
    @State private var sourceText: String = ""
    @State private var isTranslating = false
    @State private var translationDirection: TranslationDirection = .javaneseToIndonesian
    @State private var selectedRegister: JavaneseRegister = .ngoko
    @State private var selectedMethod: TranslationMethod = .hybrid
    @State private var showingContentGenerator = false
    
    enum TranslationDirection: String, CaseIterable {
        case javaneseToIndonesian = "Jawa → Indonesia"
        case indonesianToJavanese = "Indonesia → Jawa"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Translation direction picker
                Picker("Direction", selection: $translationDirection) {
                    ForEach(TranslationDirection.allCases, id: \.self) { direction in
                        Text(direction.rawValue).tag(direction)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Register picker
                Picker("Register", selection: $selectedRegister) {
                    ForEach(JavaneseRegister.allCases, id: \.self) { register in
                        Text(register.displayName).tag(register)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                
                // Translation method picker
                Picker("Method", selection: $selectedMethod) {
                    ForEach(TranslationMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                
                // Input field
                TextField(
                    translationDirection == .javaneseToIndonesian ? 
                    "Masukkan kalimat Bahasa Jawa…" : 
                    "Masukkan kalimat Bahasa Indonesia…", 
                    text: $sourceText,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.horizontal)

                // Action buttons
                HStack(spacing: 12) {
                    // Translate button
                    Button(action: translateText) {
                        HStack {
                            if isTranslating {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.left.arrow.right")
                            }
                            
                            Text(isTranslating ? "Menerjemahkan..." : "Terjemahkan")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(sourceText.isEmpty || isTranslating ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(sourceText.isEmpty || isTranslating)
                    
                    // Content generator button
                    Button(action: { showingContentGenerator = true }) {
                        Image(systemName: "sparkles")
                            .frame(width: 44, height: 44)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)

                // Translation result
                if let result = translator.translation {
                    ScrollView {
                        TranslationResultView(translation: result)
                    }
                } else if isTranslating {
                    VStack(spacing: 12) {
                        ProgressView("Menunggu respon model…")
                        
                        if selectedMethod == .hybrid {
                            Text("Mencoba kamus lokal terlebih dahulu, kemudian Apple Foundation Models...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // Error display
                if let error = translator.error {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        Text(error.localizedDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Javanese Translator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        clearTranslation()
                    }
                }
            }
        }
        .task {
            translator.prewarm()
        }
        .sheet(isPresented: $showingContentGenerator) {
            ContentGenerationView()
        }
    }
    
    private func translateText() {
        guard !sourceText.isEmpty else { return }
        
        isTranslating = true
        translator.clearTranslation()
        
        Task {
            do {
                if translationDirection == .javaneseToIndonesian {
                    try await translator.translateFromJavanese(
                        sourceText,
                        targetRegister: selectedRegister,
                        method: selectedMethod
                    )
                } else {
                    try await translator.translateToJavanese(
                        sourceText,
                        targetRegister: selectedRegister,
                        method: selectedMethod
                    )
                }
            } catch {
                // Error is handled by the translator's @Published error property
            }
            
            await MainActor.run {
                isTranslating = false
            }
        }
    }
    
    private func clearTranslation() {
        translator.clearTranslation()
        sourceText = ""
    }
}
