import Foundation
import SwiftUI
import Combine
import Translation

@available(iOS 18, *)
@MainActor
final class SystemTranslator: ObservableObject {

    struct Request {
        let text: String
        let cont: CheckedContinuation<String, Never>
    }

    let stream: AsyncStream<Request>
    private let continuation: AsyncStream<Request>.Continuation

    // 👉 Publish availability so callers can skip translation if unsupported
    @Published private(set) var isAvailable: Bool = true
    // store the last error if you want to display it
    @Published private(set) var lastError: Error?

    init() {
        var c: AsyncStream<Request>.Continuation!
        self.stream = AsyncStream<Request> { c = $0 }
        self.continuation = c
    }

    func translateToIndonesian(_ text: String) async -> String {
        await withCheckedContinuation { cont in
            continuation.yield(.init(text: text, cont: cont))
        }
    }

    // Internal: mark unavailable and flush a request with original text
    func markUnavailable(_ error: Error?) {
        isAvailable = false
        lastError = error
    }
}
