//
//  ProductData.swift
//  TrustMeter
//
//  Created by Anik on 24/2/26.
//

import Foundation

struct ProductData: Codable {
    var title: String?
    var productDescription: String?
    var imageURL: String?
    var siteName: String?
    var domain: String?
    
    var price: Double?
    var currency: String?
    var originalPrice: Double?
    var availability: String?
    
    var ogTitle: String?
    var ogImage: String?
    var ogDescription: String?
    var twitterTitle: String?
    var twitterImage: String?
    var metaDescription: String?
    
    var hasJSONLDProduct: Bool
    var hasJSONLDOfferPrice: Bool
    var hasAvailabilityInfo: Bool
    
    init(
        title: String? = nil,
        productDescription: String? = nil,
        imageURL: String? = nil,
        siteName: String? = nil,
        domain: String? = nil,
        price: Double? = nil,
        currency: String? = nil,
        originalPrice: Double? = nil,
        availability: String? = nil,
        ogTitle: String? = nil,
        ogImage: String? = nil,
        ogDescription: String? = nil,
        twitterTitle: String? = nil,
        twitterImage: String? = nil,
        metaDescription: String? = nil,
        hasJSONLDProduct: Bool = false,
        hasJSONLDOfferPrice: Bool = false,
        hasAvailabilityInfo: Bool = false
    ){
        self.title = title
        self.productDescription = productDescription
        self.imageURL = imageURL
        self.siteName = siteName
        self.domain = domain
        self.price = price
        self.currency = currency
        self.originalPrice = originalPrice
        self.availability = availability
        self.ogTitle = ogTitle
        self.ogImage = ogImage
        self.ogDescription = ogDescription
        self.twitterTitle = twitterTitle
        self.twitterImage = twitterImage
        self.metaDescription = metaDescription
        self.hasJSONLDProduct = hasJSONLDProduct
        self.hasJSONLDOfferPrice = hasJSONLDOfferPrice
        self.hasAvailabilityInfo = hasAvailabilityInfo
    }
}
