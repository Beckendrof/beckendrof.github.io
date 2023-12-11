import SwiftUI
import Kingfisher

struct SimilarView: View {
    @ObservedObject var viewModel: ProductDetailsViewModel
    
    // Sorting options
    @State private var selectedSortOption = "Default"
    @State private var selectedSortOrder = "Ascending"
    
    var body: some View {
        VStack  {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                }
                .onAppear {
                    viewModel.isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.isLoading = false
                    }
                }
            } else {
                VStack{
                    VStack(alignment: .leading){
                        Text("Sort By")
                            .bold()
                        // Segmented controls for sorting options
                        Picker("Sort By:", selection: $selectedSortOption) {
                            Text("Default").tag("Default")
                            Text("Title").tag("Title")
                            Text("Price").tag("Price")
                            Text("Days Left").tag("DaysLeft")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Conditionally show the "Order" group
                        if selectedSortOption != "Default" {
                            Group {
                                Text("Order")
                                    .bold()
                                Picker("Sort Order:", selection: $selectedSortOrder) {
                                    Text("Ascending").tag("Ascending")
                                        .disabled(selectedSortOption == "Default")
                                    Text("Descending").tag("Descending")
                                        .disabled(selectedSortOption == "Default")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .opacity(selectedSortOption != "Default" ? 1 : 0)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Make only the LazyVGrid scrollable
                    ScrollView(.vertical) {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
                            ForEach(viewModel.similarProducts, id: \.itemId) { product in
                                SimilarItemCellView(product: product)
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
                .onChange(of: selectedSortOption) { _ in
                    viewModel.sortSimilarProducts(by: selectedSortOption, order: selectedSortOrder)
                }
                .onChange(of: selectedSortOrder) { _ in
                    viewModel.sortSimilarProducts(by: selectedSortOption, order: selectedSortOrder)
                }
            }
        }
        .onAppear {
            viewModel.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.isLoading = false
            }
        }
    }
}

struct SimilarItemCellView: View {
    var product: SimilarProduct
    
    var formattedDaysLeft: String {
        if let rangeP = product.timeLeft.range(of: "P"),
           let rangeD = product.timeLeft.range(of: "D", range: rangeP.upperBound..<product.timeLeft.endIndex) {
            let daysSubstring = product.timeLeft[rangeP.upperBound..<rangeD.lowerBound]
            return ("\(daysSubstring) days left")
        }
        return "N/A"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
            // Image of the product
            KFImage(URL(string: product.imageURL))
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 120, maxHeight: 150)  // Adjusted frame to prevent overflow
                .clipped()
            
            // Title of the product
            Text(product.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            // HStack for "Days Left" and "Shipping" in one line
            HStack {
                Text("$\(product.shippingCost.value)")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formattedDaysLeft)
                    .foregroundColor(.secondary)
                
            }
            .font(.system(size: 15))
            
            HStack{
                Spacer()
                // Price of the product on the next line with larger bold blue font
                Text("$\(product.buyItNowPrice.value)")
                    .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.blue)}
            
            }.padding(10)
        }
        .background(Color.secondary.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
        )
        .padding(10)
    }
}

