import SwiftUI

struct ContentGenerationView: View {
    @StateObject private var translator = JavaneseTranslator()
    @State private var prompt: String = ""
    @State private var context: String = ""
    @State private var generatedContent: String = ""
    @State private var isGenerating = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content Generation")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Generate content using Javanese-Indonesian cultural context")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Input section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prompt")
                        .font(.headline)
                    
                    TextField(
                        "Describe what content you want to generate...",
                        text: $prompt,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                }
                
                // Context section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Context (Optional)")
                        .font(.headline)
                    
                    TextField(
                        "Provide additional context...",
                        text: $context,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                }
                
                // Generate button
                Button(action: generateContent) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        
                        Text(isGenerating ? "Generating..." : "Generate Content")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(prompt.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(prompt.isEmpty || isGenerating)
                
                // Generated content
                if !generatedContent.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Generated Content")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Copy") {
                                UIPasteboard.general.string = generatedContent
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ScrollView {
                            Text(generatedContent)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 300)
                    }
                }
                
                // Error display
                if let error = error {
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
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Content Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateContent() {
        guard !prompt.isEmpty else { return }
        
        isGenerating = true
        error = nil
        generatedContent = ""
        
        Task {
            do {
                let content = try await translator.generateContent(
                    prompt: prompt,
                    context: context
                )
                
                await MainActor.run {
                    self.generatedContent = content
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isGenerating = false
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ContentGenerationView()
    }
}
