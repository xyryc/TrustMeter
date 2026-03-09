//
//  AnalyzerViewModel.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Combine
import Foundation

@MainActor
final class AnalyzerViewModel: ObservableObject {
    @Published var productURLText = ""
    @Published private(set) var isAnalyzing = false
    @Published var latestResult: AnalysisResult?
    @Published var errorMessage: String?

    private let analyzerService = AnalyzerService()

    func analyze(minimumDuration: Duration) async {
        guard !isAnalyzing else { return }

        let urlText = productURLText
        let analyzerService = self.analyzerService

        isAnalyzing = true
        errorMessage = nil
        latestResult = nil

        async let minimumDelay: Void = waitForMinimumDuration(minimumDuration)
        async let analysisResult: AnalysisResult = Task.detached(priority: .userInitiated) {
            try await self.analyzerService.analyze(urlString: urlText)
        }.value

        do {
            let result = try await analysisResult
            _ = await minimumDelay
            latestResult = result
        } catch {
            _ = await minimumDelay
            errorMessage = userFacingMessage(for: error)
        }

        isAnalyzing = false
    }

    private func userFacingMessage(for error: Error) -> String {
        if let analyzerError = error as? AnalyzerError {
            return analyzerError.localizedDescription
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection is available right now."
            case .timedOut:
                return "The request timed out while loading the product page."
            default:
                return "Something went wrong while analyzing the page."
            }
        }

        return "Something went wrong while analyzing the page."
    }

    private func waitForMinimumDuration(_ duration: Duration) async {
        try? await Task.sleep(for: duration)
    }
}
