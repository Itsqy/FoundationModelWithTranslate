import SwiftUI
import FoundationModels

struct TranslationView: View {
    let result: Translation.PartiallyGenerated

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // target
            if let target = result.target {
                Text(target)
                    .font(.title3).bold()
                    .contentTransition(.opacity)
            }

            // register
            if let register = result.register {
                Text("Register: \(register)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // notes
            if let notes = result.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Catatan", systemImage: "lightbulb")
                    Text(notes).font(.callout)
                }
                .padding(8)
                .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }

            // word-by-word (gloss list)
            if let list = result.wordByWord, !list.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Glosarium").font(.subheadline).bold()

                    // Use enumerated index as stable ID; each element is PartiallyGenerated
                    ForEach(Array(list.enumerated()), id: \.offset) { _, g in
                        // Safely unwrap inner optional fields
                        let indo = g.indo ?? ""
                        let jawa = g.jawa ?? ""
                        let pos  = g.pos ?? ""

                        if !indo.isEmpty || !jawa.isEmpty || !pos.isEmpty {
                            HStack {
                                if !indo.isEmpty { Text(indo).bold() }
                                Text("→")
                                Text(jawa)
                                if !pos.isEmpty {
                                    Text("(\(pos))").foregroundStyle(.secondary)
                                }
                            }
                            .font(.callout)
                        }
                    }
                }
            }

            // examples
            if let examples = result.examples, !examples.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contoh").font(.subheadline).bold()
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, e in
                        if !e.isEmpty {
                            Text("• " + e)
                        }
                    }
                }
            }

            // hanacaraka
            if let aksara = result.hanacaraka, !aksara.isEmpty {
                Divider()
                Text(aksara).font(.title3)
            }
        }
        .animation(.easeOut, value: result)
        .padding()
    }
}

