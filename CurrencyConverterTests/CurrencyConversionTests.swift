
import Foundation
@testable import CurrencyConverter
import XCTest
import Combine

class CurrencyConversionTests: XCTestCase {
    var viewModel: CurrencyConversionViewModel!
    var service: CurrencyExchangeService!

    
    override func setUp() {
        super.setUp()
        viewModel = CurrencyConversionViewModel()
        service = CurrencyExchangeService()
        
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        super.tearDown()
    }
    
    func testCurrencyConversion() {
        viewModel.amount = 10 // Example amount
        viewModel.sourceCurrency = "USD"
        viewModel.targetCurrency = "EUR"
        viewModel.exchangeRates = ["EUR": 0.85] // Mock exchange rate
        
        viewModel.convertCurrency()
        
        XCTAssertEqual(viewModel.convertedAmount, 8.5, "10 USD should convert to 8.5 EUR")
    }
    
    func testFetchExchangeRates() {
        let expectation = XCTestExpectation(description: "Fetch exchange rates")
        var cancellables = Set<AnyCancellable>()

        // Call the method and subscribe to the publisher
        service.fetchExchangeRates(for: "USD")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed with error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { exchangeRates in
                XCTAssertNotNil(exchangeRates.conversionRates["EUR"], "EUR rate should be present")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}
