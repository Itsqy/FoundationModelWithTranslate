import SwiftUI
import FoundationModels

struct ContentView: View {
    @State private var translator = JavaneseTranslator(glossaryTool: GlossaryLookupTool())
    @State private var sourceText: String = ""
    @State private var isTranslating = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Masukkan kalimat Bahasa Indonesia…", text: $sourceText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button(action: {
                    Task {
                        isTranslating = true
                        do {
                            try await translator.streamTranslate(
                                source: sourceText,
                                register: "Ngoko Alus"
                            )
                        } catch {
                            translator.error = error
                        }
                        isTranslating = false
                    }
                }) {
                    Text(isTranslating ? "Menerjemahkan..." : "Terjemahkan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(sourceText.isEmpty || isTranslating)

                if let result = translator.translation {
                    ScrollView {
                        TranslationView(result: result)
                    }
                } else if isTranslating {
                    ProgressView("Menunggu respon model…")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Javanese Translator")
        }
        .task {
            translator.prewarm()
        }
    }
}
