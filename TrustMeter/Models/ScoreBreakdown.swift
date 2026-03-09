//
//  ScoreBreakdown.swift
//  TrustMeter
//
//  Created by Anik on 24/2/26.
//

import Foundation

struct ScoreBreakdown: Codable{
    var priceScore: Int
    var metadataScore: Int
    var completenessScore: Int
    var trustScore: Int
    var priceSummary: String
    var metadataSummary: String
    var completenessSummary: String
    var trustSummary: String
    var totalScore: Int
    var ratingLabel: String
    var confidenceScore: Int
    var confidenceLabel: String
    
    var positiveSignals: [String]
    var warnings: [String]
    
    static let sample = ScoreBreakdown(
        priceScore: 20,
        metadataScore: 22,
        completenessScore: 18,
        trustScore: 22,
        priceSummary: "Price and currency were found with strong support.",
        metadataSummary: "Core metadata is present and mostly consistent.",
        completenessSummary: "The page includes most of the expected product details.",
        trustSummary: "Technical trust signals and store identity look solid.",
        totalScore: 82,
        ratingLabel: "Excellent",
        confidenceScore: 88,
        confidenceLabel: "High Confidence",
        positiveSignals: [
            "Price and currency found",
            "Open Graph metadata available",
            "HTTPS is enabled"
        ],
        warnings: [
            "Description is a bit short"
        ]
    )
}
