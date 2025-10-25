import SwiftUI

struct SettingsView: View {
    @StateObject private var translator = JavaneseTranslator()
    @State private var preferredMethod: TranslationMethod = .hybrid
    @State private var fallbackToCloud: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Translation Settings") {
                    Picker("Preferred Method", selection: $preferredMethod) {
                        ForEach(TranslationMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    Toggle("Fallback to Cloud", isOn: $fallbackToCloud)
                        .disabled(preferredMethod == .dictionary)
                }
                
                
                Section("Service Status") {
                    HStack {
                        Text("Dictionary Loaded")
                        Spacer()
                        Image(systemName: translator.getTranslationStats().dictionaryLoaded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(translator.getTranslationStats().dictionaryLoaded ? .green : .red)
                    }
                    
                    HStack {
                        Text("Apple Foundation")
                        Spacer()
                        Image(systemName: translator.getTranslationStats().appleFoundationAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(translator.getTranslationStats().appleFoundationAvailable ? .green : .red)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Dictionary Entries")
                        Spacer()
                        Text("\(translator.getTranslationStats().dictionaryLoaded ? "Loaded" : "Not Available")")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        // Load saved settings
        if let savedMethod = UserDefaults.standard.string(forKey: "preferredMethod"),
           let method = TranslationMethod(rawValue: savedMethod) {
            preferredMethod = method
        }
        
        fallbackToCloud = UserDefaults.standard.bool(forKey: "fallbackToCloud")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
