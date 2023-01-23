//
//  ViewModelConfiguration.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

struct SectionConfiguration: Codable {
    var sections: [SectionConfig]
}

struct SectionConfig: Codable {
    let sectionType: SectionType
    let sectionTitle: String
    let cells: [CellConfig]
}

enum SectionType: Codable {
    case balance
    case exchange
}

struct CellConfig: Codable {
    var cellType: CellType
}

enum CellType: Codable {
    case balance([CurrencyBalance])
    case exchange(ExchangeModel)
}

struct ExchangeModel: Codable {
    let type: ExanchgeType
    let currencies: [String]
    let currencyType: String
    let amount: Double?
}

enum ExanchgeType: Codable {
    case sell
    case receive
}
