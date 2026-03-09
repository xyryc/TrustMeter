//
//  RootTabView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct RootTabView: View {
    @AppStorage("prefersDarkTheme") private var prefersDarkTheme = false

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
        .preferredColorScheme(prefersDarkTheme ? .dark : .light)
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
            .environmentObject(HistoryStore())
    }
}
