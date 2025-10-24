import Foundation
import FoundationModels

@Generable
struct Translation: Equatable {
    // Echo input for traceability
    @Guide(description: "Original Indonesian sentence/paragraph.")
    let source: String

    // Final target strings
    @Guide(description: "Main Javanese translation in requested register/dialect.")
    let target: String

    // Useful metadata for pedagogy & QA
    @Guide(description: "Dialect/register used. E.g., Ngoko/Ngoko Alus/Krama/Krama Inggil.")
    let register: String

    @Guide(description: "Notes on tricky words, ambiguity, or cultural nuance. Keep short, bullet-like.")
    let notes: String

    @Guide(description: "Optional: literal gloss mapping Indonesian → Javanese for key words/phrases.")
    let wordByWord: [Gloss]

    @Guide(description: "2–3 short example sentences in the same register using the key vocabulary.")
    @Guide(.count(2))
    let examples: [String]

    // Optional: write Aksara Jawa if you plan to support it later
    @Guide(description: "Optional Aksara Jawa representation if requested, else empty.")
    let hanacaraka: String
}

@Generable
struct Gloss: Equatable {
    let id: Int
    let indo: String
    let jawa: String
    @Guide(description: "Short POS tag like n., v., adj. if helpful.")
    let pos: String
}
