import SwiftUI

struct CardView: View {
    var entry: ConversionHistoryEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("\(entry.sourceCurrency): \(formattedAmount(entry.amount)) to \(entry.targetCurrency): \(formattedAmount(entry.convertedAmount))")
                Text("Date: \(entry.date.formatted())")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray, radius: 5, x: 0, y: 2)
        .padding(.vertical, 8)
    }
    
    private func formattedAmount(_ amount: Double) -> String {
        String(format: "%.2f", amount)
    }
    
}

