//
//  TrustScorer.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Foundation

struct TrustScorer {
    func score(productData: ProductData, pageURL: URL) -> ScoreBreakdown {
        let priceScore = scorePrice(from: productData)
        let metadataScore = scoreMetadata(from: productData)
        let completenessScore = scoreCompleteness(from: productData)
        let trustScore = scoreTrust(from: productData, pageURL: pageURL)
        let confidenceScore = scoreConfidence(from: productData, pageURL: pageURL)

        let totalScore = clampTotal(priceScore + metadataScore + completenessScore + trustScore)

        return ScoreBreakdown(
            priceScore: priceScore,
            metadataScore: metadataScore,
            completenessScore: completenessScore,
            trustScore: trustScore,
            totalScore: totalScore,
            ratingLabel: ratingLabel(for: totalScore),
            confidenceScore: confidenceScore,
            confidenceLabel: confidenceLabel(for: confidenceScore),
            positiveSignals: positiveSignals(from: productData, pageURL: pageURL),
            warnings: warnings(from: productData, pageURL: pageURL)
        )
    }

    private func scorePrice(from productData: ProductData) -> Int {
        var score = 0

        if let price = productData.price {
            score += 10

            if price > 0 {
                score += 4
            }

            if price >= 10 {
                score += 2
            }
        }

        if let currency = productData.currency, !currency.isEmpty {
            score += 5
        }

        if productData.hasJSONLDOfferPrice {
            score += 2
        }

        if let availability = productData.availability, !availability.isEmpty {
            score += 2
        }

        if let price = productData.price, let originalPrice = productData.originalPrice, originalPrice >= price {
            score += 2
        }

        return clampCategory(score)
    }

    private func scoreMetadata(from productData: ProductData) -> Int {
        var score = 0

        if let title = productData.title, !title.isEmpty {
            score += 6
            score += scoreForTextLength(title, good: 18...120, acceptable: 8...180, goodPoints: 3, acceptablePoints: 1)
        }

        if let metaDescription = productData.metaDescription, !metaDescription.isEmpty {
            score += 4
            score += scoreForTextLength(metaDescription, good: 60...260, acceptable: 30...320, goodPoints: 3, acceptablePoints: 1)
        }

        if productData.ogTitle != nil { score += 2 }
        if productData.ogDescription != nil { score += 2 }
        if productData.ogImage != nil { score += 2 }
        if productData.twitterTitle != nil { score += 1 }
        if productData.twitterImage != nil { score += 1 }

        if hasMatchingTitles(productData) {
            score += 2
        }

        if hasMatchingDescriptions(productData) {
            score += 2
        }

        return clampCategory(score)
    }

    private func scoreCompleteness(from productData: ProductData) -> Int {
        var score = 0

        if let description = productData.productDescription, !description.isEmpty {
            score += 4
            score += scoreForTextLength(description, good: 80...900, acceptable: 30...1500, goodPoints: 4, acceptablePoints: 2)
        }

        if let imageURL = productData.imageURL, !imageURL.isEmpty {
            score += 6

            if imageURL.hasPrefix("https://") {
                score += 1
            }
        }

        if let availability = productData.availability, !availability.isEmpty {
            score += 4
        }

        if let siteName = productData.siteName, !siteName.isEmpty {
            score += 3
        }

        if let domain = productData.domain, !domain.isEmpty {
            score += 3
        }

        if productData.price != nil {
            score += 2
        }

        if productData.currency != nil {
            score += 1
        }

        return clampCategory(score)
    }

    private func scoreTrust(from productData: ProductData, pageURL: URL) -> Int {
        var score = 0

        if pageURL.scheme?.lowercased() == "https" {
            score += 6
        }

        if productData.hasJSONLDProduct {
            score += 7
        }

        if productData.hasJSONLDOfferPrice {
            score += 4
        }

        if productData.hasAvailabilityInfo {
            score += 2
        }

        if hasRecognizableStoreIdentity(productData) {
            score += 2
        }

        if hasReasonableDomain(pageURL) {
            score += 2
        }

        if hasMatchingTitles(productData) {
            score += 1
        }

        if hasMatchingDescriptions(productData) {
            score += 1
        }

        return clampCategory(score)
    }

    private func ratingLabel(for totalScore: Int) -> String {
        switch totalScore {
        case 85...:
            return "Excellent"
        case 70...84:
            return "Strong"
        case 55...69:
            return "Moderate"
        case 40...54:
            return "Fair"
        default:
            return "Low Confidence"
        }
    }

    private func confidenceLabel(for score: Int) -> String {
        switch score {
        case 85...:
            return "High Confidence"
        case 65...84:
            return "Medium Confidence"
        default:
            return "Low Confidence"
        }
    }

    private func positiveSignals(from productData: ProductData, pageURL: URL) -> [String] {
        var signals: [String] = []

        if productData.price != nil, productData.currency != nil {
            appendUnique("Price and currency were both identified", to: &signals)
        }

        if productData.hasJSONLDProduct {
            appendUnique("Structured product schema detected", to: &signals)
        }

        if productData.hasJSONLDOfferPrice {
            appendUnique("Structured offer pricing was detected", to: &signals)
        }

        if pageURL.scheme?.lowercased() == "https" {
            appendUnique("HTTPS is enabled", to: &signals)
        }

        if let availability = productData.availability, !availability.isEmpty {
            appendUnique("Availability information is present", to: &signals)
        }

        if hasMatchingTitles(productData) {
            appendUnique("Product titles are consistent across metadata", to: &signals)
        }

        if hasMatchingDescriptions(productData) {
            appendUnique("Descriptions are consistent across metadata", to: &signals)
        }

        if let imageURL = productData.imageURL, imageURL.hasPrefix("https://") {
            appendUnique("Primary product image uses HTTPS", to: &signals)
        }

        if let siteName = productData.siteName, !siteName.isEmpty {
            appendUnique("Store identity was detected", to: &signals)
        }

        return Array(signals.prefix(6))
    }

