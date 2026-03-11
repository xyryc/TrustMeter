//
//  RootTabView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct RootTabView: View {
    @AppStorage("appThemeMode") private var appThemeMode = AppThemeMode.system.rawValue

    var body: some View {
        TabView {
            NavigationStack {
                AnalyzerView()
            }
            .tabItem {
                Label("Analyze", systemImage: "viewfinder")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
    }

    private var selectedTheme: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
            .environmentObject(HistoryStore())
    }
}
