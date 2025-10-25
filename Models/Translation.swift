import Foundation

// MARK: - Translation Models
struct TranslationResult {
    let originalText: String
    let translatedText: String
    let confidence: Double
    let method: TranslationMethod
    let dictionaryMatches: [DictionaryMatch]
    let processingTime: TimeInterval
}

struct DictionaryMatch {
    let javanese: String
    let indonesian: String
    let register: JavaneseRegister
    let confidence: Double
}

enum TranslationMethod: String, CaseIterable {
    case dictionary = "Dictionary"
    case appleFoundation = "Apple Foundation"
    case hybrid = "Hybrid"
}

enum JavaneseRegister: String, CaseIterable {
    case ngoko = "ngoko"
    case kramaAlus = "kramaalus"
    case kramaInggil = "kramainggil"
    
    var displayName: String {
        switch self {
        case .ngoko: return "Ngoko"
        case .kramaAlus: return "Ngoko Alus"
        case .kramaInggil: return "Krama Inggil"
        }
    }
}

// MARK: - Dictionary Entry Model
struct DictionaryEntry: Codable {
    let indonesia: String
    let kramaalus: String
    let kramainggil: String
    let ngoko: String
    
    func getTranslation(for register: JavaneseRegister) -> String {
        switch register {
        case .ngoko: return ngoko
        case .kramaAlus: return kramaalus
        case .kramaInggil: return kramainggil
        }
    }
}

// MARK: - Cloud Translation Models
struct CloudTranslationRequest: Codable {
    let text: String
    let sourceLanguage: String
    let targetLanguage: String
    let register: String?
}

struct CloudTranslationResponse: Codable {
    let translatedText: String
    let confidence: Double
    let processingTime: TimeInterval
}

// MARK: - Translation Error
enum TranslationError: LocalizedError {
    case dictionaryNotFound
    case cloudServiceUnavailable
    case invalidInput
    case networkError(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .dictionaryNotFound:
            return "Dictionary file not found"
        case .cloudServiceUnavailable:
            return "Cloud translation service is unavailable"
        case .invalidInput:
            return "Invalid input text"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}