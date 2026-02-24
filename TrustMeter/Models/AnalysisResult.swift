//
//  AnalysisResult.swift
//  TrustMeter
//
//  Created by Anik on 24/2/26.
//

import Foundation

struct AnalysisResult: Codable, Identifiable{
    var id: UUID
    var url: String
    var analyzedAt: Date
    var productData: ProductData
    var scoreBreakdown: ScoreBreakdown
    
    init(
        id: UUID = UUID(),
        url: String,
        analyzedAt: Date = Date(),
        productData: ProductData,
        scoreBreakdown: ScoreBreakdown
    ){
        self.id = id
        self.url = url
        self.analyzedAt = analyzedAt
        self.productData = productData
        self.scoreBreakdown = scoreBreakdown
    }
    
    static let sample = AnalysisResult(
        url: "https://store.example.com/products/noise-cancelling-headphones",
        productData: ProductData(
            title: "Noise Cancelling Headphones",
            productDescription: "Wireless over-ear headphones with adaptive noise cancelling.",
            imageURL: "https://picsum.photos/400/300",
            siteName: "Example Store",
            domain: "store.example.com",
            price: 129.99,
            currency: "USD"
        ),
        scoreBreakdown: .sample
    )
}
