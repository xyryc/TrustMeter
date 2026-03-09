//
//  ProductPageParser.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import Foundation

struct ProductPageParser {
    func parse(html: String, pageURL: URL) -> ProductData {
        let metadataHTML = limitedMetadataHTML(from: html)
        let urlPrice = extractPriceFromURL(pageURL)
        let inferredCurrency = inferredCurrency(for: pageURL)

        let title = extractTagContent(named: "title", in: metadataHTML)
        let metaDescription = extractMetaContent(in: metadataHTML, key: "description")
        let ogTitle = extractMetaContent(in: metadataHTML, key: "og:title")
        let ogImage = extractMetaContent(in: metadataHTML, key: "og:image")
        let ogDescription = extractMetaContent(in: metadataHTML, key: "og:description")
        let twitterTitle = extractMetaContent(in: metadataHTML, key: "twitter:title")
        let twitterImage = extractMetaContent(in: metadataHTML, key: "twitter:image")

        let schemaProduct = extractProductSchema(from: metadataHTML)
        let schemaOffer = extractOfferSchema(from: schemaProduct)

        let titleResult = pickFirst([
            (schemaProduct?.stringValue(for: "name"), .schema),
            (ogTitle, .openGraph),
            (twitterTitle, .twitter),
            (title, .pageTitle)
        ])

        let descriptionResult = pickFirst([
            (schemaProduct?.stringValue(for: "description"), .schema),
            (ogDescription, .openGraph),
            (metaDescription, .metaTag)
        ])

        let imageResult = pickFirst([
            (schemaProduct?.stringValue(for: "image"), .schema),
            (ogImage, .openGraph),
            (twitterImage, .twitter)
        ])

        let siteNameResult = pickFirst([
            (extractMetaContent(in: metadataHTML, key: "og:site_name"), .openGraph),
            (extractMetaContent(in: metadataHTML, key: "application-name"), .metaTag),
            (extractMetaContent(in: metadataHTML, key: "apple-mobile-web-app-title"), .metaTag),
            (extractSiteNameFromTitle(title), .inferredTitle),
            (cleanHostName(from: pageURL), .inferredDomain)
        ])

        let priceResult = pickFirst([
            (schemaOffer?.stringValue(for: "price"), .schema),
            (extractMetaContent(in: metadataHTML, key: "product:price:amount"), .metaTag),
            (urlPrice.map { String($0) }, .urlQuery),
            (extractFirstPrice(in: html), .rawHTML)
        ])

        let currencyResult = pickFirst([
            (schemaOffer?.stringValue(for: "priceCurrency"), .schema),
            (extractMetaContent(in: metadataHTML, key: "product:price:currency"), .metaTag),
            (currencyCode(for: priceResult.value), .rawHTML),
            (inferredCurrency, .inferredDomain)
        ])

        let availabilityResult = pickFirst([
            (schemaOffer?.stringValue(for: "availability"), .schema),
            (extractMetaContent(in: metadataHTML, key: "product:availability"), .metaTag)
        ])
        let normalizedAvailability = availabilityResult.value?.cleanAvailabilityValue

        return ProductData(
            title: titleResult.value,
            productDescription: descriptionResult.value,
            imageURL: imageResult.value?.absoluteURLString(relativeTo: pageURL),
            siteName: siteNameResult.value,
            domain: pageURL.host,
            price: priceResult.value.flatMap(parsePrice),
            currency: currencyResult.value,
            availability: normalizedAvailability,
            ogTitle: ogTitle,
            ogImage: ogImage?.absoluteURLString(relativeTo: pageURL),
            ogDescription: ogDescription,
            twitterTitle: twitterTitle,
            twitterImage: twitterImage?.absoluteURLString(relativeTo: pageURL),
            metaDescription: metaDescription,
            hasJSONLDProduct: schemaProduct != nil,
            hasJSONLDOfferPrice: schemaOffer?.stringValue(for: "price") != nil,
            hasAvailabilityInfo: normalizedAvailability != nil,
            sources: ExtractionSources(
                title: titleResult.source,
                description: descriptionResult.source,
                imageURL: imageResult.source,
                siteName: siteNameResult.source,
                price: priceResult.source,
                currency: currencyResult.source,
                availability: availabilityResult.source
            )
        )
    }

