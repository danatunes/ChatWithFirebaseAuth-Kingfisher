//
//  LoginViewController.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 27.04.2021.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 4
        loginButton.layer.masksToBounds = true
        
        setUpUI()
    }

    private func setUpUI(){
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    ///SIGN IN 
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text else {
            print("... email nil")
            return
        }
        guard let password = passwordTextField.text else {
            print("... password nil")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                //                print("... \(error.localizedDescription)")
                self?.errorLabel.text = error.localizedDescription
            }else{
                self?.performSegue(withIdentifier: "goToChatFromLogin", sender: nil)
            }
        }
    }
}
