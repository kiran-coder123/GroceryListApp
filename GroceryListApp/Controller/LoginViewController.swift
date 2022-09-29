//
//  LoginViewController.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //MARK: Constants
    let loginToList = "LoginToList"
    var handle: AuthStateDidChangeListenerHandle?

    //MARK: Life cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        // 1
        handle = Auth.auth().addStateDidChangeListener { _, user in
          // 2
          if user == nil {
            self.navigationController?.popToRootViewController(animated: true)
          } else {
            // 3
            self.performSegue(withIdentifier: self.loginToList, sender: nil)
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
          }
        }
//        handle = Auth.auth().addStateDidChangeListener { _, user in
//          guard let user = user else { return }
//          self.user = User(authData: user)
//        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)

         

    }
    
    //MARK: Actions
    @IBAction func loginButtonClicked(_ sender: Any) {
   
        guard
          let email = emailTextField.text,
          let password = passwordTextField.text,
          !email.isEmpty,
          !password.isEmpty
        else { return }

        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(
              title: "Sign In Failed",
              message: error.localizedDescription,
              preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
          }
        }

    }
    
    
    @IBAction func signInButtonClicked(_ sender: Any) {
      //performSegue(withIdentifier: loginToList, sender: nil)
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else { return }
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if error == nil {
                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
                
            } else {
                print("Error in createUser: \(error?.localizedDescription ?? "" )")
            }
        }
   }
}
//MARK: TextField delegates
extension LoginViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
