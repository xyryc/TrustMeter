//
//  URLInputNormalizer.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Foundation

enum URLInputNormalizer {
    static func normalize(_ input: String) throws -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw AnalyzerError.invalidURL
        }

        let candidate: String
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            candidate = trimmed
        } else {
            candidate = "https://\(trimmed)"
        }

        guard let url = URL(string: candidate), let scheme = url.scheme, let host = url.host,
              !scheme.isEmpty, !host.isEmpty else {
            throw AnalyzerError.invalidURL
        }

        return url
    }
}
