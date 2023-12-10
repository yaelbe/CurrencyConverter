import Foundation
import Combine

class HistoryManager {
    static let shared = HistoryManager()
    private var debounceTimer: Timer?
    private let conversionHistory = "ConversionHistory"
    
    @Published var history: [ConversionHistoryEntry] = []
    
    private init() {
        history = loadHistory()
    } // Private initializer for singleton
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: conversionHistory)
        }
    }
    
    func loadHistory() -> [ConversionHistoryEntry] {
        if let savedHistory = UserDefaults.standard.object(forKey: conversionHistory) as? Data,
           let decodedHistory = try? JSONDecoder().decode([ConversionHistoryEntry].self, from: savedHistory) {
            return decodedHistory
        }
        return []
    }
    
    func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: conversionHistory)
    }
    
    func addHistoryEntry(sourceCurrency: String, targetCurrency: String, amount: Double, convertedAmount: Double) {
        // Cancel the previous timer if it exists
        debounceTimer?.invalidate()
        
        // Set up a new timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
            // Check if the amount is less than 1
            if amount < 1 {
                return
            }
            
            let newEntry = ConversionHistoryEntry(
                sourceCurrency: sourceCurrency,
                targetCurrency: targetCurrency,
                amount: amount,
                convertedAmount: convertedAmount,
                date: Date()
            )
            self?.history.insert(newEntry, at: 0)
            self?.saveHistory()
        }
    }
}
