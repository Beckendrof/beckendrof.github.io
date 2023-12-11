import SwiftUI
import Kingfisher

struct ProductDetailsView: View {
    @Binding var product: Product
    @StateObject var viewModel: ProductDetailsViewModel
    
    init(product: Binding<Product>) {
        self._product = product
        self._viewModel = StateObject(wrappedValue: ProductDetailsViewModel(product: product.wrappedValue))
    }
    
    var body: some View {
        ZStack{
            Color.gray
        TabView {
            InfoView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Info")
                    
                }
            
            
            ShippingView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "shippingbox")
                    Text("Shipping")
                }
            
            
            PhotosView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "photo")
                    Text("Photos")
                }
            
            
            SimilarView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "rectangle.stack.person.crop")
                    Text("Similar")
                }
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing:
                                HStack {
            Button(action: {
                if let itemURL = product.itemURL {
                    if let url = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(itemURL)") {
                        UIApplication.shared.open(url)
                    }
                }
            }) {
                KFImage(URL(string: "https://upload.wikimedia.org/wikipedia/commons/6/6c/Facebook_Logo_2023.png")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            Button(action: {
                // Toggle the favorite status
                if (product.favorite == "true") {
                    viewModel.deleteFavorite(itemId: product._id)
                    product.favorite = "false"
                } else {
                    product.favorite = "true"
                    viewModel.postFavorite(product: product)
                }
            }) {
                Image(systemName: product.favorite == "true" ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
        )
        .onAppear {
            viewModel.getProductDetails()
            viewModel.getSimilarImages()
            viewModel.getSimilarProducts()
        }
    }
    }
}
