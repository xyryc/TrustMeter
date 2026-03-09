//
//  WebPageFetcher.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Foundation

struct WebPageFetcher {
    func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw AnalyzerError.networkFailure
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
            throw AnalyzerError.invalidResponse
        }

        return html
    }
}
