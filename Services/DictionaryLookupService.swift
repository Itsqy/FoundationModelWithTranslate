import Foundation

class DictionaryLookupService: ObservableObject {
    private var dictionary: [String: DictionaryEntry] = [:]
    private let dictionaryFileName = "kamus-bahasa-jawa"
    
    @Published var isLoaded = false
    @Published var error: Error?
    
    init() {
        loadDictionary()
    }
    
    // MARK: - Dictionary Loading
    private func loadDictionary() {
        guard let url = Bundle.main.url(forResource: dictionaryFileName, withExtension: "json") else {
            error = TranslationError.dictionaryNotFound
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDict = jsonData as? [String: Any],
                  let employees = jsonDict["employees"] as? [String: [String: String]] else {
                error = TranslationError.parsingError("Invalid dictionary format")
                return
            }
            
            // Convert to our DictionaryEntry format
            for (_, entryData) in employees {
                if let entry = DictionaryEntry.from(dictionary: entryData) {
                    // Create multiple entries for different registers
                    for (register, translation) in entryData {
                        if let javaneseRegister = JavaneseRegister(rawValue: register) {
                            let key = "\(translation.lowercased())_\(javaneseRegister.rawValue)"
                            dictionary[key] = entry
                        }
                    }
                }
            }
            
            isLoaded = true
        } catch {
            self.error = TranslationError.parsingError(error.localizedDescription)
        }
    }
    
    // MARK: - Translation Methods
    func translateFromJavanese(_ text: String, targetRegister: JavaneseRegister = .ngoko) -> [DictionaryMatch] {
        guard isLoaded else { return [] }
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var matches: [DictionaryMatch] = []
        
        for word in words {
            let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
            if let match = findDictionaryMatch(for: cleanWord, targetRegister: targetRegister) {
                matches.append(match)
            }
        }
        
        return matches
    }
    
    func translateToJavanese(_ text: String, targetRegister: JavaneseRegister = .ngoko) -> [DictionaryMatch] {
        guard isLoaded else { return [] }
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var matches: [DictionaryMatch] = []
        
        for word in words {
            let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
            if let match = findReverseDictionaryMatch(for: cleanWord, targetRegister: targetRegister) {
                matches.append(match)
            }
        }
        
        return matches
    }
    
    // MARK: - Private Helper Methods
    private func findDictionaryMatch(for word: String, targetRegister: JavaneseRegister) -> DictionaryMatch? {
        // Search for exact matches first
        for (key, entry) in dictionary {
            let javaneseWord = entry.getTranslation(for: targetRegister).lowercased()
            if javaneseWord == word {
                return DictionaryMatch(
                    javanese: javaneseWord,
                    indonesian: entry.indonesia,
                    register: targetRegister,
                    confidence: 1.0
                )
            }
        }
        
        // Search for partial matches
        for (key, entry) in dictionary {
            let javaneseWord = entry.getTranslation(for: targetRegister).lowercased()
            if javaneseWord.contains(word) || word.contains(javaneseWord) {
                let confidence = calculateConfidence(javaneseWord: javaneseWord, inputWord: word)
                return DictionaryMatch(
                    javanese: javaneseWord,
                    indonesian: entry.indonesia,
                    register: targetRegister,
                    confidence: confidence
                )
            }
        }
        
        return nil
    }
    
    private func findReverseDictionaryMatch(for word: String, targetRegister: JavaneseRegister) -> DictionaryMatch? {
        // Search for Indonesian to Javanese matches
        for (key, entry) in dictionary {
            if entry.indonesia.lowercased() == word {
                let javaneseTranslation = entry.getTranslation(for: targetRegister)
                return DictionaryMatch(
                    javanese: javaneseTranslation,
                    indonesian: entry.indonesia,
                    register: targetRegister,
                    confidence: 1.0
                )
            }
        }
        
        // Search for partial matches
        for (key, entry) in dictionary {
            if entry.indonesia.lowercased().contains(word) || word.contains(entry.indonesia.lowercased()) {
                let javaneseTranslation = entry.getTranslation(for: targetRegister)
                let confidence = calculateConfidence(javaneseWord: entry.indonesia, inputWord: word)
                return DictionaryMatch(
                    javanese: javaneseTranslation,
                    indonesian: entry.indonesia,
                    register: targetRegister,
                    confidence: confidence
                )
            }
        }
        
        return nil
    }
    
    private func calculateConfidence(javaneseWord: String, inputWord: String) -> Double {
        let maxLength = max(javaneseWord.count, inputWord.count)
        let minLength = min(javaneseWord.count, inputWord.count)
        
        if maxLength == 0 { return 0.0 }
        
        let similarity = Double(minLength) / Double(maxLength)
        return min(similarity, 0.8) // Cap at 0.8 for partial matches
    }
    
    // MARK: - Utility Methods
    func getDictionaryStats() -> (totalEntries: Int, registers: [JavaneseRegister]) {
        return (dictionary.count, JavaneseRegister.allCases)
    }
    
    func searchDictionary(query: String) -> [DictionaryEntry] {
        guard isLoaded else { return [] }
        
        let lowercaseQuery = query.lowercased()
        var results: [DictionaryEntry] = []
        
        for entry in dictionary.values {
            if entry.indonesia.lowercased().contains(lowercaseQuery) ||
               entry.ngoko.lowercased().contains(lowercaseQuery) ||
               entry.kramaalus.lowercased().contains(lowercaseQuery) ||
               entry.kramainggil.lowercased().contains(lowercaseQuery) {
                results.append(entry)
            }
        }
        
        return Array(Set(results)) // Remove duplicates
    }
}

// MARK: - DictionaryEntry Extension
extension DictionaryEntry {
    static func from(dictionary: [String: String]) -> DictionaryEntry? {
        guard let indonesia = dictionary["indonesia"],
              let kramaalus = dictionary["kramaalus"],
              let kramainggil = dictionary["kramainggil"],
              let ngoko = dictionary["ngoko"] else {
            return nil
        }
        
        return DictionaryEntry(
            indonesia: indonesia,
            kramaalus: kramaalus,
            kramainggil: kramainggil,
            ngoko: ngoko
        )
    }
}
