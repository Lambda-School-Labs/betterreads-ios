//
//  ForgotPasswordViewController.swift
//  BetterReads
//
//  Created by Ciara Beitel on 4/30/20.
//  Copyright © 2020 Labs23. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    var userController: UserController?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var successOrFailureMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        successOrFailureMessage.text = " "
        doneButton.layer.cornerRadius = 5
        
        // Dismiss the keyboard on tap
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        // Register View Controller as Observer
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChange(_ notification: Notification) {
        doneButton.backgroundColor = .catalinaBlue

        let (valid, _) = validate(emailTextField)
        guard valid else {
            doneButton.backgroundColor = .tundra
            doneButton.isEnabled = false
            return
        }

        doneButton.backgroundColor = .catalinaBlue
        doneButton.isEnabled = true
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        let (valid, _) = validate()
        if valid {
            guard let emailAddress = emailTextField.text,
                let userController = userController else { return }
            
            userController.forgotPasswordEmail(emailAddress: emailAddress) { (networkError) in
                if let error = networkError {
                    let alert = UIAlertController(title: "Forgot Password Error", message: "An error occured while submitting your request,\nplease try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    NSLog("Error occured during Forgot Password: \(error)")
                } else {
                    print("Forgot password reset in progress...")
                }
            }
        }
    }
    
    private func validate(_ field: UITextField? = nil) -> (Bool, String?) {
        do {
            let _ = try emailTextField.validatedText(validationType: .email(field: "email"))
            return (true, nil)
        } catch(let error) {
            let convertedError = (error as! ValidationError)
            return (false, convertedError.message)
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let (valid, message) = validate()
        if valid {
            self.successOrFailureMessage.text = " "
            emailTextField.resignFirstResponder()
            return true
        }
        self.successOrFailureMessage.text = message
        return true
    }
}