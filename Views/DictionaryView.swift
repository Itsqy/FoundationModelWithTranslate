//
//  DictionaryView.swift
//  fmltest
//
//  Created by Muhammad Rifqi Syatria on 10/19/25.
//

import SwiftUI

struct DictionaryView: View {
    @ObservedObject var dictionaryService: DictionaryService
    @State private var searchText = ""
    @State private var selectedLevel: JavaneseLevel = .kramaalus
    @Environment(\.dismiss) private var dismiss
    
    var filteredEntries: [DictionaryEntry] {
        if searchText.isEmpty {
            return dictionaryService.dictionaryEntries
        } else {
            return dictionaryService.searchEntries(query: searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Cari kata...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Language Level Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tampilkan dalam:")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    Picker("Tingkat Bahasa", selection: $selectedLevel) {
                        ForEach(JavaneseLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Dictionary Entries List
                if dictionaryService.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Memuat kamus...")
                            .font(.headline)
                        Spacer()
                    }
                } else if dictionaryService.errorMessage != nil {
                    VStack {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Gagal memuat kamus")
                            .font(.headline)
                            .padding(.top)
                        Text(dictionaryService.errorMessage ?? "Error tidak diketahui")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                } else {
                    List(filteredEntries) { entry in
                        DictionaryEntryRow(entry: entry, selectedLevel: selectedLevel)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Kamus Jawa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DictionaryEntryRow: View {
    let entry: DictionaryEntry
    let selectedLevel: JavaneseLevel
    
    var translation: String {
        switch selectedLevel {
        case .kramaalus:
            return entry.kramaalus
        case .kramainggil:
            return entry.kramainggil
        case .ngoko:
            return entry.ngoko
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.indonesia)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(selectedLevel.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(translation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            // Show all levels for reference
            if selectedLevel != .kramaalus || selectedLevel != .kramainggil || selectedLevel != .ngoko {
                HStack(spacing: 16) {
                    if entry.kramaalus != translation {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Krama Alus")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(entry.kramaalus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if entry.kramainggil != translation {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Krama Inggil")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(entry.kramainggil)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if entry.ngoko != translation {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ngoko")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(entry.ngoko)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DictionaryView(dictionaryService: DictionaryService())
}
