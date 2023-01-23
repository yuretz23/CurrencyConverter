//
//  Array+Extensio.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

extension Array {
subscript(safe index: Int) -> Element? {
    guard index < endIndex, index >= startIndex else { return nil}
        return self[index]
    }
}
