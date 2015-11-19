//
//  LoginViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class LoginViewController: UIViewController {
  let headers = [
    "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
  ]
  
  @IBOutlet weak var fbLoginButton: FBSDKLoginButton? = FBSDKLoginButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if FBSDKAccessToken.currentAccessToken() == nil {
      print("Not logged in..")
    }else{
      print("Logged in..")
    }
    self.fbLoginButton!.readPermissions = ["public_profile", "email", "user_friends"]
    self.fbLoginButton!.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.navigationBar.hidden = true
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.navigationController?.navigationBar.hidden = false
  }
  
  @IBAction func loginWithEmail(sender: UIButton) {
    showLoginView()
  }
  
  @IBAction func register(sender: UIButton) {
    showRegistrationView()
  }
  
  func showLoginView(){
    let alertController = UIAlertController(title: "Login", message: "Please, fill in email and password", preferredStyle: .Alert)
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Email"
      textField.keyboardType = .EmailAddress
      textField.addTarget(self, action: "loginTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Password"
      textField.secureTextEntry = true
      textField.addTarget(self, action: "loginTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
      // ...asd
    }
    alertController.addAction(cancelAction)
    
    let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
      let parameters = ["check_user" : [
        "login" : "\(alertController.textFields![0].text!)",
        "password" : "\(alertController.textFields![1].text!)"
        ]
      ]
      print(parameters)
      Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/user", parameters: parameters, headers: self.headers).responseJSON{
        response in
        let json = JSON(response.result.value!)
        print(response.result.value!)
        if(json["id"].intValue != 0){
          print(json["id"].intValue)
          Defaults.setUserId(json["id"].intValue)
          self.navigationController?.popViewControllerAnimated(true)
        }else{
          self.showAlertMessage("Incorrect login or password")
        }
      }
    }
    okAction.enabled = false
    alertController.addAction(okAction)
    
    self.presentViewController(alertController, animated: true) {
      // ...
    }
    
  }
  
  func showRegistrationView(){
    let alertController = UIAlertController(title: "Register", message: "Please, fill in email and password", preferredStyle: .Alert)
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Email"
      textField.keyboardType = .EmailAddress
      textField.addTarget(self, action: "registerTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Password"
      textField.secureTextEntry = true
      textField.addTarget(self, action: "registerTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Confirm password"
      textField.secureTextEntry = true
      textField.addTarget(self, action: "registerTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
      // ...asd
    }
    alertController.addAction(cancelAction)
    
    let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
      let parameters = ["new_user" : [
        "login" : "\(alertController.textFields![0].text!)",
        "password" : "\(alertController.textFields![1].text!)"
        ]
      ]
      print(parameters)
      Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/user", parameters: parameters, headers: self.headers).responseJSON{
        response in
        let json = JSON(response.result.value!)
        print(response.result.value!)
        if(json["user_id"].intValue != 0){
          print(json["user_id"].intValue)
          Defaults.setUserId(json["user_id"].intValue)
          self.navigationController?.popViewControllerAnimated(true)
        }else{
          self.showAlertMessage("Couldn`t register new user, please try again")
        }
      }
    }
    okAction.enabled = false
    alertController.addAction(okAction)
    
    self.presentViewController(alertController, animated: true) {
      // ...
    }
  }
  
  func showAlertMessage(message : String){
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler : nil)
    alertController.addAction(okAction)
    self.presentViewController(alertController, animated: true) {
      // ...
    }
  }
  
  func loginTextFieldDidChange(sender : UITextField){
    if let alertController = self.presentedViewController as? UIAlertController{
      let email = alertController.textFields![0];
      let password = alertController.textFields![1];
      let okAction = alertController.actions[alertController.actions.count-1];
      okAction.enabled = (email.text?.characters.contains("@"))!
        && email.text?.characters.count > 4
        && password.text?.characters.count > 3
    }
  }
  
  func registerTextFieldDidChange(sender : UITextField){
    if let alertController = self.presentedViewController as? UIAlertController{
      let email = alertController.textFields![0];
      let password = alertController.textFields![1];
      let confirmPassword = alertController.textFields![2];
      let okAction = alertController.actions[alertController.actions.count-1];
      okAction.enabled = (email.text?.characters.contains("@"))!
        && email.text?.characters.count > 4
        && password.text?.characters.count > 3
        && confirmPassword.text! == password.text!
    }
  }
}

extension LoginViewController : FBSDKLoginButtonDelegate {
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
  {
    if error == nil
    {
      print("Login complete.")
      if result.grantedPermissions.contains("email")
      {
        let parameters = [
          "user_id" : "\(FBSDKAccessToken.currentAccessToken().userID!)"
        ]
        let headers = [
          "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
        ]
        print(parameters)
        Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/user", parameters: parameters, headers: headers).responseJSON{
          response in
          let json = JSON(response.result.value!)
          print(response.result.value!)
          if(json["user_id"].intValue != 0){
            print(json["user_id"].intValue)
            Defaults.setUserId(json["user_id"].intValue)
            self.navigationController?.popViewControllerAnimated(true)
          }else{
            self.showAlertMessage("Some error occured, please try again")
          }
        }
      }
    }
    else
    {
      print(error.localizedDescription)
    }
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
  {
    print("User logged out...")
  }
}
