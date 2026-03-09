//
//  ResultView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct ResultView: View {
    let result: AnalysisResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                productCard
                breakdownCard
                signalCard(
                    title: "Positive Signals",
                    icon: "checkmark.seal.fill",
                    tint: .green,
                    items: result.scoreBreakdown.positiveSignals
                )
                signalCard(
                    title: "Warnings",
                    icon: "exclamationmark.triangle.fill",
                    tint: .orange,
                    items: result.scoreBreakdown.warnings
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(result.scoreBreakdown.ratingLabel)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(scoreColor)

                    Text(productTitle)
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                }

                Spacer()

                ScoreRing(score: result.scoreBreakdown.totalScore, tint: scoreColor)
            }

            HStack(spacing: 10) {
                DetailChip(icon: "globe", text: result.productData.domain ?? domainFromURL)

                if let priceText = formattedPrice {
                    DetailChip(icon: "tag.fill", text: priceText)
                }

                if let availability = result.productData.availability, !availability.isEmpty {
                    DetailChip(icon: "shippingbox.fill", text: availability)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    scoreColor.opacity(0.18),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Product Snapshot", icon: "doc.text.image")

            if let imageURL = result.productData.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemFill))

                        ProgressView()
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if let description = result.productData.productDescription, !description.isEmpty {
                Text(description)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                MetaPill(title: "Store", value: result.productData.siteName ?? "Unknown")
                MetaPill(title: "Checked", value: result.analyzedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .cardStyle()
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Score Breakdown", icon: "chart.bar.fill")

            ScoreBarRow(title: "Price", score: result.scoreBreakdown.priceScore, tint: .blue)
            ScoreBarRow(title: "Metadata", score: result.scoreBreakdown.metadataScore, tint: .indigo)
            ScoreBarRow(title: "Completeness", score: result.scoreBreakdown.completenessScore, tint: .teal)
            ScoreBarRow(title: "Trust", score: result.scoreBreakdown.trustScore, tint: .green)
        }
        .cardStyle()
    }

    private func signalCard(title: String, icon: String, tint: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: title, icon: icon, tint: tint)

            if items.isEmpty {
                Text("No items found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: icon)
                            .foregroundStyle(tint)
                            .padding(.top, 2)

                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var productTitle: String {
        result.productData.title ?? "Analyzed Product"
    }

    private var domainFromURL: String {
        URL(string: result.url)?.host ?? result.url
    }

    private var formattedPrice: String? {
        guard let price = result.productData.price else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = result.productData.currency ?? "USD"

        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    private var scoreColor: Color {
        let score = result.scoreBreakdown.totalScore

        switch score {
        case 80...:
            return .green
        case 60...79:
            return .orange
        default:
            return .red
        }
    }
}

private struct SectionTitle: View {
    let title: String
    let icon: String
    var tint: Color = .accentColor

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)

            Text(title)
                .font(.headline)
        }
    }
}

private struct DetailChip: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground), in: Capsule())
    }
}

private struct MetaPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ScoreBarRow: View {
    let title: String
    let score: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(score)/25")
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(Color(.tertiarySystemFill))

                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.7), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * (CGFloat(score) / 25))
                }
            }
            .frame(height: 10)
        }
    }
}

private struct ScoreRing: View {
    let score: Int
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: 10)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.title2.bold())

                Text("/100")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 92, height: 92)
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    ResultView(result: .sample)
}
