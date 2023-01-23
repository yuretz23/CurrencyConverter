//
//  APICurrencyService.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

struct APICurrency {
    static let baseURL = "http://api.evp.lt"
    static func exchangePath(fromCurrency: String, toCurrency: String, amount: Double) -> String {
        return "/currency/commercial/exchange/\(amount)-\(fromCurrency)/\(toCurrency)/latest"
    }
}

enum CurrencyRepositoryError: Error {
    case doNotHaveEnoughMoney
}

extension CurrencyRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .doNotHaveEnoughMoney:
            return NSLocalizedString("You do not have enough money for this transaction", comment: "")
        }
    }
}

class CurrencyRepository: CurrencyRepositoryProtocol {
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    private var freeConvertionCount = 5
    private var numberOfTransactions = 0
    private var balance: [String: Double] = ["EUR": 1000,
                                             "USD": 0,
                                             "JPY": 0]
    
    func fetchCurrencies(completion: (Result<[String], Error>) -> Void) {
        completion(.success(balance.keys.sorted()))
    }
    
    func fetchMyBalances(completion:(Result<[CurrencyBalance], Error>) -> Void) {
        let currencyBalances = balance.map { (currency: String, amount: Double) in
            return CurrencyBalance(currency: currency, amount: amount)
        }.sorted(by: { $0.currency < $1.currency })
        completion(.success(currencyBalances))
    }
    
    func convertCurrencies(fromCurrency: String,
                           fromAmount: Double,
                           toCurrency: String,
                           completion: @escaping (Result<CurrencyBalanceAPIModel, Error>) -> Void) {
        let url = URL(string: APICurrency.baseURL + APICurrency.exchangePath(fromCurrency: fromCurrency, toCurrency: toCurrency, amount: fromAmount))
        networkManager.request(fromURL: url!, httpMethod: .get, completion: completion)
    }

    func submitConverting(from: CurrencyBalance, to: CurrencyBalance, completion: @escaping (Result<Double, Error>) -> Void) {
        var summ = from.amount
        let fee = getFee(from: from, to: to)
        
        summ += fee
        
        let updatedBalance = ((balance[from.currency] ?? 0) - summ)
        if updatedBalance < 0 {
            completion(.failure(CurrencyRepositoryError.doNotHaveEnoughMoney))
            return
        }
        numberOfTransactions += 1
        balance[from.currency] = updatedBalance
        balance[to.currency] = (balance[to.currency] ?? 0) + to.amount
        completion(.success(fee))
    }
    
    private func getFee(from: CurrencyBalance, to: CurrencyBalance) -> Double {
        var fee: Double = 0
        if numberOfTransactions % 10 == 0 {
            return 0
        }
        if freeConvertionCount <= 0 {
            fee = from.amount * 0.007
            fee = max(0.1, fee)
        } else {
            freeConvertionCount -= 1
        }
        return fee
    }
}