    private func limitedMetadataHTML(from html: String) -> String {
        let limit = 250_000
        return String(html.prefix(limit))
    }

    private func extractTagContent(named tagName: String, in html: String) -> String? {
        guard let startRange = html.range(of: "<\(tagName)", options: [.caseInsensitive]),
              let contentStart = html[startRange.lowerBound...].range(of: ">", options: [])?.upperBound,
              let endRange = html[contentStart...].range(of: "</\(tagName)>", options: [.caseInsensitive]) else {
            return nil
        }

        return String(html[contentStart..<endRange.lowerBound])
            .simpleHTMLDecoded()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractMetaContent(in html: String, key: String) -> String? {
        var searchStart = html.startIndex

        while let metaRange = html[searchStart...].range(of: "<meta", options: [.caseInsensitive]) {
            guard let tagEnd = html[metaRange.lowerBound...].range(of: ">")?.upperBound else {
                break
            }

            let tag = String(html[metaRange.lowerBound..<tagEnd])

            if tag.containsAttribute(named: "property", value: key) || tag.containsAttribute(named: "name", value: key) {
                if let content = tag.attributeValue(named: "content") {
                    return content.simpleHTMLDecoded().trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            searchStart = tagEnd
        }

        return nil
    }

    private func extractProductSchema(from html: String) -> [String: Any]? {
        var searchStart = html.startIndex

        while let scriptRange = html[searchStart...].range(of: "<script", options: [.caseInsensitive]) {
            guard let tagEnd = html[scriptRange.lowerBound...].range(of: ">")?.upperBound else {
                break
            }

            let openingTag = String(html[scriptRange.lowerBound..<tagEnd])

            guard openingTag.contains("application/ld+json") else {
                searchStart = tagEnd
                continue
            }

            guard let closingRange = html[tagEnd...].range(of: "</script>", options: [.caseInsensitive]) else {
                break
            }

            let jsonString = String(html[tagEnd..<closingRange.lowerBound])
                .simpleHTMLDecoded()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = jsonString.data(using: .utf8),
                  let object = try? JSONSerialization.jsonObject(with: data) else {
                searchStart = closingRange.upperBound
                continue
            }

            if let product = findProductObject(in: object) {
                return product
            }

            searchStart = closingRange.upperBound
        }

        return nil
    }

    private func findProductObject(in object: Any) -> [String: Any]? {
        if let dictionary = object as? [String: Any] {
            if dictionary.matchesSchemaType("Product") {
                return dictionary
            }

            if let graph = dictionary["@graph"] {
                return findProductObject(in: graph)
            }

            for value in dictionary.values {
                if let product = findProductObject(in: value) {
                    return product
                }
            }
        }

        if let array = object as? [Any] {
            for item in array {
                if let product = findProductObject(in: item) {
                    return product
                }
            }
        }

        return nil
    }

    private func extractOfferSchema(from product: [String: Any]?) -> [String: Any]? {
        guard let offers = product?["offers"] else { return nil }

        if let dictionary = offers as? [String: Any] {
            return dictionary
        }

        if let array = offers as? [[String: Any]] {
            return array.first
        }

        return nil
    }

    private func extractFirstPrice(in html: String) -> String? {
        let searchableHTML = String(html.prefix(300_000))
        let pattern = #"(?:([$€£])\s?([0-9]+(?:[.,][0-9]{2})?)|(?:BDT|Tk\.?)\s?([0-9]+(?:[.,][0-9]{2})?))"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(searchableHTML.startIndex..., in: searchableHTML)
        guard let match = regex.firstMatch(in: searchableHTML, options: [], range: range) else {
            return nil
        }

        if let symbolRange = Range(match.range(at: 1), in: searchableHTML),
           let amountRange = Range(match.range(at: 2), in: searchableHTML) {
            return String(searchableHTML[symbolRange]) + String(searchableHTML[amountRange])
        }

        if let amountRange = Range(match.range(at: 3), in: searchableHTML) {
            return String(searchableHTML[amountRange])
        }

        return nil
    }

    private func parsePrice(from string: String) -> Double? {
        let filtered = string.filter { "0123456789.,".contains($0) }
        let normalized = normalizeDecimalString(filtered)
        return Double(normalized)
    }

    private func currencyCode(for priceString: String?) -> String? {
        guard let priceString else { return nil }

        if priceString.contains("$") { return "USD" }
        if priceString.contains("€") { return "EUR" }
        if priceString.contains("£") { return "GBP" }
        if priceString.localizedCaseInsensitiveContains("BDT") || priceString.localizedCaseInsensitiveContains("Tk") {
            return "BDT"
        }

        return nil
    }

    private func firstNonEmpty(_ values: String?...) -> String? {
        values.first { value in
            guard let value else { return false }
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } ?? nil
    }

    private func pickFirst(_ candidates: [(String?, ExtractionSource)]) -> (value: String?, source: ExtractionSource?) {
        for candidate in candidates {
            if let value = candidate.0?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
                return (value, candidate.1)
            }
        }

        return (nil, nil)
    }

    private func normalizeDecimalString(_ value: String) -> String {
        if value.contains(",") && value.contains(".") {
            return value.replacingOccurrences(of: ",", with: "")
        }

        if value.filter({ $0 == "," }).count == 1 && !value.contains(".") {
            return value.replacingOccurrences(of: ",", with: ".")
        }

        return value.replacingOccurrences(of: ",", with: "")
    }

    private func extractSiteNameFromTitle(_ title: String?) -> String? {
        guard let title else { return nil }

        let separators = [" | ", " - ", " – ", " — "]

        for separator in separators {
            let parts = title.components(separatedBy: separator).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if parts.count >= 2, let lastPart = parts.last, lastPart.count >= 2 {
                return lastPart
            }
        }

        return nil
    }

    private func extractPriceFromURL(_ url: URL) -> Double? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let priceValue = components.queryItems?.first(where: { $0.name == "price" })?.value else {
            return nil
        }

        return parsePrice(from: priceValue)
    }

    private func inferredCurrency(for url: URL) -> String? {
        guard let host = url.host?.lowercased() else { return nil }

        if host.hasSuffix(".com.bd") || host.hasSuffix(".bd") {
            return "BDT"
        }

        return nil
    }

    private func cleanHostName(from url: URL) -> String? {
        guard let host = url.host?.lowercased() else { return nil }

        let parts = host
            .split(separator: ".")
            .filter { part in
                let value = String(part)
                return value != "www" && value != "m"
            }

        guard let firstPart = parts.first else { return nil }

        let rawName = String(firstPart)
        let capitalizedName = rawName.prefix(1).uppercased() + rawName.dropFirst()
        return capitalizedName
    }
}

private extension Dictionary where Key == String, Value == Any {
    func matchesSchemaType(_ expectedType: String) -> Bool {
        if let type = self["@type"] as? String {
            return type.caseInsensitiveCompare(expectedType) == .orderedSame
        }

        if let types = self["@type"] as? [String] {
            return types.contains { $0.caseInsensitiveCompare(expectedType) == .orderedSame }
        }

        return false
    }

