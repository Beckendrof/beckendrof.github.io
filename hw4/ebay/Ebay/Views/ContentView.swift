import SwiftUI
import Kingfisher

struct ContentView: View {
    @State private var showPoweredBy = true
    @State var searchViewModel = SearchViewModel()

    var body: some View {
        ZStack {
            SearchView(viewModel: searchViewModel)
                .opacity(showPoweredBy ? 0 : 1)

            if showPoweredBy {
                VStack {
                    Spacer()
                    HStack{
                        
                        Text("Powered by")
                            .font(.headline)
                        
                        KFImage(URL(string: "https://upload.wikimedia.org/wikipedia/commons/4/48/EBay_logo.png"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showPoweredBy = false
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
