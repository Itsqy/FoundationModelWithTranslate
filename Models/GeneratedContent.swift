//
//  GeneratedContent.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import Foundation

struct GeneratedContent: Codable, Identifiable {
    var id = UUID()
    let inputText: String
    let meaning: Meaning
    let pronunciation: Pronunciation
    let usage: Usage
    let conversationFunction: ConversationFunction
    let generatedAt: Date
    
    init(inputText: String, meaning: Meaning, pronunciation: Pronunciation, usage: Usage, conversationFunction: ConversationFunction) {
        self.inputText = inputText
        self.meaning = meaning
        self.pronunciation = pronunciation
        self.usage = usage
        self.conversationFunction = conversationFunction
        self.generatedAt = Date()
    }
}

struct Meaning: Codable {
    let literal: String
    let contextual: String
    
    init(literal: String, contextual: String) {
        self.literal = literal
        self.contextual = contextual
    }
}

struct Pronunciation: Codable {
    let phonetic: String
    let intonation: String
    
    init(phonetic: String, intonation: String) {
        self.phonetic = phonetic
        self.intonation = intonation
    }
}

struct Usage: Codable {
    let situations: [String]
    let examples: [String]
    
    init(situations: [String], examples: [String]) {
        self.situations = situations
        self.examples = examples
    }
}

struct ConversationFunction: Codable {
    let function: String
    let equivalent: String
    
    init(function: String, equivalent: String) {
        self.function = function
        self.equivalent = equivalent
    }
}
