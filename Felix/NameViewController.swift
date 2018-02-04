//
//  NameViewController.swift
//  Felix
//
//  Created by Kevin Tan on 2/3/18.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        nameTextField.inputAccessoryView = keyboardToolbar
        nameTextField.delegate = self
        
        for subview in view.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if UIApplication.shared.applicationState != .active {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - (self.view.frame.height - nameTextField.frame.maxY - 25)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if UIApplication.shared.applicationState != .active {
            return
        }

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height - (self.view.frame.height - nameTextField.frame.maxY - 25)
            }
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension NameViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text else {
            nextButton.isHidden = true
            return
        }
        
        if text.isEmpty {
            nextButton.isHidden = true
        }
        
        else {
            nextButton.isHidden = false
        }
        
    }
    
}

