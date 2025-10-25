import Foundation
import FoundationModels

// MARK: - Apple Foundation Models Demo
// This demonstrates how to use Apple's Foundation Models for Javanese-Indonesian translation

class AppleFoundationDemo {
    private let translator = JavaneseTranslator()
    
    func runAppleFoundationDemo() async {
        print("🍎 Apple Foundation Models Demo")
        print("==============================\n")
        
        // Demo 1: Basic Apple Foundation Translation
        await demoBasicAppleFoundationTranslation()
        
        // Demo 2: Register-Specific Translation
        await demoRegisterSpecificTranslation()
        
        // Demo 3: Content Generation with Apple Foundation
        await demoAppleFoundationContentGeneration()
        
        // Demo 4: Performance Comparison
        await demoPerformanceComparison()
    }
    
    private func demoBasicAppleFoundationTranslation() async {
        print("📱 Basic Apple Foundation Translation")
        print("------------------------------------")
        
        let testPhrases = [
            "Aku arep mangan nasi karo kulawarga",
            "Kula badhe nedha sekul kaliyan kulawarga",
            "Kula badhe dhahar sekul kaliyan kulawarga"
        ]
        
        for phrase in testPhrases {
            do {
                let result = try await translator.translateWithAppleFoundation(
                    phrase,
                    direction: .javaneseToIndonesian,
                    targetRegister: .ngoko
                )
                
                print("✅ \(phrase)")
                print("   → \(result.translatedText)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Method: \(result.method.rawValue)")
                print("   Processing Time: \(String(format: "%.2f", result.processingTime))s")
                print()
            } catch {
                print("❌ Apple Foundation translation failed: \(error.localizedDescription)")
                print("   (This is expected if Apple Foundation Models are not available)")
                print()
            }
        }
    }
    
    private func demoRegisterSpecificTranslation() async {
        print("🎭 Register-Specific Translation")
        print("--------------------------------")
        
        let testPhrases = [
            ("Mangan", "Ngoko register"),
            ("Nedha", "Krama Alus register"),
            ("Dhahar", "Krama Inggil register")
        ]
        
        for (phrase, description) in testPhrases {
            do {
                let result = try await translator.translateWithAppleFoundation(
                    phrase,
                    direction: .javaneseToIndonesian,
                    targetRegister: .ngoko
                )
                
                print("✅ \(phrase) (\(description))")
                print("   → \(result.translatedText)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Method: \(result.method.rawValue)")
                print()
            } catch {
                print("❌ Register-specific translation failed: \(error.localizedDescription)")
                print()
            }
        }
    }
    
    private func demoAppleFoundationContentGeneration() async {
        print("✨ Apple Foundation Content Generation")
        print("-------------------------------------")
        
        let prompts = [
            "Write a short story about a Javanese family dinner",
            "Explain the difference between Ngoko and Krama registers",
            "Create a traditional Javanese greeting"
        ]
        
        for prompt in prompts {
            do {
                let content = try await translator.generateContent(
                    prompt: prompt,
                    context: "Provide both Javanese and Indonesian versions"
                )
                
                print("✅ Prompt: \(prompt)")
                print("Generated Content:")
                print(content)
                print()
            } catch {
                print("❌ Content generation failed: \(error.localizedDescription)")
                print("   (This is expected if Apple Foundation Models are not available)")
                print()
            }
        }
    }
    
