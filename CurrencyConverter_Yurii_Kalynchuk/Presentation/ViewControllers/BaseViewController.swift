//
//  BaseViewController.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    var submitBottomConstraint: NSLayoutConstraint?
    var activitiIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitBottomConstraint = self.view.constraints.first(where: { constraint in
            constraint.identifier == "bottomConstraint"
        })
        setUpKeyboardNotifications()
        setUpIndicator()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    // MARK: - Private func
    private func setUpKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: submitBottomConstraint,
                             keyboardWillShow: true)
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: submitBottomConstraint,
                             keyboardWillShow: false)
    }
    
    private func moveViewWithKeyboard(notification: NSNotification,
                                      viewBottomConstraint: NSLayoutConstraint?,
                                      keyboardWillShow: Bool) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            viewBottomConstraint?.constant = keyboardHeight + (safeAreaExists ? -15 : +15)
        } else {
            viewBottomConstraint?.constant = 15
        }
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    
    private func setUpIndicator() {
        activitiIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activitiIndicatorView)
        activitiIndicatorView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        activitiIndicatorView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        activitiIndicatorView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        activitiIndicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        activitiIndicatorView.style = .large
        activitiIndicatorView.color = UIColor(named: "BlueColor1") ?? .gray
    }
    
    // MARK: - Public func
    func startLoading() {
        activitiIndicatorView.isHidden = false
        activitiIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        activitiIndicatorView.stopAnimating()
        activitiIndicatorView.isHidden = true
    }
}
