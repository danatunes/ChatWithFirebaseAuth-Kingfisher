//
//  RegistrationViewController.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 27.04.2021.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var registrationButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registrationButton.layer.cornerRadius = 4
        registrationButton.layer.masksToBounds = true
        setUpUI()
    }
    
    private func setUpUI(){
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(registrationButton)
    }
    
    ///SIGN UP
    @IBAction func registrationButtonPressed(_ sender: UIButton) {
        
        guard  let email = emailTextField.text else {
            print("... email nil")
            return
        }
        guard let password = passwordTextField.text else {
            print("... password nil")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            error != nil ? self?.errorLabel.text = error?.localizedDescription : self?.performSegue(withIdentifier: "goToChatFromRegistration", sender: nil)
        }
        
        
    }
}
