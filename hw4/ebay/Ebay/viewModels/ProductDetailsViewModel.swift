import Foundation
import Combine

class ProductDetailsViewModel: ObservableObject {
    @Published var product: Product
    @Published var similarImages: SimilarImage?
    @Published var similarProducts: [SimilarProduct] = []
    @Published var isLoading: Bool = false

    init(product: Product) {
        self.product = product
    }

    func sortSimilarProducts(by option: String, order: String) {
        switch option {
        case "Default":
            // No sorting needed for the default option
            break
        case "Title":
            similarProducts.sort(by: { $0.title < $1.title })
        case "Price":
            similarProducts.sort(by: { getProductPrice($0) < getProductPrice($1) })
        case "DaysLeft":
            similarProducts.sort { (product1, product2) -> Bool in
                let daysLeft1 = convertToDaysLeft(product1)
                let daysLeft2 = convertToDaysLeft(product2)
                return daysLeft1 < daysLeft2
            }
        default:
            // Default case for unrecognized options
            break
        }

        if order == "Descending" {
            similarProducts.reverse()
        }
    }
    
    func fetchFavorites() {
        EbayService.shared.fetchFavorites()
            .done { data in
                if let index = data.firstIndex(where: { $0.itemId == self.product.itemId }) {
                    self.product._id = data[index]._id
                }
                print(self.product)
            }
            .catch { error in
                print(error)
            }
    }
    
    func deleteFavorite(itemId: String?) {
        EbayService.shared.deleteFavorite(id: itemId!)
            .done {
                print("Item with \(itemId!) removed")
            }
            .catch { error in
                print(error)
            }
    }
    
    func postFavorite(product: Product) {
        // Remove the selected favorites from the array
        EbayService.shared.postFavorite(product: product)
            .done {
                self.fetchFavorites()
            }
            .catch { error in
                print(error)
            }
    }

    private func convertToDaysLeft(_ product: SimilarProduct) -> Int {
        if let rangeP = product.timeLeft.range(of: "P"),
           let rangeD = product.timeLeft.range(of: "D", range: rangeP.upperBound..<product.timeLeft.endIndex),
           let daysSubstring = Int(product.timeLeft[rangeP.upperBound..<rangeD.lowerBound]) {
            return daysSubstring
        }
        return 0 // Default value if conversion fails
    }

    private func getProductPrice(_ product: SimilarProduct) -> Double {
        // Assuming buyItNowPrice is a Double
        return Double(product.buyItNowPrice.value) ?? 0.0
    }
    
    func extractDaysLeft(from durationString: String) -> Int? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withFractionalSeconds]

        if let duration = formatter.date(from: "1970-01-01\(durationString)"),
            let days = Calendar.current.dateComponents([.day], from: Date(), to: duration).day {
            return days
        }

        return nil
    }
    
    func getProductDetails() {
        EbayService.shared.getProductDetails(ItemID: (product.ItemId ?? ""))
            .done { details in
                // Merge the details with the existing product
                self.product.Item = details.Item
            }
            .catch { error in
                print(error)
                // Handle API error
            }
    }
    
    func getSimilarImages() {
        EbayService.shared.getSimilarImages(productTitle: (product.Title ?? ""))
            .done { data in
                // Process the similar images
                self.similarImages = data
            }
            .catch { error in
                print(error)
                // Handle API error
            }
    }

    func getSimilarProducts() {
        EbayService.shared.getSimilarProducts(itemId: (product.itemId ?? ""))
            .done { data in
                // Process the similar items
                self.similarProducts = data.getSimilarItemsResponse.itemRecommendations.item
            }
            .catch { error in
                print(error)
                // Handle API error
            }
    }

}
