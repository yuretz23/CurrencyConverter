//
//  MyBalancesTableViewCell.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import UIKit

class MyBalancesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    func configure(balances: [CurrencyBalance]) {
        stackView.subviews.forEach( { $0.removeFromSuperview() })
        for balance in balances {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18,weight: .medium)
            label.text = balance.getFullFormatedString()
            stackView.addArrangedSubview(label)
        }
    }

}
