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
}
extension LoginViewController : FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.")
            if result.grantedPermissions.contains("email")
            {
              let parameters = ["facebook" : [
                "facebook_id" : "\(FBSDKAccessToken.currentAccessToken())"
                ]
              ]
              let headers = [
                "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
              ]
              Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/login", parameters: parameters, headers: headers).responseJSON{
                response in
               let json = JSON(response.result.value!)
                print(response.result.value!)
                Defaults.setUserId(json["user_id"].int!)
              }
          }
          
          self.navigationController?.popViewControllerAnimated(true)
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
