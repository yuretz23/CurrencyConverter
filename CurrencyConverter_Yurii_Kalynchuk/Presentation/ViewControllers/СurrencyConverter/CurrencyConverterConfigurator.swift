//
//  File.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import UIKit

class CurrencyConverterConfigurator {
    static func makeCurrencyConverterScreen() -> CurrencyConverterViewController {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyConverterViewController = mainStoryboard.instantiateViewController(withIdentifier: "CurrencyConverterViewController") as! CurrencyConverterViewController
        let networkManager = NetworkManager()
        let currencyRepo = CurrencyRepository(networkManager: networkManager)
        currencyConverterViewController.presenter = CurrencyConverterPresenter(currencyConverterView: currencyConverterViewController,
                                                                               exchangeUseCase: ExchangeUseCase(currencyService: currencyRepo))
        return currencyConverterViewController
    }
}
