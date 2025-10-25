import Foundation
import FoundationModels

class JavaneseTranslator: ObservableObject {
    // MARK: - Published Properties
    @Published var translation: TranslationResult?
    @Published var isTranslating = false
    @Published var error: Error?
    @Published var streamingText = ""
    
    // MARK: - Services
    private let dictionaryService = DictionaryLookupService()
    private let appleFoundationService: AppleFoundationModelService
    
    // MARK: - Configuration
    private var preferredMethod: TranslationMethod = .hybrid
    private var fallbackToCloud = true
    
    init() {
        self.appleFoundationService = AppleFoundationModelService()
    }
    
    // MARK: - Public Translation Methods
    func translateFromJavanese(
        _ text: String,
        targetRegister: JavaneseRegister = .ngoko,
        method: TranslationMethod? = nil
    ) async throws -> TranslationResult {
        let startTime = Date()
        isTranslating = true
        error = nil
        
        defer {
            isTranslating = false
        }
        
        let translationMethod = method ?? preferredMethod
        
        do {
            let result = try await performTranslation(
                text: text,
                direction: .javaneseToIndonesian,
                targetRegister: targetRegister,
                method: translationMethod
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            let finalResult = TranslationResult(
                originalText: result.originalText,
                translatedText: result.translatedText,
                confidence: result.confidence,
                method: result.method,
                dictionaryMatches: result.dictionaryMatches,
                processingTime: processingTime
            )
            
            await MainActor.run {
                self.translation = finalResult
            }
            
            return finalResult
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    func translateToJavanese(
        _ text: String,
        targetRegister: JavaneseRegister = .ngoko,
        method: TranslationMethod? = nil
    ) async throws -> TranslationResult {
        let startTime = Date()
        isTranslating = true
        error = nil
        
        defer {
            isTranslating = false
        }
        
        let translationMethod = method ?? preferredMethod
        
        do {
            let result = try await performTranslation(
                text: text,
                direction: .indonesianToJavanese,
                targetRegister: targetRegister,
                method: translationMethod
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            let finalResult = TranslationResult(
                originalText: result.originalText,
                translatedText: result.translatedText,
                confidence: result.confidence,
                method: result.method,
                dictionaryMatches: result.dictionaryMatches,
                processingTime: processingTime
            )
            
            await MainActor.run {
                self.translation = finalResult
            }
            
            return finalResult
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    // MARK: - Streaming Translation Methods
    func streamTranslateFromJavanese(
        sourceJavanese: String,
        targetRegister: JavaneseRegister = .ngoko
    ) async throws {
        isTranslating = true
        streamingText = ""
        error = nil
        
        defer {
            isTranslating = false
        }
        
        do {
            // First try dictionary lookup for immediate results
            let dictionaryMatches = dictionaryService.translateFromJavanese(sourceJavanese, targetRegister: targetRegister)
            
            if !dictionaryMatches.isEmpty {
                let dictionaryResult = buildDictionaryResult(
                    originalText: sourceJavanese,
                    matches: dictionaryMatches,
                    direction: .javaneseToIndonesian
                )
                
                await MainActor.run {
                    self.translation = dictionaryResult
                }
            }
            
            // Then use cloud service for comprehensive translation
            if cloudService.isAvailable {
                let cloudResult = try await cloudService.translateFromJavanese(
                    sourceJavanese,
                    targetRegister: targetRegister,
                    useStreaming: true
                )
                
                await MainActor.run {
                    self.translation = cloudResult
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    func streamTranslate(
        source: String,
        register: JavaneseRegister = .ngoko
    ) async throws {
        isTranslating = true
        streamingText = ""
        error = nil
        
        defer {
            isTranslating = false
        }
        
        do {
            // First try dictionary lookup for immediate results
            let dictionaryMatches = dictionaryService.translateToJavanese(source, targetRegister: register)
            
            if !dictionaryMatches.isEmpty {
                let dictionaryResult = buildDictionaryResult(
                    originalText: source,
                    matches: dictionaryMatches,
                    direction: .indonesianToJavanese
                )
                
                await MainActor.run {
                    self.translation = dictionaryResult
                }
            }
            
            // Then use cloud service for comprehensive translation
            if cloudService.isAvailable {
                let cloudResult = try await cloudService.translateToJavanese(
                    source,
                    targetRegister: register,
                    useStreaming: true
                )
                
                await MainActor.run {
                    self.translation = cloudResult
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    // MARK: - Apple Foundation Models Translation
    func translateWithAppleFoundation(
        _ text: String,
        direction: TranslationDirection,
        targetRegister: JavaneseRegister = .ngoko
    ) async throws -> TranslationResult {
        let startTime = Date()
        isTranslating = true
        error = nil
        
        defer {
            isTranslating = false
        }
        
        do {
            let result: TranslationResult
            if direction == .javaneseToIndonesian {
                result = try await appleFoundationService.translateFromJavanese(
                    text,
                    targetRegister: targetRegister
                )
            } else {
                result = try await appleFoundationService.translateToJavanese(
                    text,
                    targetRegister: targetRegister
                )
            }
            
            let processingTime = Date().timeIntervalSince(startTime)
            let finalResult = TranslationResult(
                originalText: result.originalText,
                translatedText: result.translatedText,
                confidence: result.confidence,
                method: .cloudModel,
                dictionaryMatches: result.dictionaryMatches,
                processingTime: processingTime
            )
            
            await MainActor.run {
                self.translation = finalResult
            }
            
            return finalResult
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    // MARK: - Content Generation
    func generateContent(
        prompt: String,
        context: String = ""
    ) async throws -> String {
        guard appleFoundationService.isAvailable else {
            throw TranslationError.cloudServiceUnavailable
        }
        
        return try await appleFoundationService.generateContent(
            prompt: prompt,
            context: context
        )
    }
    
    // MARK: - Private Translation Logic
    private func performTranslation(
        text: String,
        direction: TranslationDirection,
        targetRegister: JavaneseRegister,
        method: TranslationMethod
    ) async throws -> TranslationResult {
        switch method {
        case .dictionary:
            return try await performDictionaryTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
        case .appleFoundation:
            return try await performAppleFoundationTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
        case .hybrid:
            return try await performHybridTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
        case .cloudModel:
            // Redirect to Apple Foundation Models
            return try await performAppleFoundationTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
        }
    }
    
    private func performDictionaryTranslation(
        text: String,
        direction: TranslationDirection,
        targetRegister: JavaneseRegister
    ) async throws -> TranslationResult {
        let matches: [DictionaryMatch]
        
        if direction == .javaneseToIndonesian {
            matches = dictionaryService.translateFromJavanese(text, targetRegister: targetRegister)
        } else {
            matches = dictionaryService.translateToJavanese(text, targetRegister: targetRegister)
        }
        
        if matches.isEmpty {
            throw TranslationError.invalidInput
        }
        
        let translatedText = matches.map { $0.indonesian }.joined(separator: " ")
        let averageConfidence = matches.map { $0.confidence }.reduce(0, +) / Double(matches.count)
        
        return TranslationResult(
            originalText: text,
            translatedText: translatedText,
            confidence: averageConfidence,
            method: .dictionary,
            dictionaryMatches: matches,
            processingTime: 0.1 // Fast dictionary lookup
        )
    }
    
    
    private func performAppleFoundationTranslation(
        text: String,
        direction: TranslationDirection,
        targetRegister: JavaneseRegister
    ) async throws -> TranslationResult {
        guard appleFoundationService.isAvailable else {
            throw TranslationError.cloudServiceUnavailable
        }
        
        if direction == .javaneseToIndonesian {
            return try await appleFoundationService.translateFromJavanese(text, targetRegister: targetRegister)
        } else {
            return try await appleFoundationService.translateToJavanese(text, targetRegister: targetRegister)
        }
    }
    
    private func performHybridTranslation(
        text: String,
        direction: TranslationDirection,
        targetRegister: JavaneseRegister
    ) async throws -> TranslationResult {
        // First try dictionary
        do {
            let dictionaryResult = try await performDictionaryTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
            
            // If dictionary has high confidence, use it
            if dictionaryResult.confidence > 0.8 {
                return dictionaryResult
            }
        } catch {
            // Dictionary failed, continue to Apple Foundation
        }
        
        // Try Apple Foundation Models
        if appleFoundationService.isAvailable {
            return try await performAppleFoundationTranslation(
                text: text,
                direction: direction,
                targetRegister: targetRegister
            )
        }
        
        throw TranslationError.invalidInput
    }
    
    private func buildDictionaryResult(
        originalText: String,
        matches: [DictionaryMatch],
        direction: TranslationDirection
    ) -> TranslationResult {
        let translatedText = matches.map { match in
            direction == .javaneseToIndonesian ? match.indonesian : match.javanese
        }.joined(separator: " ")
        
        let averageConfidence = matches.map { $0.confidence }.reduce(0, +) / Double(matches.count)
        
        return TranslationResult(
            originalText: originalText,
            translatedText: translatedText,
            confidence: averageConfidence,
            method: .dictionary,
            dictionaryMatches: matches,
            processingTime: 0.1
        )
    }
    
    // MARK: - Configuration Methods
    func setPreferredMethod(_ method: TranslationMethod) {
        preferredMethod = method
    }
    
    func setFallbackToCloud(_ enabled: Bool) {
        fallbackToCloud = enabled
    }
    
    // MARK: - Utility Methods
    func prewarm() {
        // Preload dictionary and check cloud service availability
        Task {
            await dictionaryService.objectWillChange.send()
        }
    }
    
    func clearTranslation() {
        translation = nil
        streamingText = ""
        error = nil
    }
    
    func getTranslationStats() -> (dictionaryLoaded: Bool, appleFoundationAvailable: Bool, preferredMethod: TranslationMethod) {
        return (
            dictionaryLoaded: dictionaryService.isLoaded,
            appleFoundationAvailable: appleFoundationService.isAvailable,
            preferredMethod: preferredMethod
        )
    }
}