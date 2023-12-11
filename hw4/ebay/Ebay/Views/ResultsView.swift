import SwiftUI
import Kingfisher

struct ResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var isInFavorites: Bool
    @Binding var showFavAlert: Bool
    @State private var isFavorite: Bool = false
    
    var body: some View {
        Text("Results")
            .bold()
            .font(.title)
            .padding(.vertical, 5)
        if viewModel.isLoading {
            HStack { 
                Spacer()
                ProgressView("Loading...")
                Spacer()
            }
        } else if viewModel.searchResults.count < 1 {
            Text("No results found")
                .foregroundColor(.red)
                .padding(.vertical, 5)
        } else {
            ForEach($viewModel.searchResults, id: \.id) { $product in
                HStack {
                    // Image on the left using Kingfisher
                    KFImage(URL(string: product.Image ?? "" ))
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(3.0)
                        .aspectRatio(contentMode: .fit)
                    
                    // Details on the right
                    VStack(alignment: .leading) {
                        Text((product.Title?.prefix(20) ?? "") + (product.Title?.count ?? 21 > 20 ? "..." : ""))
                            .lineLimit(1) // Ensure title is limited to 1 line
                        HStack {
                            VStack(alignment: .leading) {
                                Text("$\(product.Price ?? "")")
                                    .bold()
                                    .font(.system(size: 15)) // Smaller font size for price
                                    .foregroundColor(.blue)
                                Text(product.Shipping ?? "")
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
                    Button(action: {
                        showFavAlert = true
                        // Toggle the favorite status
                        if (product.favorite == "true") {
                            viewModel.deleteFavorite(itemId: product.itemId)
                            isInFavorites = false
                            product.favorite = "false"
                        } else {
                            product.favorite = "true"
                            isInFavorites = true
                            viewModel.postFavorite(product: product)
                        }
                    }) {
                        Image(systemName: product.favorite == "true" ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Image(systemName: "chevron.right")
                }
                .background(NavigationLink("", destination: ProductDetailsView(product: $product)))
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}
