import SwiftUI
import Translation

@available(iOS 18, *)
struct TranslationHostView: View {
    @ObservedObject var translator: SystemTranslator

    var body: some View {
        let config = TranslationSession.Configuration(
            source: nil,
            target: .init(languageCode: .indonesian)
        )

        return Color.clear
            .translationTask(config) { session in
                // Try preparing models first
                do {
                    try await session.prepareTranslation()
                } catch {
                    // If it's the "not supported" error, mark unavailable and
                    // service the queue by returning originals (no more attempts).
                    if isUnsupported(error) {
                        translator.markUnavailable(error)
                        for await req in translator.stream {
                            req.cont.resume(returning: req.text) // return original
                        }
                        return
                    }
                    // For other errors, we won't mark permanently unavailable;
                    // we’ll still try to translate per request and fallback if needed.
                }

                // Normal translation loop
                for await req in translator.stream {
                    if !translator.isAvailable {
                        req.cont.resume(returning: req.text)
                        continue
                    }
                    do {
                        let response = try await session.translate(req.text)
                        req.cont.resume(returning: response.targetText)
                    } catch {
                        if isUnsupported(error) {
                            translator.markUnavailable(error)
                            req.cont.resume(returning: req.text)
                        } else {
                            // transient error → fallback only for this request
                            req.cont.resume(returning: req.text)
                        }
                    }
                }
            }
    }

    /// Detect TranslationErrorDomain Code=11
    private func isUnsupported(_ error: Error) -> Bool {
        let ns = error as NSError
        return ns.domain == "TranslationErrorDomain" && ns.code == 11
    }
}

#Preview {
    TranslationHostView(translator: .init())
}
