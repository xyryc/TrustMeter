//
//  ResultView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct ResultView: View {
    @AppStorage("showExtractionSources") private var showExtractionSources = true
    let result: AnalysisResult
    @State private var isDescriptionExpanded = false

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

            HStack(spacing: 12) {
                ConfidenceBadgeView(
                    score: result.scoreBreakdown.confidenceScore,
                    label: result.scoreBreakdown.confidenceLabel
                )

                Text("Confidence reflects how reliable the extracted fields appear.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                ExpandableDescriptionView(
                    description: description,
                    isExpanded: $isDescriptionExpanded
                )
            }

            if showExtractionSources {
                HStack(spacing: 12) {
                    MetaPill(title: "Store", value: storeName)
                    MetaPill(title: "Price Source", value: sourceLabel(result.productData.sources.price))
                }

                HStack(spacing: 12) {
                    MetaPill(title: "Title Source", value: sourceLabel(result.productData.sources.title))
                    MetaPill(title: "Checked", value: result.analyzedAt.formatted(date: .abbreviated, time: .shortened))
                }
            } else {
                HStack(spacing: 12) {
                    MetaPill(title: "Store", value: storeName)
                    MetaPill(title: "Checked", value: result.analyzedAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
        }
        .cardStyle()
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Score Breakdown", icon: "chart.bar.fill")

            Text("Each category measures a different part of page quality instead of reusing the same signals.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            BreakdownMetricView(
                title: "Pricing Integrity",
                icon: "tag.fill",
                score: result.scoreBreakdown.priceScore,
                summary: result.scoreBreakdown.priceSummary,
                tint: .blue
            )

            BreakdownMetricView(
                title: "Metadata Quality",
                icon: "doc.text.magnifyingglass",
                score: result.scoreBreakdown.metadataScore,
                summary: result.scoreBreakdown.metadataSummary,
                tint: .indigo
            )

            BreakdownMetricView(
                title: "Product Completeness",
                icon: "square.grid.2x2.fill",
                score: result.scoreBreakdown.completenessScore,
                summary: result.scoreBreakdown.completenessSummary,
                tint: .teal
            )

            BreakdownMetricView(
                title: "Store & Technical Trust",
                icon: "checkmark.shield.fill",
                score: result.scoreBreakdown.trustScore,
                summary: result.scoreBreakdown.trustSummary,
                tint: .green
            )
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

    private var storeName: String {
        if let siteName = result.productData.siteName, !siteName.isEmpty {
            return siteName
        }

        if let domain = result.productData.domain, !domain.isEmpty {
            return domain
        }

        return "Store"
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

    private func sourceLabel(_ source: ExtractionSource?) -> String {
        source?.rawValue ?? "Unavailable"
    }
}

private struct ConfidenceBadgeView: View {
    let score: Int
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield")
            Text("\(label) \(score)%")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(badgeColor.opacity(0.14), in: Capsule())
        .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch score {
        case 85...:
            return .green
        case 65...84:
            return .orange
        default:
            return .red
        }
    }
}

private struct BreakdownMetricView: View {
    let title: String
    let icon: String
    let score: Int
    let summary: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .foregroundStyle(tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(score)/25")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }

            ScoreBarRow(title: "", score: score, tint: tint, hidesHeader: true)
        }
        .padding(14)
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ExpandableDescriptionView: View {
    let description: String
    @Binding var isExpanded: Bool

    private let collapsedLineLimit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(description)
                .foregroundStyle(.secondary)
                .lineLimit(isExpanded ? nil : collapsedLineLimit)

            Button(isExpanded ? "See less" : "See more") {
                isExpanded.toggle()
            }
            .font(.subheadline.weight(.semibold))
            .buttonStyle(.plain)
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(result: .sample)
    }
}
