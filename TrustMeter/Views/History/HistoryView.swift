//
//  HistoryView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: HistoryStore

    var body: some View {
        Group {
            if historyStore.items.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !historyStore.items.isEmpty {
                Button("Clear") {
                    historyStore.removeAll()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.largeTitle.bold())

            Text("Scanned products will appear here.")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    private var historyList: some View {
        List {
            ForEach(historyStore.items) { result in
                NavigationLink {
                    ResultView(result: result)
                } label: {
                    HistoryRowView(result: result)
                }
            }
            .onDelete(perform: historyStore.delete)
        }
        .listStyle(.insetGrouped)
    }
}

private struct HistoryRowView: View {
    let result: AnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.productData.title ?? "Analyzed Product")
                        .font(.headline)
                        .lineLimit(2)

                    Text(result.productData.domain ?? result.url)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(result.scoreBreakdown.totalScore)")
                    .font(.headline.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(scoreColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(scoreColor)
            }

            HStack(spacing: 10) {
                Text(result.scoreBreakdown.ratingLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground), in: Capsule())

                if let priceText = formattedPrice {
                    Text(priceText)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground), in: Capsule())
                }

                Spacer()

                Text(result.analyzedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedPrice: String? {
        guard let price = result.productData.price else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = result.productData.currency ?? "USD"

        return formatter.string(from: NSNumber(value: price))
    }

    private var scoreColor: Color {
        switch result.scoreBreakdown.totalScore {
        case 80...:
            return .green
        case 60...79:
            return .orange
        default:
            return .red
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(HistoryStore())
    }
}
