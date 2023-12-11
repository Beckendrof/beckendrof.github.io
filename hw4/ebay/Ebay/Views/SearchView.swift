import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .symbolVariant(configuration.isOn ? .fill : .none)
                .foregroundColor(configuration.isOn ? Color.blue : Color.primary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var isShowingAutocompleteSheet = false
    @State private var timer: Timer?
    @State var isInFavorites = false
    @State var showFavAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                        // Keyword
                        HStack {
                            Text("Keyword: ")
                            TextField("Required", text: $viewModel.keyword)
                        }
                        
                        // Category
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(SearchViewModel.categories, id: \.self) { category in
                                Text(category)
                            }
                        }
                        .tint(.blue)
                        
                        // Condition
                        VStack(alignment: .leading) {
                            Text("Condition")
                            
                            HStack {
                                Spacer()
                                Toggle("New", isOn: $viewModel.newCondition)
                                    .toggleStyle(CheckboxToggleStyle())
                                
                                Toggle("Used", isOn: $viewModel.usedCondition)
                                    .toggleStyle(CheckboxToggleStyle())
                                
                                Toggle("Unspecified", isOn: $viewModel.unspecifiedCondition)
                                    .toggleStyle(CheckboxToggleStyle())
                                Spacer()
                            }
                        }
                        
                        // Shipping
                        VStack(alignment: .leading) {
                            Text("Shipping")
                            
                            HStack {
                                Spacer()
                                Toggle("Pickup", isOn: $viewModel.pickupShipping)
                                    .toggleStyle(CheckboxToggleStyle())
                                
                                Toggle("Free Shipping", isOn: $viewModel.freeShipping)
                                    .toggleStyle(CheckboxToggleStyle())
                                Spacer()
                            }
                        }
                        
                        // Distance
                        HStack {
                            Text("Distance: ")
                            TextField("10", text: $viewModel.distance)
                                .keyboardType(.numberPad)
                        }
                        
                        VStack {
                            // ... other content
                            
                            // Custom Location
                            Toggle("Custom Location", isOn: $viewModel.customLocation)
                            
                            if viewModel.customLocation {
                                HStack {
                                    Text("Zipcode: ")
                                    TextField("Required", text: $viewModel.zipcode)
                                        .onChange(of: viewModel.zipcode) { _ in
                                            if viewModel.zipcode.count < 5 {
                                                timer?.invalidate()
                                                // Start a new timer to present the sheet after 2 seconds of inactivity
                                                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                                    isShowingAutocompleteSheet.toggle()
                                                }
                                            }
                                        }
                                }
                                .sheet(isPresented: $isShowingAutocompleteSheet) {
                                    AutocompleteSheetView(zipcode: $viewModel.zipcode, isShowingSheet: $isShowingAutocompleteSheet, viewModel: viewModel)
                                }
                            }
                        }
                        
                        HStack(spacing: 30) {
                            Button(action: {
                                if viewModel.keyword.isEmpty || (viewModel.customLocation && viewModel.zipcode.count < 1){
                                    viewModel.showAlert = true
                                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                                        viewModel.showAlert = false
                                    }
                                } else {
                                    viewModel.showAlert = false
                                    viewModel.showResults = true
                                    viewModel.search()
                                }
                            }) {
                                Text("Submit")
                                    .padding(8)
                            }

                            Button(action: {
                                viewModel.clear()
                                viewModel.showResults = false
                            }) {
                                Text("Clear")
                                    .padding(8)
                            }
                        }
                        .padding(.leading, 60)
                        .padding(.vertical, 3)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if viewModel.showResults {
                        Section {
                            ResultsView(viewModel: viewModel, isInFavorites: $isInFavorites, showFavAlert: $showFavAlert)
                        }
                    }
                    
                }
                .navigationBarTitle("Product Search")
                .navigationBarItems(trailing:
                    NavigationLink(
                        destination: FavoritesView(viewModel: viewModel),
                        label: {
                            Image(systemName: "heart.circle")
                                .foregroundColor(.blue)
                        }
                    )
                )
                .onAppear {
                    viewModel.fetchFavorites()
                }
                
                if showFavAlert {
                    VStack{
                        Spacer ()
                        if isInFavorites {
                            Text("Added to Favorites")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                                .padding()
                                .onAppear {
                                    // Schedule a timer to hide the text box after 1.5 seconds
                                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                                        withAnimation {
                                            showFavAlert = false
                                        }
                                    }
                                }
                        } else {
                            Text("Removed from favorites")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                                .padding()
                                .onAppear {
                                    // Schedule a timer to hide the text box after 1.5 seconds
                                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                                        withAnimation {
                                            showFavAlert = false
                                        }
                                    }
                                }
                        }
                    }
                }
                
                if viewModel.showAlert {
                    VStack {
                        Spacer()
                        if viewModel.keyword.isEmpty {
                        Text("Keyword is mandatory")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                            .padding()
                            .onAppear {
                                // Schedule a timer to hide the text box after 2 seconds
                                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                    withAnimation {
                                        viewModel.isKeywordEmpty = false
                                    }
                                }
                            }
                        } else {
                            Text("Zipcode is required")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                                .padding()
                                .onAppear {
                                    // Schedule a timer to hide the text box after 2 seconds
                                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                        withAnimation {
                                            viewModel.isKeywordEmpty = false
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

struct AutocompleteSheetView: View {
    @Binding var zipcode: String
    @Binding var isShowingSheet: Bool
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        List {
            ForEach(viewModel.autocompleteResults, id: \.self) { result in
                Text(result)
                    .onTapGesture {
                        zipcode = result
                        isShowingSheet = false
                    }
            }
        }
        .padding()
        .onAppear {
            // Call the function in the viewModel to fetch autocomplete results
            viewModel.fetchAutocompleteResults(for: zipcode)
        }
    }
}
