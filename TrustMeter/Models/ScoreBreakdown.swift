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
    var totalScore: Int
    var ratingLabel: String
    
    var positiveSignals: [String]
    var warnings: [String]
    
    static let sample = ScoreBreakdown(
        priceScore: 20,
        metadataScore: 22,
        completenessScore: 18,
        trustScore: 22,
        totalScore: 82,
        ratingLabel: "Excellent",
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
