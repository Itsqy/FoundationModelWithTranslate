# Apple Foundation Models Integration Guide

This guide explains how to use Apple's Foundation Models for Javanese-Indonesian translation in your iOS app.

## Overview

Apple Foundation Models provide powerful cloud-based AI capabilities that can be integrated into iOS applications. This project demonstrates how to use these models for Javanese-Indonesian translation with cultural context awareness.

## Prerequisites

### System Requirements
- **iOS 18.0+** or **macOS 15.0+**
- **Xcode 16.0+**
- **Swift 5.9+**

### Apple Developer Account
- Active Apple Developer Program membership
- Access to Apple Foundation Models (when available)
- Proper entitlements configured

## Integration Steps

### 1. Enable Foundation Models Framework

Add the Foundation Models framework to your project:

```swift
import FoundationModels
```

### 2. Configure Entitlements

Add the following entitlements to your `entitlements` file:

```xml
<key>com.apple.developer.foundation-models</key>
<true/>
<key>com.apple.developer.foundation-models.cloud</key>
<true/>
```

### 3. Request Permissions

Request user permission to use Foundation Models:

```swift
import FoundationModels

// Request permission to use Foundation Models
Task {
    do {
        let permission = try await FoundationModels.requestPermission()
        if permission == .granted {
            // Foundation Models are available
        }
    } catch {
        // Handle permission error
    }
}
```

## Implementation

### Basic Translation Service

```swift
import FoundationModels

class AppleFoundationTranslationService {
    private let foundationModels = FoundationModels.shared
    
    func translateText(_ text: String, from: Language, to: Language) async throws -> String {
        let request = TranslationRequest(
            text: text,
            sourceLanguage: from,
            targetLanguage: to,
            model: .cloudLarge, // Use cloud-based model
            options: TranslationOptions(
                preserveCulturalContext: true,
                maintainFormalityLevel: true
            )
        )
        
        let response = try await foundationModels.translate(request)
        return response.translatedText
    }
}
```

### Javanese-Specific Translation

```swift
extension AppleFoundationTranslationService {
    func translateJavaneseToIndonesian(
        _ text: String,
        register: JavaneseRegister
    ) async throws -> String {
        let request = TranslationRequest(
            text: text,
            sourceLanguage: .javanese,
            targetLanguage: .indonesian,
            model: .cloudLarge,
            options: TranslationOptions(
                preserveCulturalContext: true,
                maintainFormalityLevel: true,
                customInstructions: createJavaneseInstructions(for: register)
            )
        )
        
        let response = try await foundationModels.translate(request)
        return response.translatedText
    }
    
    private func createJavaneseInstructions(for register: JavaneseRegister) -> String {
        switch register {
        case .ngoko:
            return "Translate using informal, everyday Javanese register"
        case .kramaAlus:
            return "Translate using polite, respectful Javanese register"
        case .kramaInggil:
            return "Translate using very formal, high respect Javanese register"
        }
    }
}
```

### Content Generation

```swift
extension AppleFoundationTranslationService {
    func generateContent(
        prompt: String,
        context: String = ""
    ) async throws -> String {
        let request = ContentGenerationRequest(
            prompt: prompt,
            context: context,
            model: .cloudLarge,
            options: ContentGenerationOptions(
                language: .javanese,
                culturalContext: .indonesian,
                formalityLevel: .appropriate
            )
        )
        
        let response = try await foundationModels.generateContent(request)
        return response.content
    }
}
```

## Advanced Features

### Streaming Translation

```swift
func streamTranslation(
    _ text: String,
    from: Language,
    to: Language
) async throws -> AsyncThrowingStream<String, Error> {
    return AsyncThrowingStream { continuation in
        Task {
            do {
                let request = TranslationRequest(
                    text: text,
                    sourceLanguage: from,
                    targetLanguage: to,
                    model: .cloudLarge,
                    streaming: true
                )
                
                for try await chunk in foundationModels.streamTranslate(request) {
                    continuation.yield(chunk.text)
                }
                
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
```

### Batch Translation

```swift
func translateBatch(
    _ texts: [String],
    from: Language,
    to: Language
) async throws -> [String] {
    let request = BatchTranslationRequest(
        texts: texts,
        sourceLanguage: from,
        targetLanguage: to,
        model: .cloudLarge
    )
    
    let response = try await foundationModels.translateBatch(request)
    return response.translations
}
```

## Error Handling

### Common Error Types

```swift
enum FoundationModelError: LocalizedError {
    case permissionDenied
    case modelUnavailable
    case quotaExceeded
    case networkError
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Foundation Models permission not granted"
        case .modelUnavailable:
            return "Requested model is not available"
        case .quotaExceeded:
            return "API quota exceeded"
        case .networkError:
            return "Network connection error"
        case .invalidInput:
            return "Invalid input text"
        }
    }
}
```

### Error Handling Implementation

```swift
func handleTranslationError(_ error: Error) {
    if let foundationError = error as? FoundationModelError {
        switch foundationError {
        case .permissionDenied:
            // Request permission again
            requestFoundationModelPermission()
        case .quotaExceeded:
            // Show quota exceeded message
            showQuotaExceededAlert()
        case .modelUnavailable:
            // Fallback to alternative model
            fallbackToAlternativeModel()
        default:
            // Show generic error
            showErrorAlert(foundationError.localizedDescription)
        }
    } else {
        // Handle other errors
        showErrorAlert(error.localizedDescription)
    }
}
```

## Performance Optimization

### Caching Strategy

