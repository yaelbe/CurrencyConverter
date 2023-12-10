import Foundation
import Combine

class CurrencyConversionViewModel: NSObject, ObservableObject {
    @Published var sourceCurrency: String = "" {
        didSet {
            print("sourceCurrency: \(String(describing: sourceCurrency))")
            fetchExchangeRates()
        }
    }
    
    @Published var targetCurrency: String = "EUR" {
        didSet {
            print("targetCurrency: \(String(describing: targetCurrency))")
            convertCurrency()
        }
    }
    @Published var amount: Double = 0{
        didSet {
            print("amount set")
            convertCurrency()
        }
    }
    @Published var convertedAmount: Double = 0
    @Published var currencies: [String] = CurrencyMapper.shared.allCurrencies()
    @Published var history: [ConversionHistoryEntry] = []
    
    private var exchangeService = CurrencyExchangeService()
     var exchangeRates: [String: Double] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    var convertedAmountFormatted: String {
        String(format: "%.2f", convertedAmount)
    }
    
    var sourceCurrencySymbol: String {
        Locale.current.localizedString(forCurrencyCode: sourceCurrency) ?? ""
    }
    
    var targetCurrencySymbol: String {
        Locale.current.localizedString(forCurrencyCode: targetCurrency) ?? ""
    }
    
    override init() {
        super.init()
        setupHistory()
        setupCurrencyListener()
    }
    
    private func setupHistory() {
        history = HistoryManager.shared.loadHistory()
        HistoryManager.shared.$history
            .assign(to: \.history, on: self)
            .store(in: &cancellables)
    }
    
    private func setupCurrencyListener() {
        LocationManager.shared.$currentCurrency
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currency in
                self?.sourceCurrency = currency
                //                self?.fetchExchangeRates()
            }
            .store(in: &cancellables)
    }
    
    func fetchExchangeRates() {
        exchangeService.fetchExchangeRates(for: sourceCurrency )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching exchange rates: \(error)")
                    // Handle the error appropriately
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] exchangeRates in
                self?.exchangeRates = exchangeRates.conversionRates
                self?.convertCurrency()
            })
            .store(in: &cancellables)
    }
    
    func convertCurrency() {
        print("amount:\(amount)")
        if let rate = exchangeRates[targetCurrency] {
            convertedAmount = amount * rate
            HistoryManager.shared.addHistoryEntry(sourceCurrency: sourceCurrency,
                                                  targetCurrency: targetCurrency,
                                                  amount: amount,
                                                  convertedAmount: convertedAmount)
            
        }else {
            convertedAmount = 0.0
        }
    }
    
    func clearHistory() {
        HistoryManager.shared.clearHistory()
        history = HistoryManager.shared.loadHistory() // Reload the history to reflect the changes
    }
}

