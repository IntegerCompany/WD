//
//  ViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var usetTempImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if FBSDKAccessToken.currentAccessToken() == nil {
            self.navigationController?.performSegueWithIdentifier("goToLoginScreen", sender: self)
        }
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        let url = "https://graph.facebook.com/\(accessToken.userID)/picture?type=large&return_ssl_resources=1"
        print(url)
        self.usetTempImage.downloadedFrom(link: url, contentMode: .ScaleAspectFit)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

