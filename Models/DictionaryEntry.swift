//
//  DictionaryEntry.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let id: String
    let indonesia: String
    let kramaalus: String
    let kramainggil: String
    let ngoko: String
    
    enum CodingKeys: String, CodingKey {
        case indonesia, kramaalus, kramainggil, ngoko
    }
    
    init(id: String, indonesia: String, kramaalus: String, kramainggil: String, ngoko: String) {
        self.id = id
        self.indonesia = indonesia
        self.kramaalus = kramaalus
        self.kramainggil = kramainggil
        self.ngoko = ngoko
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.indonesia = try container.decode(String.self, forKey: .indonesia)
        self.kramaalus = try container.decode(String.self, forKey: .kramaalus)
        self.kramainggil = try container.decode(String.self, forKey: .kramainggil)
        self.ngoko = try container.decode(String.self, forKey: .ngoko)
    }
}

enum JavaneseLevel: String, CaseIterable {
    case kramaalus = "Krama Alus"
    case kramainggil = "Krama Inggil"
    case ngoko = "Ngoko"
    
    var displayName: String {
        return self.rawValue
    }
}
