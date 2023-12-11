import SwiftUI

struct ShippingView: View {
    @ObservedObject var viewModel: ProductDetailsViewModel
    
    var body: some View {
        VStack {
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
            } else {
                GeometryReader { geometry in
                    VStack(alignment: .leading) {
                        
                        // Seller Info
                        Divider()
                        HStack{
                            Image(systemName: "storefront")
                            Text("Seller")
                        }
                        Divider()
                        if let storeName = viewModel.product.Item?.Storefront?.StoreName,
                           let storeURLString = viewModel.product.Item?.Storefront?.StoreURL
                        {
                            HStack(alignment: .top) {
                                Text("Store Name")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Button(action: {
                                    if let url = URL(string: storeURLString) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }) {
                                    Text(storeName)
                                        .foregroundColor(.blue)
                                        .frame(width: geometry.size.width / 2, alignment: .center)
                                }
                            }
                        }
                        if let feedbackScore = viewModel.product.Item?.Seller?.FeedbackScore {
                            HStack(alignment: .top) {
                                Text("Feedback Score")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text("\(feedbackScore)")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let popularity = viewModel.product.Item?.Seller?.PositiveFeedbackPercent {
                            HStack(alignment: .top) {
                                Text("Popularity")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text("\(String(format: "%.2f", popularity))%")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        
                        // Shipping Information
                        Divider()
                        HStack{
                            Image(systemName: "sailboat")
                            Text("Shipping Info")
                        }
                        Divider()
                        if let shippingCost = viewModel.product.shippingCost {
                            HStack(alignment: .top) {
                                Text("Shipping Cost")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(shippingCost == "0" ? "FREE" : shippingCost)
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let globalShipping = viewModel.product.Item?.GlobalShipping {
                            HStack(alignment: .top) {
                                Text("Global Shipping")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(globalShipping ? "Yes" : "No")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let handlingTime = viewModel.product.Item?.HandlingTime {
                            HStack(alignment: .top) {
                                Text("Handling Time")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text("\(handlingTime) days")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        
                        // Return Policy
                        Divider()
                        HStack{
                            Image(systemName: "return")
                            Text("Return Policy")
                        }
                        Divider()
                        if let returnsAccepted = viewModel.product.Item?.ReturnPolicy?.ReturnsAccepted {
                            HStack(alignment: .top) {
                                Text("Policy")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(returnsAccepted)
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let refundMode = viewModel.product.Item?.ReturnPolicy?.Refund {
                            HStack(alignment: .top) {
                                Text("Refund Mode")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(refundMode)
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let returnWithin = viewModel.product.Item?.ReturnPolicy?.ReturnsWithin {
                            HStack(alignment: .top) {
                                Text("Return Within")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(returnWithin)
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                        if let shippingCostPaidBy = viewModel.product.Item?.ReturnPolicy?.ShippingCostPaidBy {
                            HStack(alignment: .top) {
                                Text("Shipping Cost Paid By")
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                                Spacer()
                                Text(shippingCostPaidBy)
                                    .frame(width: geometry.size.width / 2, alignment: .center)
                            }
                        }
                    }
                }
                .padding(.vertical, 50)
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
