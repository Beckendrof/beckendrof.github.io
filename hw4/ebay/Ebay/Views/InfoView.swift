import SwiftUI
import Kingfisher

struct InfoView: View {
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
                VStack(alignment: .leading) {
                    TabView {
                        ForEach(viewModel.product.Item?.PictureURL ?? [], id: \.self) { imageURL in
                            KFImage(URL(string: imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 200)
                    .padding(.vertical)
                    Text(viewModel.product.Title ?? "")
                    Text("$\(viewModel.product.Price ?? "")")
                        .bold()
                        .font(.system(size: 15)) // Smaller font size for price
                        .foregroundColor(.blue)
                        .padding(.vertical)
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Description")
                    }
                    ScrollView {
                        ForEach(viewModel.product.Item?.ItemSpecifics?.NameValueList ?? []) { nameValueList in
                            if let name = nameValueList.Name, let values = nameValueList.Value {
                                GeometryReader { geometry in
                                    VStack {
                                        HStack {
                                            Text(name)
                                                .frame(width: geometry.size.width / 2, alignment: .leading)
                                            Spacer()
                                            Text(values.joined(separator: ", "))
                                                .frame(width: geometry.size.width / 2, alignment: .leading)
                                        }
                                    }
                                    Divider()
                                }
                                
                            }
                        }
                    }.padding(.vertical)
                }
                .padding()
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
