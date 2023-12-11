import Foundation

// MARK: - SimilarItemsResponse
struct SimilarItemsResponse: Codable {
    let getSimilarItemsResponse: GetSimilarItemsResponse
}

// MARK: - GetSimilarItemsResponse
struct GetSimilarItemsResponse: Codable {
    let ack, version, timestamp: String
    let itemRecommendations: ItemRecommendations
    let diagnostic: JSONNull?
}

// MARK: - ItemRecommendations
struct ItemRecommendations: Codable {
    let item: [SimilarProduct]
}

// MARK: - SimilarProduct
struct SimilarProduct: Codable {
    let itemId, title, viewItemURL, globalId: String
    let timeLeft, primaryCategoryId, primaryCategoryName, country: String
    let imageURL, shippingType: String
    let buyItNowPrice, shippingCost: Price
}

// MARK: - Price
struct Price: Codable {
    let currencyId, value: String

    enum CodingKeys: String, CodingKey {
        case currencyId = "@currencyId"
        case value = "__value__"
    }
}

// MARK: - JSONNull
struct JSONNull: Codable, Hashable {
    static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}
