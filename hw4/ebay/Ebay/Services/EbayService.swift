// Service.swift

import Foundation
import Alamofire
import PromiseKit

enum MyError: Error {
    case invalidResponse
}

class EbayService {
    static let shared = EbayService()

    private init() {}
    
    struct FavoritePostData: Encodable {
        let image: String?
        let title: String?
        let price: String?
        let shipping: String?
        let ItemId: String?
    }
    
    func fetchAutocompleteResults(for query: String) -> Promise<[String]> {
        let url = "https://homework-03-404509.wl.r.appspot.com/autocomplete"
        let parameters: [String: Any] = ["q": query]

        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: [String].self) { response in
                    switch response.result {
                    case .success(let results):
                        seal.fulfill(results)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    func searchProducts(keyword: String, additionalParams: [String: Any]? = nil) -> Promise<[Product]> {
        let url = "https://homework-03-404509.wl.r.appspot.com/search"
        var parameters: [String: Any] = [
            "keyword": keyword,
        ]
        
        if let additionalParams = additionalParams {
            parameters.merge(additionalParams) { _, new in new }
        }
        
        print("Searching for \(keyword)...")

        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: [Product].self) { response in
                    switch response.result {
                    case .success(let products):
                        seal.fulfill(products)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
    
    func fetchFavorites() -> Promise<[Product]> {
        let url = "https://homework-03-404509.wl.r.appspot.com/wishlistGet"
        print ("\nFetching favorite items...")
        
        return Promise { seal in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: [Product].self) { response in
                    switch response.result {
                    case .success(let data):
                        seal.fulfill(data)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
    
    func deleteFavorite(id: String) -> Promise<Void> {
        let url = "https://homework-03-404509.wl.r.appspot.com/wishlistDel"
        let parameters: [String: Any] = [
            "q": id,
        ]
        print("\nDeleting favorite item with ID: \(id)...")
        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        seal.fulfill(())
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    func postFavorite(product: Product) -> Promise<Void> {
        let url = "https://homework-03-404509.wl.r.appspot.com/wishlistPost"
        print("\nPosting favorite item...")

        // Create a FavoritePostData instance with the desired fields
        let postData = FavoritePostData(
            image: product.Image,
            title: product.Title,
            price: product.Price,
            shipping: product.Shipping,
            ItemId: product.itemId
        )

        return Promise { seal in
            AF.request(url, method: .get, parameters: postData)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        seal.fulfill(())
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    
    func getSimilarImages(productTitle: String) -> Promise<SimilarImage> {
        let url = "https://homework-03-404509.wl.r.appspot.com/searchImage"
        let parameters: [String: Any] = [
            "q": productTitle,
        ]

        print("\nGetting similar images for \(productTitle)...")

        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: SimilarImage.self) { response in
                    switch response.result {
                    case .success(let similarImages):
                        seal.fulfill(similarImages)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    func getSimilarProducts(itemId: String) -> Promise<SimilarItemsResponse> {
        let url = "https://homework-03-404509.wl.r.appspot.com/getSimilarItems"
        let parameters: [String: Any] = [
            "q": itemId,
        ]

        print("\nGetting similar items for item \(itemId)...")

        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: SimilarItemsResponse.self) { response in
                    switch response.result {
                    case .success(let similarItems):
                        seal.fulfill(similarItems)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    
    func getProductDetails(ItemID: String) -> Promise<Product> {
        let url = "https://homework-03-404509.wl.r.appspot.com/productDetails"
        let parameters: [String: Any] = [
            "itemId": ItemID,
        ]

        print("\nFetching details for Item \(ItemID)...")

        return Promise { seal in
            AF.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: Product.self) { response in
                    switch response.result {
                    case .success(let productDetails):
                        seal.fulfill(productDetails)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
}
