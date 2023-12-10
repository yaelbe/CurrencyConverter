import SwiftUI

struct CurrencyConverterView: View {
    @ObservedObject var viewModel: CurrencyConversionViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let columns = [
                    GridItem(.flexible(minimum: totalWidth * 0.40)),
                    GridItem(.flexible(minimum: totalWidth * 0.25)),
                    GridItem(.flexible(minimum: totalWidth * 0.25))
                ]
                VStack {
                    LazyVGrid(columns: columns, spacing: 6) {
                        // Source Currency Row
                        HStack {
                            Text(viewModel.sourceCurrencySymbol)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                        }
                        HStack {
                            Picker("Source Currency", selection: $viewModel.sourceCurrency) {
                                ForEach(viewModel.currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                        HStack {
                            TextField("Amount", value: $viewModel.amount, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Spacer()
                        }
                        
                        // Target Currency Row
                        HStack {
                            Text(viewModel.targetCurrencySymbol)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                        }
                        HStack {
                            Picker("Target Currency", selection: $viewModel.targetCurrency) {
                                ForEach(viewModel.currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                        HStack {
                            Text(viewModel.convertedAmountFormatted)
                            Spacer()
                        }
                    }.padding()
                    BorderedViewWithTitle(title: "Conversion History",buttonText: "Clear",buttonAction: {
                        viewModel.clearHistory()
                    }){
                        if viewModel.history.isEmpty {
                            Spacer()
                            Text("No history found")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.history) { entry in
                                        CardView(entry: entry)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                }
                .navigationTitle("Currency Converter")
                .listStyle(PlainListStyle())
                
            }
        }
    }
}