```swift
class TranslationCache {
    private var cache: [String: String] = [:]
    private let maxCacheSize = 1000
    
    func getCachedTranslation(for text: String) -> String? {
        return cache[text]
    }
    
    func cacheTranslation(_ text: String, translation: String) {
        if cache.count >= maxCacheSize {
            // Remove oldest entries
            let keysToRemove = Array(cache.keys.prefix(cache.count - maxCacheSize + 1))
            keysToRemove.forEach { cache.removeValue(forKey: $0) }
        }
        
        cache[text] = translation
    }
}
```

### Request Optimization

```swift
struct OptimizedTranslationRequest {
    let text: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let model: FoundationModel
    let options: TranslationOptions
    
    // Optimize request based on text length and complexity
    var optimizedModel: FoundationModel {
        if text.count < 50 {
            return .cloudSmall
        } else if text.count < 200 {
            return .cloudMedium
        } else {
            return .cloudLarge
        }
    }
    
    // Batch similar requests
    static func batchRequests(_ requests: [OptimizedTranslationRequest]) -> [OptimizedTranslationRequest] {
        // Group requests by language pair and model
        let grouped = Dictionary(grouping: requests) { request in
            "\(request.sourceLanguage)-\(request.targetLanguage)-\(request.model)"
        }
        
        return grouped.values.flatMap { $0 }
    }
}
```

## Testing

### Unit Tests

```swift
import XCTest
@testable import YourApp

class AppleFoundationTranslationTests: XCTestCase {
    var translationService: AppleFoundationTranslationService!
    
    override func setUp() {
        super.setUp()
        translationService = AppleFoundationTranslationService()
    }
    
    func testJavaneseToIndonesianTranslation() async throws {
        let result = try await translationService.translateJavaneseToIndonesian(
            "Mangan",
            register: .ngoko
        )
        
        XCTAssertEqual(result, "Makan")
    }
    
    func testRegisterSpecificTranslation() async throws {
        let ngokoResult = try await translationService.translateJavaneseToIndonesian(
            "Mangan",
            register: .ngoko
        )
        
        let kramaResult = try await translationService.translateJavaneseToIndonesian(
            "Nedha",
            register: .kramaAlus
        )
        
        XCTAssertEqual(ngokoResult, "Makan")
        XCTAssertEqual(kramaResult, "Makan")
    }
}
```

### Integration Tests

```swift
class AppleFoundationIntegrationTests: XCTestCase {
    func testEndToEndTranslation() async throws {
        let translator = JavaneseTranslator()
        
        let result = try await translator.translateWithAppleFoundation(
            "Aku arep mangan nasi",
            direction: .javaneseToIndonesian,
            targetRegister: .ngoko
        )
        
        XCTAssertFalse(result.translatedText.isEmpty)
        XCTAssertEqual(result.method, .cloudModel)
        XCTAssertGreaterThan(result.confidence, 0.8)
    }
}
```

## Best Practices

### 1. Model Selection

```swift
func selectOptimalModel(for text: String, complexity: TranslationComplexity) -> FoundationModel {
    switch (text.count, complexity) {
    case (0..<50, .simple):
        return .cloudSmall
    case (50..<200, .medium):
        return .cloudMedium
    case (200..., .complex):
        return .cloudLarge
    default:
        return .cloudMedium
    }
}
```

### 2. Error Recovery

```swift
func translateWithFallback(_ text: String) async throws -> String {
    do {
        return try await appleFoundationService.translate(text)
    } catch FoundationModelError.modelUnavailable {
        // Fallback to OpenAI
        return try await openAIService.translate(text)
    } catch FoundationModelError.quotaExceeded {
        // Fallback to dictionary
        return try await dictionaryService.translate(text)
    }
}
```

### 3. Performance Monitoring

```swift
class TranslationPerformanceMonitor {
    private var metrics: [String: TimeInterval] = [:]
    
    func recordTranslationTime(_ method: String, duration: TimeInterval) {
        metrics[method] = duration
    }
    
    func getAverageTranslationTime() -> TimeInterval {
        let total = metrics.values.reduce(0, +)
        return total / Double(metrics.count)
    }
}
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure entitlements are properly configured
   - Request permission at runtime
   - Check Apple Developer account status

2. **Model Unavailable**
   - Check iOS/macOS version compatibility
   - Verify model availability in your region
   - Use fallback models

3. **Performance Issues**
   - Monitor request frequency
   - Implement caching
   - Use appropriate model sizes

4. **Quota Exceeded**
   - Implement rate limiting
   - Use fallback services
   - Monitor usage patterns

## Future Enhancements

### Planned Features
- **On-Device Models**: Local processing for privacy
- **Custom Models**: Fine-tuned models for specific domains
- **Real-time Translation**: Live conversation translation
- **Multimodal Support**: Text, voice, and image translation

### API Evolution
- **Streaming Support**: Real-time translation streaming
- **Batch Processing**: Multiple text translation
- **Custom Instructions**: Domain-specific translation rules
- **Quality Metrics**: Translation confidence and quality scores

## Resources

- [Apple Foundation Models Documentation](https://developer.apple.com/documentation/foundationmodels)
- [iOS 18 Release Notes](https://developer.apple.com/ios/)
- [SwiftUI Integration Guide](https://developer.apple.com/documentation/swiftui)
- [Privacy and Security Best Practices](https://developer.apple.com/privacy/)

## Support

For technical support and questions:
- Apple Developer Forums
- Foundation Models Documentation
- iOS Developer Community
- Apple Developer Support
