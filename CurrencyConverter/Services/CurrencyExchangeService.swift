import Foundation
import Combine

class CurrencyExchangeService {
    
    private var cancellables = Set<AnyCancellable>()
    private let urlSession: URLSession
    private let lastFetchDateKey = "lastFetchDate"
    private var lastFetchDate: Date?
    
    private let baseURL = "https://v6.exchangerate-api.com/v6/90d57b505f1cd61c1fbf58fe/latest/"
    
    init() {
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, // 10 MB memory cache
                             diskCapacity: 50 * 1024 * 1024, // 50 MB disk cache
                             diskPath: nil)
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.urlSession = URLSession(configuration: configuration)
        clearCacheIfNeeded()
    }
    
    private func clearCacheIfNeeded() {
        let currentDate = Date()
        if let lastFetchDate = UserDefaults.standard.object(forKey: lastFetchDateKey) as? Date,
           !Calendar.current.isDate(lastFetchDate, inSameDayAs: currentDate) {
            urlSession.configuration.urlCache?.removeAllCachedResponses()
        }
        UserDefaults.standard.set(currentDate, forKey: lastFetchDateKey)
    }
    
    func fetchExchangeRates(for currency: String) -> AnyPublisher<ExchangeRates, Error> {
        guard !currency.isEmpty else {
            return Fail(error: CurrencyExchangeError.emptyCurrency)
                .eraseToAnyPublisher()
        }
        guard let url = URL(string: "\(baseURL)\(currency)") else{
            return Fail(error: CurrencyExchangeError.invalidURL)
                .eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ExchangeRates.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum CurrencyExchangeError: Error {
    case emptyCurrency
    case invalidURL
}

struct ExchangeRates: Decodable {
    let baseCode: String
    let conversionRates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}

