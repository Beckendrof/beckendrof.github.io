import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    // Computed property for the total price
    var totalPrice: Double {
        return viewModel.favorites.reduce(0.0) { $0 + (Double($1.price!) ?? 0.0) }
    }
    
    var body: some View {
        VStack {
                if viewModel.isLoading {
                    // Show loading indicator in the center
                    ProgressView("Loading...")
                        .onAppear {
                                viewModel.fetchFavorites()
                            }
                } else if viewModel.favorites.isEmpty {
                    // Show "No Items in Wishlist" message in the center
                    Text("No Items in Wishlist")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List {
                        HStack{
                            Text("Wishlist total(\(viewModel.favorites.count)) items")
                            Spacer()
                            Text(String(format: "$%.2f", totalPrice))
                        }
                        ForEach(viewModel.favorites, id: \.id) { product in
                            HStack {
                                // Image on the left using Kingfisher
                                KFImage(URL(string: product.image ?? "" ))
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(3.0)
                                    .aspectRatio(contentMode: .fit)
                                
                                // Details on the right
                                VStack(alignment: .leading) {
                                    Text((product.title?.prefix(20) ?? "") + (product.title?.count ?? 21 > 20 ? "..." : ""))
                                        .lineLimit(1) // Ensure title is limited to 1 line
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("$\(product.price ?? "")")
                                                .bold()
                                                .font(.system(size: 15)) // Smaller font size for price
                                                .foregroundColor(.blue)
                                            Text(product.shipping ?? "")
                                                .textCase(.uppercase)
                                                .font(.system(size: 13)) // Smaller font size for shipping
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    HStack {
                                        Text((product.Zip?.prefix(3) ?? "") + (product.Zip?.count ?? 1 > 3 ? "**" : ""))
                                            .font(.system(size: 13)) // Smaller font size for zip
                                            .foregroundColor(.gray)
                                        Spacer()
                                        if let conditionId = product.condition {
                                            switch conditionId {
                                            case "1000":
                                                Text("NEW")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            case "2000", "2500":
                                                Text("REFURBISHED")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            case "3000", "4000", "5000", "6000":
                                                Text("USED")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            default:
                                                Text("NA")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            }
                                        } else {
                                            // Handle the case where conditionId is nil (optional chaining)
                                            Text("NA")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                
                                Spacer() // Spacer to push details to the right
                            }
                            .padding(.vertical, 10)
                        }
                        .onDelete{ indices in
                            // Access items at the specified indices and perform actions
                            for index in indices {
                                let deletedItem = viewModel.favorites[index]
                                viewModel.deleteFavorite(itemId: deletedItem.itemId)
                            }
                            viewModel.favorites.remove(atOffsets: indices)
                        }
                    }
                }
        }
        .navigationBarTitle("Favorites")
        .onAppear{
            viewModel.isLoading = true
        }
    }
}
