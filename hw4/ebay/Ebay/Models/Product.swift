import Foundation

struct Product: Codable {
    var _id: String?
    var id: String? {
        return itemId ?? _id
    }
    var favorite: String?
    let itemURL: String?
    let shippingCost: String?
    let shippingLocations: String?
    let handlingTime: [String]?
    let expeditedShipping: String?
    let oneDayShipping: String?
    let returnAccepted: String?
    let ItemId: String?
    var itemId: String? {
        // Provide a computed property to handle both cases
        return Item?.ItemID ?? ItemId 
    }
    let image: String?
    let title: String?
    let price: String?
    let shipping: String?
    let Image: String?
    let Title: String?
    let Price: String?
    let Shipping: String?
    let Zip: String?
    let condition: String?
    let Timestamp: String?
    let Ack: String?
    let Build: String?
    let Version: String?
    var Item: ItemDetails?
    
    struct ItemDetails: Codable {
        let BestOfferEnabled: Bool?
        let ItemID: String?
        let EndTime: String?
        let StartTime: String?
        let ViewItemURLForNaturalSearch: String?
        let ListingType: String?
        let Location: String?
        let PaymentMethods: [String]?
        let PictureURL: [String]?
        let PostalCode: String?
        let PrimaryCategoryID: String?
        let PrimaryCategoryName: String?
        let Quantity: Int?
        let Seller: SellerDetails?
        let BidCount: Int?
        let ConvertedCurrentPrice: PriceDetails?
        let CurrentPrice: PriceDetails?
        let ListingStatus: String?
        let QuantitySold: Int?
        let ShipToLocations: [String]?
        let Site: String?
        let TimeLeft: String?
        let Title: String?
        let ItemSpecifics: ItemSpecifics?
        let PrimaryCategoryIDPath: String?
        let Storefront: StorefrontDetails?
        let Country: String?
        let ReturnPolicy: ReturnPolicy?
        let AutoPay: Bool?
        let PaymentAllowedSite: [String]?
        let IntegratedMerchantCreditCardEnabled: Bool?
        let HandlingTime: Int?
        let ConditionID: Int?
        let ConditionDisplayName: String?
        let QuantityAvailableHint: String?
        let ExcludeShipToLocation: [String]?
        let TopRatedListing: Bool?
        let GlobalShipping: Bool?
        let QuantitySoldByPickupInStore: Int?
        let SKU: String?
        let NewBestOffer: Bool?
    }

    struct SellerDetails: Codable {
        let UserID: String?
        let FeedbackRatingStar: String?
        let FeedbackScore: Int?
        let PositiveFeedbackPercent: Double?
        let TopRatedSeller: Bool?

    }

    struct PriceDetails: Codable {
        let Value: Double?
        let CurrencyID: String?
    }

    struct ItemSpecifics: Codable {
        let NameValueList: [NameValueList]

        struct NameValueList: Codable, Identifiable {
            let id = UUID()
            let Name: String?
            let Value: [String]?
        }
    }

    struct StorefrontDetails: Codable {
        let StoreURL: String?
        let StoreName: String?
    }

    struct ReturnPolicy: Codable {
        let Refund: String?
        let ReturnsWithin: String?
        let ReturnsAccepted: String?
        let ShippingCostPaidBy: String?
        let InternationalReturnsAccepted: String?
    }
    
}
