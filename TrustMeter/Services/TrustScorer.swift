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

        let totalScore = priceScore + metadataScore + completenessScore + trustScore

        return ScoreBreakdown(
            priceScore: priceScore,
            metadataScore: metadataScore,
            completenessScore: completenessScore,
            trustScore: trustScore,
            totalScore: totalScore,
            ratingLabel: ratingLabel(for: totalScore),
            positiveSignals: positiveSignals(from: productData, pageURL: pageURL),
            warnings: warnings(from: productData, pageURL: pageURL)
        )
    }

    private func scorePrice(from productData: ProductData) -> Int {
        var score = 0

        if productData.price != nil { score += 15 }
        if productData.currency != nil { score += 10 }

        return min(score, 25)
    }

    private func scoreMetadata(from productData: ProductData) -> Int {
        var score = 0

        if productData.title != nil { score += 8 }
        if productData.metaDescription != nil { score += 5 }
        if productData.ogTitle != nil { score += 4 }
        if productData.ogImage != nil { score += 4 }
        if productData.ogDescription != nil { score += 4 }

        return min(score, 25)
    }

    private func scoreCompleteness(from productData: ProductData) -> Int {
        var score = 0

        if productData.productDescription != nil { score += 8 }
        if productData.imageURL != nil { score += 8 }
        if productData.availability != nil { score += 5 }
        if productData.siteName != nil || productData.domain != nil { score += 4 }

        return min(score, 25)
    }

    private func scoreTrust(from productData: ProductData, pageURL: URL) -> Int {
        var score = 0

        if pageURL.scheme?.lowercased() == "https" { score += 8 }
        if productData.hasJSONLDProduct { score += 8 }
        if productData.hasJSONLDOfferPrice { score += 5 }
        if productData.hasAvailabilityInfo { score += 4 }

        return min(score, 25)
    }

    private func ratingLabel(for totalScore: Int) -> String {
        switch totalScore {
        case 80...:
            return "Excellent"
        case 60...79:
            return "Good"
        case 40...59:
            return "Fair"
        default:
            return "Low Confidence"
        }
    }

    private func positiveSignals(from productData: ProductData, pageURL: URL) -> [String] {
        var signals: [String] = []

        if productData.price != nil, productData.currency != nil {
            signals.append("Price and currency found")
        }

        if productData.ogTitle != nil || productData.ogImage != nil || productData.ogDescription != nil {
            signals.append("Open Graph metadata available")
        }

        if productData.hasJSONLDProduct {
            signals.append("Structured product schema detected")
        }

        if pageURL.scheme?.lowercased() == "https" {
            signals.append("HTTPS is enabled")
        }

        if productData.hasAvailabilityInfo {
            signals.append("Availability information found")
        }

        return signals
    }

    private func warnings(from productData: ProductData, pageURL: URL) -> [String] {
        var warnings: [String] = []

        if productData.price == nil {
            warnings.append("Price could not be found on the page")
        }

        if productData.productDescription?.count ?? 0 < 40 {
            warnings.append("Description is missing or very short")
        }

        if productData.imageURL == nil {
            warnings.append("Primary product image was not detected")
        }

        if pageURL.scheme?.lowercased() != "https" {
            warnings.append("Page is not using HTTPS")
        }

        if !productData.hasJSONLDProduct {
            warnings.append("Structured product schema was not found")
        }

        return warnings
    }
}
