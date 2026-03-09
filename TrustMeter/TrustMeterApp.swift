//
//  TrustMeterApp.swift
//  TrustMeter
//
//  Created by Anik on 15/2/26.
//

import SwiftUI

@main
struct TrustMeterApp: App {
    @StateObject private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(historyStore)
        }
    }
}
