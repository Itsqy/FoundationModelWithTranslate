//
//  playground.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/27/25.
//

import FoundationModels
import Playgrounds

#Playground {

    var result : String
    let dictService = DictionaryService()
    let reverseNgoko = ReverseNgokoTranslationService(dictionaryService: dictService)
    let translationIndo = TranslationService(dictionaryService: dictService)
    
    Task {
//        let result = await reverseNgoko.translateSentence("ngombe")
//        print(result) // Output: "Saya akan makan nasi"
//        let instructions = """
//          You are a translator.
//          Translate the following Indonesian sentence into natural English:
//          - Maintain tone and meaning.
//          """
//
//        let session = LanguageModelSession(instructions: instructions)
//        let response = try await session.respond(to: "translate this sentences/word ,just use translation directly without any caption : \(result), ")
//        
//        
//        let instructionBreakdown = """
//                  Analyze this  text/sentences without any caption : "\(response.content)"
//                  Provide literal meaning by breaking down each word:
//                  - Word by word translation
//                  - Literal meaning explanation
//           """
//
//
//        let sessionBreakdown = LanguageModelSession(instructions: instructionBreakdown)
//
//
//        let prompt = "generate one usecase to use that word/sentences and translate it to indonesia"
//        let responseBreakdown = try await sessionBreakdown.respond(to: prompt)
//
        
        let result = await reverseNgoko.translateSentence("ngombe")
        print("Intermediate Indonesian:", result) // e.g. "Saya minum"

        /// STEP 1: Translate to English first (if needed)
        let instructions = """
        You are a translator.
        Translate the following Indonesian sentence into natural English only.
        Do not include any explanation, caption, or note.
        Just output the translated English sentence.
        """

        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: result)

        /// STEP 2: Analyze and generate Indonesian example, without captions
        let instructionBreakdown = """
        Analyze this text/sentence: "\(response.content)"
        Provide 2, natural Indonesian example usage for this sentence.
        
        Do not include any headings, labels, or English text.
        Output only the final Indonesian sentences.
        """

        let sessionBreakdown = LanguageModelSession(instructions: instructionBreakdown)
        let prompt = "translate in Indonesian language only, without captions or explanations. and  provide meaning in contextual and literal."
        let responseBreakdown = try await sessionBreakdown.respond(to: prompt)

        print("Clean Indonesian Output:\n\(responseBreakdown.content)")
        
       
        let resulttoJawa = await translationIndo.translateSentence("\(responseBreakdown.content)",to:.ngoko)

       
    }
    

    
    
    
        
}