    private func demoPerformanceComparison() async {
        print("⚡ Performance Comparison")
        print("------------------------\n")
        
        let testPhrase = "Aku arep mangan nasi karo kulawarga"
        let iterations = 5
        
        // Dictionary Performance
        print("📚 Dictionary Performance:")
        let dictionaryStart = Date()
        
        for _ in 0..<iterations {
            _ = try? await translator.translateFromJavanese(
                testPhrase,
                targetRegister: .ngoko,
                method: .dictionary
            )
        }
        
        let dictionaryTime = Date().timeIntervalSince(dictionaryStart)
        print("   \(iterations) translations in \(String(format: "%.2f", dictionaryTime))s")
        print("   Average: \(String(format: "%.2f", dictionaryTime / Double(iterations)))s per translation")
        print()
        
        // Apple Foundation Performance
        print("🍎 Apple Foundation Performance:")
        let appleStart = Date()
        
        for _ in 0..<iterations {
            _ = try? await translator.translateWithAppleFoundation(
                testPhrase,
                direction: .javaneseToIndonesian,
                targetRegister: .ngoko
            )
        }
        
        let appleTime = Date().timeIntervalSince(appleStart)
        print("   \(iterations) translations in \(String(format: "%.2f", appleTime))s")
        print("   Average: \(String(format: "%.2f", appleTime / Double(iterations)))s per translation")
        print()
        
        // OpenAI Performance
        print("🤖 OpenAI Performance:")
        let openAIStart = Date()
        
        for _ in 0..<iterations {
            _ = try? await translator.translateFromJavanese(
                testPhrase,
                targetRegister: .ngoko,
                method: .cloudModel
            )
        }
        
        let openAITime = Date().timeIntervalSince(openAIStart)
        print("   \(iterations) translations in \(String(format: "%.2f", openAITime))s")
        print("   Average: \(String(format: "%.2f", openAITime / Double(iterations)))s per translation")
        print()
        
        // Hybrid Performance
        print("🔄 Hybrid Performance:")
        let hybridStart = Date()
        
        for _ in 0..<iterations {
            _ = try? await translator.translateFromJavanese(
                testPhrase,
                targetRegister: .ngoko,
                method: .hybrid
            )
        }
        
        let hybridTime = Date().timeIntervalSince(hybridStart)
        print("   \(iterations) translations in \(String(format: "%.2f", hybridTime))s")
        print("   Average: \(String(format: "%.2f", hybridTime / Double(iterations)))s per translation")
        print()
    }
}

// MARK: - Apple Foundation Models Integration Examples
extension AppleFoundationDemo {
    func showIntegrationExamples() {
        print("📖 Apple Foundation Models Integration Examples")
        print("=============================================\n")
        
        print("1. Basic Translation:")
        print("   let result = try await translator.translateWithAppleFoundation(")
        print("       \"Aku arep mangan nasi\",")
        print("       direction: .javaneseToIndonesian,")
        print("       targetRegister: .ngoko")
        print("   )")
        print()
        
        print("2. Content Generation:")
        print("   let content = try await translator.generateContent(")
        print("       prompt: \"Write about Javanese culture\",")
        print("       context: \"For educational purposes\"")
        print("   )")
        print()
        
        print("3. Streaming Translation:")
        print("   for try await chunk in translator.streamTranslation(")
        print("       \"Aku arep mangan nasi\",")
        print("       direction: .javaneseToIndonesian,")
        print("       register: .ngoko")
        print("   ) {")
        print("       print(chunk)")
        print("   }")
        print()
        
        print("4. Error Handling:")
        print("   do {")
        print("       let result = try await translator.translateWithAppleFoundation(...)")
        print("   } catch TranslationError.cloudServiceUnavailable {")
        print("       // Fallback to dictionary or OpenAI")
        print("   } catch {")
        print("       // Handle other errors")
        print("   }")
        print()
    }
}

// MARK: - Apple Foundation Models Configuration
extension AppleFoundationDemo {
    func showConfigurationExamples() {
        print("⚙️ Apple Foundation Models Configuration")
        print("=======================================\n")
        
        print("1. Check Availability:")
        print("   let stats = translator.getTranslationStats()")
        print("   if stats.appleFoundationAvailable {")
        print("       // Apple Foundation Models are available")
        print("   }")
        print()
        
        print("2. Set Preferred Method:")
        print("   translator.setPreferredMethod(.appleFoundation)")
        print()
        
        print("3. Configure Fallback:")
        print("   translator.setFallbackToCloud(true)")
        print()
        
        print("4. Monitor Performance:")
        print("   let result = try await translator.translateWithAppleFoundation(...)")
        print("   print(\"Processing time: \\(result.processingTime)s\")")
        print("   print(\"Confidence: \\(result.confidence)\")")
        print()
    }
}

// MARK: - Real-World Usage Scenarios
extension AppleFoundationDemo {
    func showRealWorldScenarios() {
        print("🌍 Real-World Usage Scenarios")
        print("============================\n")
        
        print("1. Educational App:")
        print("   - Use Apple Foundation Models for accurate translations")
        print("   - Provide cultural context and explanations")
        print("   - Support multiple Javanese registers")
        print()
        
        print("2. Cultural Preservation:")
        print("   - Generate content about Javanese traditions")
        print("   - Translate historical documents")
        print("   - Create educational materials")
        print()
        
        print("3. Business Applications:")
        print("   - Translate business documents")
        print("   - Generate marketing content")
        print("   - Support customer communication")
        print()
        
        print("4. Personal Use:")
        print("   - Learn Javanese language")
        print("   - Communicate with family")
        print("   - Understand cultural context")
        print()
    }
}
