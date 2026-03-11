//
//  SettingsView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @AppStorage("appThemeMode") private var appThemeMode = AppThemeMode.system.rawValue
    @AppStorage("saveHistoryEnabled") private var saveHistoryEnabled = true
    @AppStorage("showExtractionSources") private var showExtractionSources = true
    @State private var showClearHistoryConfirmation = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appThemeMode) {
                    ForEach(AppThemeMode.allCases) { themeMode in
                        Text(themeMode.title).tag(themeMode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("History") {
                Toggle("Save History", isOn: $saveHistoryEnabled)

                Button("Clear History", role: .destructive) {
                    showClearHistoryConfirmation = true
                }
                .disabled(historyStore.items.isEmpty)
            }

            Section("Results") {
                Toggle("Show Extraction Sources", isOn: $showExtractionSources)
            }

            Section("About") {
                settingsRow(title: "App Name", value: "TrustMeter")
                settingsRow(title: "Version", value: appVersion)
                settingsRow(title: "Build", value: buildNumber)
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Clear all saved scans?", isPresented: $showClearHistoryConfirmation, titleVisibility: .visible) {
            Button("Clear History", role: .destructive) {
                historyStore.removeAll()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes every saved result from the History tab.")
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    private func settingsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(HistoryStore())
    }
}
