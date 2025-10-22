//
//  DictionaryService.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import SwiftUI
import Foundation
import Combine

class DictionaryService: ObservableObject {
    @Published var dictionaryEntries: [DictionaryEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var entriesDict: [String: DictionaryEntry] = [:]
    
    init() {
        loadDictionary()
    }
    
    func loadDictionary() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "kamus-bahasa-jawa", withExtension: "json") else {
            errorMessage = "Dictionary file not found"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let jsonDict = jsonObject as? [String: Any],
               let employees = jsonDict["employees"] as? [String: Any] {
                
                var entries: [DictionaryEntry] = []
                
                for (key, value) in employees {
                    if let entryDict = value as? [String: String] {
                        var entry = DictionaryEntry(
                            id: key,
                            indonesia: entryDict["indonesia"] ?? "",
                            kramaalus: entryDict["kramaalus"] ?? "",
                            kramainggil: entryDict["kramainggil"] ?? "",
                            ngoko: entryDict["ngoko"] ?? ""
                        )
                        entries.append(entry)
                        entriesDict[entry.indonesia.lowercased()] = entry
                    }
                }
                
                DispatchQueue.main.async {
                    self.dictionaryEntries = entries
                    self.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load dictionary: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func translateWord(_ word: String, to level: JavaneseLevel) -> String? {
        let lowercaseWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let entry = entriesDict[lowercaseWord] {
            switch level {
            case .kramaalus:
                return entry.kramaalus
            case .kramainggil:
                return entry.kramainggil
            case .ngoko:
                return entry.ngoko
            }
        }
        
        return nil
    }
    
    func searchEntries(query: String) -> [DictionaryEntry] {
        let lowercaseQuery = query.lowercased()
        return dictionaryEntries.filter { entry in
            entry.indonesia.lowercased().contains(lowercaseQuery) ||
            entry.kramaalus.lowercased().contains(lowercaseQuery) ||
            entry.kramainggil.lowercased().contains(lowercaseQuery) ||
            entry.ngoko.lowercased().contains(lowercaseQuery)
        }
    }
}

