//
//  ContentView.swift
//  CurrencyConverter
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CurrencyConverterView(viewModel: CurrencyConversionViewModel())
    }
}

#Preview {
    ContentView()
}
