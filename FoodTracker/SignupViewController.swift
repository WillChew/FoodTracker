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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAlert()
        
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
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
    
    let newUser = User(username: username, password: password)
        UserDefaults.standard.setValuesForKeys([username : password])
        requestManager.signUpRequest(newUser) {
            // instantiate VC
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "MealTableViewController") as UIViewController
            //push to VC
            DispatchQueue.main.async {
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
        
    
}
}
