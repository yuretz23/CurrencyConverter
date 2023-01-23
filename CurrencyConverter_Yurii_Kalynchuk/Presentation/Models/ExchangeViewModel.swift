//
//  ExchangeViewModel.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

struct ExchangeViewModel {
    static func emptyModel() -> ExchangeViewModel {
        return ExchangeViewModel(fromCurrency: "",
                                 fromAmount: 0,
                                 toCurrency: "")
    }
    var fromCurrency: String
    var fromAmount: Double
    var toCurrency: String
}
