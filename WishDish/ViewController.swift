//
//  ViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class ViewController: BaseViewController, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var usetTempImage: UIImageView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if FBSDKAccessToken.currentAccessToken() == nil {
            self.navigationController?.performSegueWithIdentifier("goToLoginScreen", sender: self)
        }else{
            let accessToken = FBSDKAccessToken.currentAccessToken()
            let url = "https://graph.facebook.com/\(accessToken.userID)/picture?type=large&return_ssl_resources=1"
            print(url)
            self.usetTempImage.downloadedFrom(link: url, contentMode: .ScaleAspectFit)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardWillHide(notification: NSNotification) {}
    override func keyboardWillShow(notification: NSNotification) {}
    @IBAction func facebookButton(sender: UIButton) {
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://itunes.apple.com/ru/app/foursquare/id306934924?mt=8")
        content.contentTitle = "Wish dish"
        content.contentDescription = "Best app"
        SocialNetwork.shareWIthFacebookAppUrl(self,content: content)
    }
    @IBAction func instagramButton(sender: UIButton) {
        SocialNetwork.shareWithInstagram(self, baseView: self.view, fromImage: self.usetTempImage)
    }
  
  }


