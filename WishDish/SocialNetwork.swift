//
//  SocialNetwork.swift
//  WishDish
//
//  Created by Max Vitruk on 15.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class SocialNetwork {
    
    class func shareWithInstagram(controller : UIDocumentInteractionControllerDelegate, baseView : UIView, fromImage : UIImageView){
        let instagramURL = NSURL(string: "instagram://app")!
        if UIApplication.sharedApplication().canOpenURL(instagramURL) {
            let documentDirectory = NSHomeDirectory().stringByAppendingPathComponent("Documents")
            let saveImagePath = documentDirectory.stringByAppendingPathComponent("Image.igo")
            let imageData = UIImagePNGRepresentation(fromImage.takeSnapshot(W: 640, H: 640))
            imageData!.writeToFile(saveImagePath, atomically: true)
            let imageURL = NSURL.fileURLWithPath(saveImagePath)
            let docController  = UIDocumentInteractionController()
            docController.delegate = controller
            docController.UTI = "com.instagram.exclusivegram"
            docController.URL = imageURL
            docController.presentOpenInMenuFromRect(CGRectZero, inView: baseView, animated: true)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://instagram.com")!)
        }
    }
    
    class func shareWIthFacebookAppUrl(controller : UIViewController, content : FBSDKShareLinkContent){
        FBSDKShareDialog.showFromViewController(controller, withContent: content, delegate: nil)
    }
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}

extension UIView {
    func takeSnapshot(W W: CGFloat, H: CGFloat) -> UIImage {
        let cropRect = CGRectMake(0, 0, 600, 600)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(cropRect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        image.imageWithNewSize(CGSizeMake(W, H))
        return image
    }
}

extension UIImage {
    func imageWithNewSize(newSize:CGSize) ->UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return newImage
    }
}
