//
//  HistoryStore.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Combine
import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var items: [AnalysisResult] = []

    private let userDefaults: UserDefaults
    private let storageKey = "analysis_history"
    private let maxItemCount = 50

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    func add(_ result: AnalysisResult) {
        items.removeAll { $0.id == result.id }
        items.insert(result, at: 0)

        if items.count > maxItemCount {
            items = Array(items.prefix(maxItemCount))
        }

        save()
    }

    func delete(at offsets: IndexSet) {
        for offset in offsets.sorted(by: >) {
            items.remove(at: offset)
        }
        save()
    }

    func removeAll() {
        items.removeAll()
        save()
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey) else { return }

        let decoder = JSONDecoder()

        if let savedItems = try? decoder.decode([AnalysisResult].self, from: data) {
            items = savedItems.sorted { $0.analyzedAt > $1.analyzedAt }
        }
    }

    private func save() {
        let encoder = JSONEncoder()

        guard let data = try? encoder.encode(items) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
