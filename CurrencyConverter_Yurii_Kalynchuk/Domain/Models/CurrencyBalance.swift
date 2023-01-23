//
//  CurrencyBalance.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

struct CurrencyBalance: Codable {
    let currency: String
    let amount: Double
    
    func getFullFormatedString() -> String {
        return String.localizedStringWithFormat("%.2f %@", amount, currency)
    }
}

struct CurrencyBalanceAPIModel: Decodable {
    let currency: String
    let amount: String
}


