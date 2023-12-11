import SwiftUI
import Kingfisher

struct PhotosView: View {
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
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        Text("Powered by")
                        KFImage(URL(string: "https://cdn.freebiesupply.com/images/large/2x/google-logo-transparent.png")!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    VStack {
                        ForEach(viewModel.similarImages?.items ??  [], id: \.title) { similarImage in
                            KFImage(URL(string: similarImage.link)) // Assuming 'link' contains the image URL
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200) // Adjust the frame size as needed
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
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
