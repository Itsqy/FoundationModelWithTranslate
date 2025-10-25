import SwiftUI

struct TranslationResultView: View {
    let translation: TranslationResult
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main translation result
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Translation")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    TranslationMethodBadge(method: translation.method)
                }
                
                Text(translation.translatedText)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Translation details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { showingDetails.toggle() }) {
                        Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                }
                
                if showingDetails {
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Confidence", value: "\(Int(translation.confidence * 100))%")
                        DetailRow(label: "Method", value: translation.method.rawValue)
                        DetailRow(label: "Processing Time", value: String(format: "%.2fs", translation.processingTime))
                        
                        if !translation.dictionaryMatches.isEmpty {
                            DetailRow(label: "Dictionary Matches", value: "\(translation.dictionaryMatches.count)")
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            // Dictionary matches section
            if !translation.dictionaryMatches.isEmpty {
                DictionaryMatchesView(matches: translation.dictionaryMatches)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TranslationMethodBadge: View {
    let method: TranslationMethod
    
    var body: some View {
        Text(method.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch method {
        case .dictionary:
            return .blue.opacity(0.2)
        case .cloudModel:
            return .green.opacity(0.2)
        case .hybrid:
            return .orange.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch method {
        case .dictionary:
            return .blue
        case .cloudModel:
            return .green
        case .hybrid:
            return .orange
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct DictionaryMatchesView: View {
    let matches: [DictionaryMatch]
    @State private var expandedMatch: DictionaryMatch?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dictionary Matches")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(matches.indices, id: \.self) { index in
                let match = matches[index]
                DictionaryMatchRow(
                    match: match,
                    isExpanded: expandedMatch?.javanese == match.javanese
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expandedMatch = expandedMatch?.javanese == match.javanese ? nil : match
                    }
                }
            }
        }
    }
}

struct DictionaryMatchRow: View {
    let match: DictionaryMatch
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(match.javanese)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text(match.indonesian)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(match.register.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(3)
                        
                        Text("\(Int(match.confidence * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                    
                    HStack {
                        Text("Register:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(match.register.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Confidence:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(match.confidence * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
                .padding(.leading, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(6)
    }
}

// MARK: - Preview
struct TranslationResultView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTranslation = TranslationResult(
            originalText: "Mangan",
            translatedText: "Makan",
            confidence: 0.95,
            method: .hybrid,
            dictionaryMatches: [
                DictionaryMatch(
                    javanese: "Mangan",
                    indonesian: "Makan",
                    register: .ngoko,
                    confidence: 1.0
                )
            ],
            processingTime: 0.5
        )
        
        TranslationResultView(translation: sampleTranslation)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}