//
//  CurrencyConverterPresenter.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

protocol CurrencyConverterPresenterProtocol: AnyObject {
    func getCurrenciesList()
    func getMyBalances()
    func convertCurrencies(model: ExchangeViewModel, submited: Bool)
}

class CurrencyConverterPresenter: CurrencyConverterPresenterProtocol {

    weak private var currencyConverterView: CurrencyConverterView?
    private let exchangeUseCase: ExchangeUseCaseProtocol
    
    init(currencyConverterView: CurrencyConverterView,
         exchangeUseCase: ExchangeUseCaseProtocol) {
        self.currencyConverterView = currencyConverterView
        self.exchangeUseCase = exchangeUseCase
    }
    func getCurrenciesList() {
        currencyConverterView?.startLoading()
        exchangeUseCase.fetchCurrencies { result in
            self.currencyConverterView?.stopLoading()
            switch result {
            case .success(let currenciesList):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.showCurrenciesList(currencies: currenciesList)
                }
            case .failure( let error):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.showFailureAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func getMyBalances() {
        currencyConverterView?.startLoading()
        exchangeUseCase.fetchMyBalances { result in
            switch result {
            case .success(let balances):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    self?.currencyConverterView?.showBalances(balances: balances)
                }
            case .failure( let error):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    self?.currencyConverterView?.showFailureAlert(message: error.localizedDescription)
                }
            }
        }
    }

    func convertCurrencies(model: ExchangeViewModel, submited: Bool) {
        currencyConverterView?.startLoading()
        exchangeUseCase.convertCurrencies(model: model) { result in
            switch result {
            case .success(let currency):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    let convertedCurrency = CurrencyBalance(currency: currency.currency, amount: Double(currency.amount) ?? 0)
                    self?.currencyConverterView?.showConvertedCurencies(currency: convertedCurrency)
                    if submited {
                        self?.submitConverting(from: CurrencyBalance(currency: model.fromCurrency, amount: model.fromAmount), to: convertedCurrency)
                    }
                }
            case .failure( let error):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    self?.currencyConverterView?.showFailureAlert(message: error.localizedDescription)
                }
            }
        }
    }
    private func submitConverting(from: CurrencyBalance, to: CurrencyBalance) {
        self.currencyConverterView?.startLoading()
        exchangeUseCase.submitConverting(from: from, to: to) { result in
            switch result {
            case .success(let fee):
                self.getMyBalances()
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    
                    self?.currencyConverterView?.showSuccessAlert(message: String(format: NSLocalizedString("converted_alert",
                                                                                                            comment: "Converted alert"), from.getFullFormatedString(), to.getFullFormatedString(), fee, from.currency),
                                                                  title: NSLocalizedString("currency converted", comment: "Currency converted").capitalizingFirstLetter())
                }
            case .failure( let error):
                DispatchQueue.main.async { [weak self] in
                    self?.currencyConverterView?.stopLoading()
                    self?.currencyConverterView?.showFailureAlert(message: error.localizedDescription)
                }
            }
        }
    }
}
