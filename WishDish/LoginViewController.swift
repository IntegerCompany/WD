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
}
extension LoginViewController : FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.")
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
            self.navigationController?.presentViewController(vc!, animated: true, completion: nil)
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
