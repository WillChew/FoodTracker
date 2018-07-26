//
//  SignupViewController.swift
//  FoodTracker
//
//  Created by Will Chew on 2018-07-17.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import UIKit

var user: User!
var requestManager: RequestManager!

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var signupButtonOutlet: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var newUsernameTextField: UITextField!
    var newPasswordTextField: UITextField!
    var alert: UIAlertController!
    var badInfoAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAlert()
        makeBadInfoAlert()
        
        
        
        requestManager = RequestManager()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.usernameTextField.text = usernameTextField.text
        self.passwordTextField.text = passwordTextField.text
        textField.resignFirstResponder()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        let existingUser = User(username: username, password: password)
        UserDefaults.standard.setValuesForKeys([username : password])
        requestManager.loginRequest(existingUser) {
            
            
            
            //push to VC
            DispatchQueue.main.async {
                if UserDefaults.standard.bool(forKey: "wrongInfo") == true {
                    self.present(self.badInfoAlert, animated: true, completion: nil)
                    UserDefaults.standard.set(false, forKey: "wrongInfo")
                }
                // instantiate VC
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "MealTableViewController") as UIViewController
                
                UserDefaults.standard.set(true, forKey: "wasLaunched")
                
                self.navigationController?.pushViewController(rootVC, animated: true)
                
            }
        }
    }
    
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        present(self.alert, animated: true, completion: nil)
        
    }
    
    func createAlert() {
        alert = UIAlertController(title: "Signup", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Signup", style: .default, handler: self.submitButtonPressed2)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField(configurationHandler: usernameTextField)
        alert.addTextField(configurationHandler: passwordTextField)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
    }
    
    func usernameTextField(textField: UITextField!) {
        newUsernameTextField = textField
        newUsernameTextField.placeholder = "Enter a username"
        newUsernameTextField.autocorrectionType = .no
        
    }
    
    func passwordTextField(textField: UITextField!) {
        newPasswordTextField = textField
        newPasswordTextField.placeholder = "Enter a password"
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.autocorrectionType = .no
    }
    
    func submitButtonPressed2(alert: UIAlertAction!){
        guard let username = newUsernameTextField.text, let password = newPasswordTextField.text else {
            return
            
        }
        
        let newUser = User(username: username, password: password)
        UserDefaults.standard.setValuesForKeys([username : password])
        requestManager.signUpRequest(newUser) {
            
            //push to VC
            DispatchQueue.main.async {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "MealTableViewController") as UIViewController
                if UserDefaults.standard.bool(forKey: "existing") == true {
                    self.alert.message = "User already exists"
                    self.present(self.alert, animated: true, completion: nil)
                    UserDefaults.standard.set(false, forKey: "existing")
                    
                } else {
                    self.navigationController?.pushViewController(rootVC, animated: true)
                    UserDefaults.standard.set(true, forKey: "wasLaunched")
                }
            }
        }
        
    }
    
    func makeBadInfoAlert(){
        badInfoAlert = UIAlertController(title: "Log In", message: "Bad credentials", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try Again", style: .destructive) { (action) in }
        
        badInfoAlert.addAction(okAction)
    }
    
    
}
