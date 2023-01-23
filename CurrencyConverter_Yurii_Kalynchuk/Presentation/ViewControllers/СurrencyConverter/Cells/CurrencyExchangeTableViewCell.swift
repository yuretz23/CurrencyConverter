//
//  CurrencyExchangeTableViewCell.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import UIKit

protocol CurrencyExchangeTableViewCellDelegate {
    func didUpdateFrom(currency: String)
    func didUpdateTo(currency: String)
    func didUpdateFrom(amount: Double?)
    func didTapDoneButton()
}

class CurrencyExchangeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyTextField: CurrencyTextField!
    
    private let pickerView = UIPickerView()
    private var currenciesList: [String] = []
    private var cellType: ExanchgeType = .sell
    private var delegate: CurrencyExchangeTableViewCellDelegate?
    
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareUI()
    }
    
    // MARK: Configuration
    func configure(model: ExchangeModel, delegate: CurrencyExchangeTableViewCellDelegate?) {
        self.delegate = delegate
        currenciesList = model.currencies
        cellType = model.type
        if let currency = currenciesList[safe: model.type == .sell ? 0 : 1] {
            currencyTextField.text = currency
            
        }
        switch model.type {
        case .sell:
            if let currency = currenciesList[safe: 0] {
                currencyTextField.text = currency
                self.delegate?.didUpdateFrom(currency: currency)
            }
            actionImageView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.3019607843, blue: 0.3058823529, alpha: 1)
            actionImageView.image = UIImage(systemName: "arrow.down")
            actionLabel.text = NSLocalizedString("sell", comment: "Sell").capitalizingFirstLetter()
            amountTextField.textColor = .black
            amountTextField.isUserInteractionEnabled = true
        case .receive:
            if let currency = currenciesList[safe: 1] {
                currencyTextField.text = currency
                self.delegate?.didUpdateTo(currency: currency)
            }
            pickerView.selectRow(1, inComponent: 0, animated: false)
            actionImageView.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
            actionImageView.image = UIImage(systemName: "arrow.up")
            actionLabel.text = NSLocalizedString("receive", comment: "Receive").capitalizingFirstLetter()
            amountTextField.textColor = UIColor(named: "GreenColor") ?? .green
            amountTextField.isUserInteractionEnabled = false
        }
        if let amount = model.amount {
            amountTextField.text = String(format: "%.2f", amount)
        } else {
            amountTextField.text = nil
        }
        delegate?.didUpdateFrom(amount: model.amount)
    }
    
    func updateAmountValue(amount: Double) {
        amountTextField.text = String(format: "+ %.2f", amount)
    }
    
    // MARK: - Actions
    @objc func doneAction() {
        self.endEditing(true)
    }
    
    // MARK: - Private methods
    private func prepareUI() {
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0,y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        let flexsibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneButtonAction))
        toolBar.items = [flexsibleSpace, doneButton]
        amountTextField.inputAccessoryView = toolBar
        currencyTextField.inputAccessoryView = toolBar
        
        amountTextField.delegate = self
        currencyTextField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        currencyTextField.inputView = pickerView
    }
    
    @objc func doneButtonAction() {
        self.endEditing(true)
        delegate?.didTapDoneButton()
        
    }
}

// MARK: - TextField delegate
extension CurrencyExchangeTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === currencyTextField {
            if let selectedIndex = currenciesList.firstIndex(where: { $0 == textField.text }) {
                pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
                if cellType == .sell {
                    delegate?.didUpdateFrom(currency: currenciesList[selectedIndex])
                } else {
                    delegate?.didUpdateTo(currency: currenciesList[selectedIndex])
                }
            }
        }
        return
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === amountTextField {
            guard let text = textField.text,
                  let range = Range(range, in: text),
                  let possibleString = textField.text?.replacingCharacters(in: range, with: string) else { return false }
            let centAmountString = possibleString.replacingOccurrences(of: ".", with: "")
            guard let centAmount = Int(centAmountString) else { return false }
            let amount = (Double(centAmount) / 100.0)
            if centAmountString.count <= 18 {
                let amountString = String(format: "%0.2f", amount)
                textField.text = amountString
                delegate?.didUpdateFrom(amount: amount)
            }
            return false
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === amountTextField {
            let number = Double(textField.text ?? "") ?? 0
            textField.text = String(format: "%.2f", number)
        }
    }
}

// MARK: - UIPickerView delegate
extension CurrencyExchangeTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currenciesList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currenciesList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencyTextField.text = currenciesList[row]
        switch cellType {
        case .receive:
            delegate?.didUpdateTo(currency: currenciesList[row])
        case .sell:
            delegate?.didUpdateFrom(currency: currenciesList[row])
        }
    }
}