    private func warnings(from productData: ProductData, pageURL: URL) -> [String] {
        var warnings: [String] = []

        if productData.price == nil {
            appendUnique("Price could not be found on the page", to: &warnings)
        }

        if productData.currency == nil {
            appendUnique("Currency could not be confirmed", to: &warnings)
        }

        if let price = productData.price, price > 0, price < 1 {
            appendUnique("Price looks unusually low and may be a parsing error", to: &warnings)
        }

        if let description = productData.productDescription {
            if description.count < 40 {
                appendUnique("Description is missing or very short", to: &warnings)
            }
        } else {
            appendUnique("Description is missing or very short", to: &warnings)
        }

        if productData.imageURL == nil {
            appendUnique("Primary product image was not detected", to: &warnings)
        }

        if !productData.hasJSONLDProduct {
            appendUnique("Structured product schema was not found", to: &warnings)
        }

        if pageURL.scheme?.lowercased() != "https" {
            appendUnique("Page is not using HTTPS", to: &warnings)
        }

        if !hasMatchingTitles(productData),
           productData.title != nil,
           productData.ogTitle != nil {
            appendUnique("Page title and Open Graph title do not fully match", to: &warnings)
        }

        if !hasRecognizableStoreIdentity(productData) {
            appendUnique("Store identity could not be clearly confirmed", to: &warnings)
        }

        return Array(warnings.prefix(6))
    }

    private func scoreConfidence(from productData: ProductData, pageURL: URL) -> Int {
        var score = 0

        score += confidencePoints(for: productData.sources.title)
        score += confidencePoints(for: productData.sources.description)
        score += confidencePoints(for: productData.sources.imageURL)
        score += confidencePoints(for: productData.sources.siteName)
        score += confidencePoints(for: productData.sources.price)
        score += confidencePoints(for: productData.sources.currency)
        score += confidencePoints(for: productData.sources.availability)

        if productData.hasJSONLDProduct {
            score += 12
        }

        if productData.hasJSONLDOfferPrice {
            score += 8
        }

        if hasMatchingTitles(productData) {
            score += 8
        }

        if hasMatchingDescriptions(productData) {
            score += 6
        }

        if pageURL.scheme?.lowercased() == "https" {
            score += 5
        }

        if let price = productData.price, price > 0 {
            score += 4
        }

        return min(max(score, 0), 100)
    }

    private func confidencePoints(for source: ExtractionSource?) -> Int {
        guard let source else { return 0 }

        switch source {
        case .schema:
            return 12
        case .openGraph:
            return 10
        case .twitter:
            return 7
        case .metaTag:
            return 8
        case .pageTitle:
            return 6
        case .urlQuery:
            return 5
        case .rawHTML:
            return 3
        case .inferredTitle:
            return 4
        case .inferredDomain:
            return 4
        }
    }

    private func scoreForTextLength(
        _ text: String,
        good: ClosedRange<Int>,
        acceptable: ClosedRange<Int>,
        goodPoints: Int,
        acceptablePoints: Int
    ) -> Int {
        let count = text.trimmingCharacters(in: .whitespacesAndNewlines).count

        if good.contains(count) {
            return goodPoints
        }

        if acceptable.contains(count) {
            return acceptablePoints
        }

        return 0
    }

    private func hasMatchingTitles(_ productData: ProductData) -> Bool {
        let values = [
            productData.title,
            productData.ogTitle,
            productData.twitterTitle
        ]
        .compactMap(normalizedText)

        guard values.count >= 2 else { return false }

        let first = values[0]
        return values.dropFirst().contains { $0 == first || $0.contains(first) || first.contains($0) }
    }

    private func hasMatchingDescriptions(_ productData: ProductData) -> Bool {
        let values = [
            productData.productDescription,
            productData.metaDescription,
            productData.ogDescription
        ]
        .compactMap(normalizedText)

        guard values.count >= 2 else { return false }

        let first = values[0]
        return values.dropFirst().contains { $0 == first || $0.prefix(40) == first.prefix(40) }
    }

    private func hasRecognizableStoreIdentity(_ productData: ProductData) -> Bool {
        if let siteName = productData.siteName, siteName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 {
            return true
        }

        if let domain = productData.domain, domain.contains(".") {
            return true
        }

        return false
    }

    private func hasReasonableDomain(_ pageURL: URL) -> Bool {
        guard let host = pageURL.host?.lowercased() else { return false }

        if host == "localhost" {
            return false
        }

        if host.split(separator: ".").count < 2 {
            return false
        }

        if host.contains("127.0.0.1") {
            return false
        }

        return true
    }

    private func normalizedText(_ text: String?) -> String? {
        guard let text else { return nil }

        let trimmed = text
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return trimmed.isEmpty ? nil : trimmed
    }

    private func appendUnique(_ value: String, to array: inout [String]) {
        if !array.contains(value) {
            array.append(value)
        }
    }

    private func clampCategory(_ score: Int) -> Int {
        min(max(score, 0), 25)
    }

    private func clampTotal(_ score: Int) -> Int {
        min(max(score, 0), 100)
    }
}
