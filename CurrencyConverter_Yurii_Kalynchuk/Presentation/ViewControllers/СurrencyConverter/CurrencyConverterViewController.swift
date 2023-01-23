//
//  ViewController.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import UIKit

protocol CurrencyConverterView: AnyObject {
    func startLoading()
    func stopLoading()
    func showCurrenciesList(currencies: [String])
    func showBalances(balances: [CurrencyBalance])
    func showConvertedCurencies(currency: CurrencyBalance)
    func showFailureAlert(message: String)
    func showSuccessAlert(message: String, title: String)
}

class CurrencyConverterViewController: BaseViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var sectionConfiguration: SectionConfiguration!
    var presenter: CurrencyConverterPresenterProtocol?
    private var viewModel: ExchangeViewModel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = ExchangeViewModel.emptyModel()
        self.title = NSLocalizedString("currency_converter", comment: "Currency converter").capitalizingFirstLetter()
        submitButton.setTitle(NSLocalizedString("submit", comment: "Submit").uppercased(), for: .normal)
        configSections()
        presenter?.getCurrenciesList()
        presenter?.getMyBalances()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setUpGradient()
    }

    // MARK: - IBActions
    @IBAction func submitButtonAction(_ sender: Any) {
        presenter?.convertCurrencies(model: viewModel, submited: true)
        view.endEditing(true)
    }
    
    // MARK: Private methods
    private func setUpGradient() {
        applyAppBlueGradient(to: gradientView)
        applyAppBlueGradient(to: submitButton)
    }
    
    private func applyAppBlueGradient(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(named: "BlueColor1")?.cgColor ?? UIColor.blue.cgColor,
                           UIColor(named: "BlueColor2")?.cgColor ?? UIColor.blue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func configSections() {
        if let jsonData = sectioinConfigurationJson.data(using: .utf8) {
            self.sectionConfiguration = try? JSONDecoder().decode(SectionConfiguration.self,
                                                                 from: jsonData)
        } else {
            self.sectionConfiguration = SectionConfiguration(sections: [])
        }
    }
}

// MARK: - TableViewDelegate
extension CurrencyConverterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("\(sectionConfiguration.sections[section].sectionTitle)", comment: "\(section) section title").uppercased()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionConfiguration.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionConfiguration.sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfig = sectionConfiguration.sections[indexPath.section].cells[indexPath.row]
        switch cellConfig.cellType {
        case .balance(let balances):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyBalancesTableViewCell") as? MyBalancesTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(balances: balances)
            return cell
        case .exchange(let exchangeModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyExchangeTableViewCell") as? CurrencyExchangeTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(model: exchangeModel, delegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
}

// MARK: - CurrencyExchangeTableViewCellDelegate
extension CurrencyConverterViewController: CurrencyExchangeTableViewCellDelegate {
    func didUpdateFrom(currency: String) {
        viewModel.fromCurrency = currency
    }
    
    func didUpdateTo(currency: String) {
        viewModel.toCurrency = currency
    }
    
    func didUpdateFrom(amount: Double?) {
        viewModel.fromAmount = amount ?? 0
    }
    
    func didTapDoneButton() {
        presenter?.convertCurrencies(model: viewModel, submited: false)
        view.endEditing(true)
    }
}

// MARK: - CurrencyConverterView
extension CurrencyConverterViewController: CurrencyConverterView {
    func showSuccessAlert(message: String, title: String) {
        let action = UIAlertAction(title: "Done", style: .destructive)
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert,
                     animated: true)
    }
    
    func showFailureAlert(message: String) {
        let action = UIAlertAction(title: "OK", style: .destructive)
        let alertController = UIAlertController(title: "Failure",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    func showBalances(balances: [CurrencyBalance]) {
        guard let sectionIndex = sectionConfiguration.sections.firstIndex(where: { $0.sectionType == .balance }) else { return }
        sectionConfiguration.sections[sectionIndex] = SectionConfig(sectionType: .balance,
                                                                    sectionTitle: "my_balances".uppercased(),
                                                                    cells: [CellConfig(cellType: .balance(balances))])
        
        self.tableView.reloadRows(at: (0...sectionConfiguration.sections[sectionIndex].cells.count).map( { IndexPath(row: $0, section: sectionIndex) }) , with: .none)
    }
    
    func showCurrenciesList(currencies: [String]) {
        guard let sectionIndex = sectionConfiguration.sections.firstIndex(where: { $0.sectionType == .exchange }) else { return }
        sectionConfiguration.sections[sectionIndex] =  SectionConfig(sectionType: .exchange,
                                                                     sectionTitle: NSLocalizedString("currency_exchange", comment: "Currency exchange").uppercased(),
                                                                     cells: [CellConfig(cellType: .exchange(ExchangeModel(type: .sell,
                                                                                                                          currencies: currencies,
                                                                                                                          currencyType: "",
                                                                                                                          amount: nil))),
                                                                             CellConfig(cellType: .exchange(ExchangeModel(type: .receive,
                                                                                                                          currencies: currencies,
                                                                                                                          currencyType: "",
                                                                                                                          amount: 0))) ])

        self.tableView.reloadSections(IndexSet(integer: sectionIndex),
                                      with: .none)
    }
    
    func showConvertedCurencies(currency: CurrencyBalance) {
        guard let sectionIndex = sectionConfiguration.sections.firstIndex(where: { $0.sectionType == .exchange }),
              let cellIndex = sectionConfiguration.sections[sectionIndex].cells.firstIndex(where: { cellConfig in
                  
                  switch cellConfig.cellType {
                  case .exchange(let exchangeModel):
                      if exchangeModel.type == .receive {
                          return true
                      } else {
                          return false
                      }
                  default: return false
                  }
              }) else { return }
        let indexPath = IndexPath(item: cellIndex, section: sectionIndex)
        (tableView.cellForRow(at: indexPath) as? CurrencyExchangeTableViewCell)?.updateAmountValue(amount: currency.amount)
    }
}


