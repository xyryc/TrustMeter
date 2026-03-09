//
//  AnalyzerService.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Foundation

struct AnalyzerService {
    private let fetcher = WebPageFetcher()
    private let parser = ProductPageParser()
    private let scorer = TrustScorer()

    func analyze(urlString: String) async throws -> AnalysisResult {
        let normalizedURL = try URLInputNormalizer.normalize(urlString)
        let html = try await fetcher.fetchHTML(from: normalizedURL)
        let productData = parser.parse(html: html, pageURL: normalizedURL)
        let scoreBreakdown = scorer.score(productData: productData, pageURL: normalizedURL)

        return AnalysisResult(
            url: normalizedURL.absoluteString,
            productData: productData,
            scoreBreakdown: scoreBreakdown
        )
    }
}

enum AnalyzerError: LocalizedError {
    case invalidURL
    case networkFailure
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Enter a valid product URL to analyze."
        case .networkFailure:
            return "The product page could not be loaded."
        case .invalidResponse:
            return "The page was loaded, but its content could not be read."
        }
    }
}
