//
//  CurrencyService.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

protocol CurrencyRepositoryProtocol {
    func convertCurrencies(fromCurrency: String,
                           fromAmount: Double,
                           toCurrency: String,
                           completion: @escaping (Result<CurrencyBalanceAPIModel, Error>) -> Void)
    func fetchCurrencies(completion: (Result<[String], Error>) -> Void)
    func fetchMyBalances(completion:(Result<[CurrencyBalance], Error>) -> Void)
    func submitConverting(from: CurrencyBalance, to: CurrencyBalance, completion: @escaping (Result<Double, Error>) -> Void)
}
