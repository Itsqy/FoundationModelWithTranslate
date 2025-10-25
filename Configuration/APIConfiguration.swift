import Foundation

final class APIConfiguration {
    static let shared = APIConfiguration()
    
    private init() {}
    
    // MARK: - Apple Foundation Models Configuration
    var isAppleFoundationAvailable: Bool {
        if #available(iOS 18.0, macOS 15.0, *) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Model Configuration
    var defaultModel: String {
        return "apple-foundation-model"
    }
    
    var maxTokens: Int {
        return 1000
    }
    
    var temperature: Double {
        return 0.3
    }
    
    // MARK: - Validation
    var isAPIConfigured: Bool {
        return isAppleFoundationAvailable
    }
    
    func validateConfiguration() -> Bool {
        return isAppleFoundationAvailable
    }
}