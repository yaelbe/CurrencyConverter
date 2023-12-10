import Foundation

struct ConversionHistoryEntry: Identifiable, Codable {
    let id = UUID()
    let sourceCurrency: String
    let targetCurrency: String
    let amount: Double
    let convertedAmount: Double
    let date: Date
}
