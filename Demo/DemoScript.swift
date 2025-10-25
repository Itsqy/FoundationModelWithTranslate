import Foundation

// MARK: - Demo Script for Javanese Translator
// This file demonstrates how to use the translation services

class TranslationDemo {
    private let translator = JavaneseTranslator()
    
    func runDemo() async {
        print("🇮🇩 Javanese-Indonesian Translator Demo")
        print("=====================================\n")
        
        // Demo 1: Dictionary Translation
        await demoDictionaryTranslation()
        
        // Demo 2: Cloud Translation (if available)
        await demoCloudTranslation()
        
        // Demo 3: Hybrid Translation
        await demoHybridTranslation()
        
        // Demo 4: Content Generation
        await demoContentGeneration()
    }
    
    private func demoDictionaryTranslation() async {
        print("📚 Dictionary Translation Demo")
        print("-------------------------------")
        
        let testPhrases = [
            ("Mangan", "Ngoko for 'eat'"),
            ("Nedha", "Krama Alus for 'eat'"),
            ("Dhahar", "Krama Inggil for 'eat'"),
            ("Turu", "Ngoko for 'sleep'"),
            ("Tilem", "Krama Alus for 'sleep'")
        ]
        
        for (phrase, description) in testPhrases {
            do {
                let result = try await translator.translateFromJavanese(
                    phrase,
                    targetRegister: .ngoko,
                    method: .dictionary
                )
                
                print("✅ \(phrase) (\(description))")
                print("   → \(result.translatedText)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Method: \(result.method.rawValue)")
                print("   Processing Time: \(String(format: "%.2f", result.processingTime))s")
                print("   Dictionary Matches: \(result.dictionaryMatches.count)")
                print()
            } catch {
                print("❌ Failed to translate '\(phrase)': \(error.localizedDescription)")
                print()
            }
        }
    }
    
    private func demoCloudTranslation() async {
        print("☁️ Cloud Translation Demo")
        print("-------------------------")
        
        let testPhrases = [
            "Aku arep mangan nasi karo kulawarga",
            "Kula badhe nedha sekul kaliyan kulawarga",
            "Kula badhe dhahar sekul kaliyan kulawarga"
        ]
        
        for phrase in testPhrases {
            do {
                let result = try await translator.translateFromJavanese(
                    phrase,
                    targetRegister: .ngoko,
                    method: .cloudModel
                )
                
                print("✅ \(phrase)")
                print("   → \(result.translatedText)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Method: \(result.method.rawValue)")
                print("   Processing Time: \(String(format: "%.2f", result.processingTime))s")
                print()
            } catch {
                print("❌ Cloud translation failed: \(error.localizedDescription)")
                print("   (This is expected if no API key is configured)")
                print()
            }
        }
    }
    
    private func demoHybridTranslation() async {
        print("🔄 Hybrid Translation Demo")
        print("---------------------------")
        
        let testPhrases = [
            "Aku arep mangan",
            "Kula badhe nedha",
            "Kula badhe dhahar"
        ]
        
        for phrase in testPhrases {
            do {
                let result = try await translator.translateFromJavanese(
                    phrase,
                    targetRegister: .ngoko,
                    method: .hybrid
                )
                
                print("✅ \(phrase)")
                print("   → \(result.translatedText)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Method: \(result.method.rawValue)")
                print("   Processing Time: \(String(format: "%.2f", result.processingTime))s")
                print("   Dictionary Matches: \(result.dictionaryMatches.count)")
                print()
            } catch {
                print("❌ Hybrid translation failed: \(error.localizedDescription)")
                print()
            }
        }
    }
    
    private func demoContentGeneration() async {
        print("✨ Content Generation Demo")
        print("-------------------------")
        
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
                print("   (This is expected if no API key is configured)")
                print()
            }
        }
    }
}

// MARK: - Usage Examples
extension TranslationDemo {
    func showUsageExamples() {
        print("📖 Usage Examples")
        print("================\n")
        
        print("1. Basic Translation:")
        print("   let translator = JavaneseTranslator()")
        print("   let result = try await translator.translateFromJavanese(")
        print("       \"Mangan\",")
        print("       targetRegister: .ngoko,")
        print("       method: .dictionary")
        print("   )")
        print()
        
        print("2. Cloud Translation:")
        print("   let result = try await translator.translateFromJavanese(")
        print("       \"Aku arep mangan nasi\",")
        print("       targetRegister: .ngoko,")
        print("       method: .cloudModel")
        print("   )")
        print()
        
        print("3. Hybrid Translation:")
        print("   let result = try await translator.translateFromJavanese(")
        print("       \"Aku arep mangan nasi\",")
        print("       targetRegister: .ngoko,")
        print("       method: .hybrid")
        print("   )")
        print()
        
        print("4. Content Generation:")
        print("   let content = try await translator.generateContent(")
        print("       prompt: \"Write about Javanese culture\",")
        print("       context: \"For educational purposes\"")
        print("   )")
        print()
        
        print("5. Configuration:")
        print("   // Set API key")
        print("   APIConfiguration.shared.setAPIKey(\"your-api-key\")")
        print()
        print("   // Configure translator")
        print("   translator.setPreferredMethod(.hybrid)")
        print("   translator.setFallbackToCloud(true)")
        print()
    }
}

// MARK: - Performance Benchmarks
extension TranslationDemo {
    func runPerformanceBenchmarks() async {
        print("⚡ Performance Benchmarks")
        print("========================\n")
        
        let testWords = ["Mangan", "Turu", "Nedha", "Dhahar", "Kulo"]
        let iterations = 10
        
        // Dictionary Performance
        print("📚 Dictionary Performance:")
        let dictionaryStart = Date()
        
        for _ in 0..<iterations {
            for word in testWords {
                _ = try? await translator.translateFromJavanese(
                    word,
                    targetRegister: .ngoko,
                    method: .dictionary
                )
            }
        }
        
        let dictionaryTime = Date().timeIntervalSince(dictionaryStart)
        print("   \(iterations * testWords.count) translations in \(String(format: "%.2f", dictionaryTime))s")
        print("   Average: \(String(format: "%.2f", dictionaryTime / Double(iterations * testWords.count)))s per translation")
        print()
        
        // Cloud Performance (if available)
        if translator.getTranslationStats().cloudAvailable {
            print("☁️ Cloud Performance:")
            let cloudStart = Date()
            
            for _ in 0..<3 { // Fewer iterations for cloud
                for word in testWords {
                    _ = try? await translator.translateFromJavanese(
                        word,
                        targetRegister: .ngoko,
                        method: .cloudModel
                    )
                }
            }
            
            let cloudTime = Date().timeIntervalSince(cloudStart)
            print("   \(3 * testWords.count) translations in \(String(format: "%.2f", cloudTime))s")
            print("   Average: \(String(format: "%.2f", cloudTime / Double(3 * testWords.count)))s per translation")
            print()
        }
        
        // Hybrid Performance
        print("🔄 Hybrid Performance:")
        let hybridStart = Date()
        
        for _ in 0..<iterations {
            for word in testWords {
                _ = try? await translator.translateFromJavanese(
                    word,
                    targetRegister: .ngoko,
                    method: .hybrid
                )
            }
        }
        
        let hybridTime = Date().timeIntervalSince(hybridStart)
        print("   \(iterations * testWords.count) translations in \(String(format: "%.2f", hybridTime))s")
        print("   Average: \(String(format: "%.2f", hybridTime / Double(iterations * testWords.count)))s per translation")
        print()
    }
}
