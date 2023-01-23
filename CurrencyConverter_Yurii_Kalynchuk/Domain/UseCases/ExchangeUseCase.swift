//
//  ExchangeUseCase.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

protocol ExchangeUseCaseProtocol {
    func fetchCurrencies(completion:(Result<[String], Error>) -> Void)
    func fetchMyBalances(completion:(Result<[CurrencyBalance], Error>) -> Void)
    func convertCurrencies(model: ExchangeViewModel, completion: @escaping (Result<CurrencyBalanceAPIModel, Error>) -> Void)
    func submitConverting(from: CurrencyBalance, to: CurrencyBalance, completion: @escaping (Result<Double, Error>) -> Void)
}

class ExchangeUseCase: ExchangeUseCaseProtocol {
    private let currencyService: CurrencyRepositoryProtocol
    
    init(currencyService: CurrencyRepositoryProtocol) {
        self.currencyService = currencyService
    }
    
    func fetchCurrencies(completion: (Result<[String], Error>) -> Void) {
        currencyService.fetchCurrencies { result in
            completion(result)
        }
    }
    
    func fetchMyBalances(completion: (Result<[CurrencyBalance], Error>) -> Void) {
        currencyService.fetchMyBalances { result in
            completion(result)
        }
        
    }
    
    func convertCurrencies(model: ExchangeViewModel, completion: @escaping (Result<CurrencyBalanceAPIModel, Error>) -> Void) {
        currencyService.convertCurrencies(fromCurrency: model.fromCurrency, fromAmount: model.fromAmount, toCurrency: model.toCurrency, completion: completion)
    }
    
    func submitConverting(from: CurrencyBalance, to: CurrencyBalance, completion: @escaping (Result<Double, Error>) -> Void) {
        currencyService.submitConverting(from: from, to: to, completion: completion)
    }
}
