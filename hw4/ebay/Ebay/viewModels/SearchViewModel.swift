import Foundation
import SwiftUI
import PromiseKit
import Alamofire

class SearchViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var selectedCategory: String = "All"
    @Published var newCondition: Bool = false
    @Published var usedCondition: Bool = false
    @Published var unspecifiedCondition: Bool = false
    @Published var pickupShipping: Bool = false
    @Published var freeShipping: Bool = false
    @Published var distance: String = ""
    @Published var customLocation: Bool = false
    @Published var zipcode: String = ""
    @Published var isKeywordEmpty: Bool = false
    @Published var showAlert: Bool = false
    @Published var showResults: Bool = false
    @Published var favorites: [Product] = []
    @Published var geolocation: GeolocationResponse?
    @Published var searchResults: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var autocompleteResults: [String] = []
    
    static let categoryMap: [String: String] = [
        "All Categories": "",
        "Art": "550",
        "Baby": "2984",
        "Books": "267",
        "Clothing, Shoes & Accessories": "11450",
        "Computers/Tablets & Networking": "58058",
        "Health & Beauty": "26395",
        "Music": "11233",
        "Video Games and Consoles": "1249"
    ]

    static let categories = ["All", "Art", "Baby", "Books", "Clothing, Shoes & Accesories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles"]
    
    enum MyError: Error {
        case customLocationError
    }
    
    func fetchAutocompleteResults(for query: String) {
        // Call the necessary function in EbayService or other service to fetch autocomplete results
        EbayService.shared.fetchAutocompleteResults(for: query)
            .done { results in
                // Update the autocompleteResults in the viewModel
                self.autocompleteResults = results
            }
            .catch { error in
                // Handle error if necessary
                print(error)
            }
    }

    func search() {
        fetchFavorites()
        self.isLoading = true

        // Call processParams, which now returns a Promise
        processParams()
            .done { processedParams in
                EbayService.shared.searchProducts(keyword: self.keyword, additionalParams: processedParams /* other parameters */)
                    .done { products in
                        self.searchResults = products // Store the results
                        for index in self.searchResults.indices {
                            if self.favorites.first(where: { $0.title == self.searchResults[index].Title }) != nil {
                                self.searchResults[index].favorite = "true"
                            } else {
                                self.searchResults[index].favorite = "false"
                            }
                        }
                        self.isLoading = false
                    }
                    .catch { error in
                        print(error)
                    }
            }
            .catch { error in
                print(error)
            }
    }

    
    func processParams() -> Promise<[String: Any]> {
        var params: [String: Any] = [:]
        var argCount = 0
        var value = 0

        // Condition filters
        let checkedConditions = [
            ("newCondition", "1000"),
            ("usedCondition", "3000"),
            ("unspecifiedCondition", "Unspecified")
        ]

        for (conditionKey, conditionValue) in checkedConditions {
            if (self[keyPath: \.newCondition] && conditionKey == "newCondition" ||
                self[keyPath: \.usedCondition] && conditionKey == "usedCondition" ||
                self[keyPath: \.unspecifiedCondition] && conditionKey == "unspecifiedCondition") {
                params["itemFilter(\(argCount)).value(\(value))"] = conditionValue
                value += 1
            }
        }
        
        if (value != 0) {
            params["itemFilter(\(argCount)).name"] = "Condition"
            argCount += 1
            value = 0
        }
        
        // Category filter
        if let categoryId = Self.categoryMap[selectedCategory] {
            params["categoryId"] = categoryId
        }

        // Shipping filters
        let shippingConditions = [
            ("pickupShipping", "LocalPickupOnly"),
            ("freeShipping", "FreeShippingOnly")
        ]
        
        for (shippingKey, shippingValue) in shippingConditions {
            if self[keyPath: \.pickupShipping] && shippingKey == "pickupShipping" ||
                self[keyPath: \.freeShipping] && shippingKey == "freeShipping" {
                params["itemFilter(\(argCount)).name"] = shippingValue
                params["itemFilter(\(argCount)).value(\(value))"] = "true"
                value = 0
                argCount += 1
            }
        }
        
        // MaxDistance filter
        params["itemFilter(\(argCount)).name"] = "MaxDistance"
        params["itemFilter(\(argCount)).value(\(value))"] = self[keyPath: \.distance].isEmpty ? "10" : self[keyPath: \.distance]

        // Custom location handling
        return Promise { seal in
            let locationValue = self[keyPath: \.customLocation]

            if locationValue {
                let customLocation = self[keyPath: \.zipcode]
                if !customLocation.isEmpty {
                    params["buyerPostalCode"] = customLocation
                    seal.fulfill(params)  // Fulfill the promise with the current params
                } else {
                    seal.reject(MyError.customLocationError)
                }
            } else {
                fetchGeolocation()
                    .done { geolocation in
                        params["buyerPostalCode"] = geolocation.postal
                        seal.fulfill(params)  // Fulfill the promise with the updated params
                    }.catch { error in
                        print(error)
                        seal.reject(error)  // Reject the promise if there's an error
                    }
            }
        }
    }
    
    private func fetchGeolocation() -> Promise<GeolocationResponse> {
        return Promise { seal in
            let url = "https://ipinfo.io/json?token=6147bb55e38ee8"
            AF.request(url)
                .validate()
                .responseDecodable(of: GeolocationResponse.self) { response in
                    switch response.result {
                    case .success(let geolocation):
                        seal.fulfill(geolocation)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
    
    func deleteFavorite(itemId: String?) {
        fetchFavorites()
        // Find the favorite with the matching itemId
        if let favoriteToDelete = self.favorites.first(where: { $0.ItemId == itemId }) {
            let favoriteIdToDelete = favoriteToDelete._id

            // Remove the selected favorite from the array
            EbayService.shared.deleteFavorite(id: favoriteIdToDelete!)
                .done {
                    if let index = self.searchResults.firstIndex(where: { $0.itemId == itemId }) {
                        self.searchResults[index].favorite = "false"

                        // Remove the selected favorite from the array after successful deletion
                        if let indexToRemove = self.favorites.firstIndex(where: { $0.ItemId == itemId }) {
                            self.favorites.remove(at: indexToRemove)
                        }
                    }
                }
                .catch { error in
                    print(error)
                }
        } else {
            print("Favorite not found for itemId: \(itemId ?? "nil")")
        }
    }
    
    func postFavorite(product: Product) {
        // Remove the selected favorites from the array
        EbayService.shared.postFavorite(product: product)
            .done { }
            .catch { error in
                print(error)
            }
    }
    
    func fetchFavorites() {
        EbayService.shared.fetchFavorites()
            .done { data in
                self.favorites = data
                self.isLoading = false
                if !self.searchResults.isEmpty {
                    for index in self.searchResults.indices {
                        if self.favorites.first(where: { $0.title == self.searchResults[index].Title }) != nil {
                            self.searchResults[index].favorite = "true"
                        } else {
                            self.searchResults[index].favorite = "false"
                        }
                    }
                }
            }
            .catch { error in
                print(error)
            }
    }


    func clear() {
        keyword = ""
        selectedCategory = "All"
        newCondition = false
        usedCondition = false
        unspecifiedCondition = false
        pickupShipping = false
        freeShipping = false
        distance = ""
        customLocation = false
        zipcode = ""
        errorMessage = nil
    }
}