    func stringValue(for key: String) -> String? {
        if let string = self[key] as? String {
            return string
        }

        if let array = self[key] as? [String] {
            return array.first
        }

        return nil
    }
}

private extension String {
    func absoluteURLString(relativeTo baseURL: URL) -> String {
        if let absoluteURL = URL(string: self, relativeTo: baseURL)?.absoluteURL {
            return absoluteURL.absoluteString
        }

        return self
    }

    func simpleHTMLDecoded() -> String {
        self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }

    var cleanAvailabilityValue: String {
        components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? self
    }

    func containsAttribute(named name: String, value: String) -> Bool {
        let lowercasedTag = lowercased()
        let lowercasedName = name.lowercased()
        let lowercasedValue = value.lowercased()

        return lowercasedTag.contains("\(lowercasedName)=\"\(lowercasedValue)\"")
            || lowercasedTag.contains("\(lowercasedName)='\(lowercasedValue)'")
    }

    func attributeValue(named name: String) -> String? {
        let patterns = [
            "\(name)=\"",
            "\(name)='"
        ]

        for pattern in patterns {
            guard let startRange = range(of: pattern, options: [.caseInsensitive]) else {
                continue
            }

            let valueStart = startRange.upperBound
            let quoteCharacter: Character = pattern.last == "\"" ? "\"" : "'"

            if let valueEnd = self[valueStart...].firstIndex(of: quoteCharacter) {
                return String(self[valueStart..<valueEnd])
            }
        }

        return nil
    }
}
