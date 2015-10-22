//
//  BaseViewController.swift
//  WishDish
//
//  Created by Dmytro Lohush on 10/22/15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

protocol MenuCallBackExtension {  
  func menuFromMenu(sender : UIButton)
}

class BaseViewController: UIViewController, UIPopoverPresentationControllerDelegate {
  
  var popoverContent : MenuViewController!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController

    
    let rightView = UIView(frame:  CGRectMake(0, 0, 80, 30))
    rightView.backgroundColor = UIColor.clearColor()
    
    let btn1 = UIButton(frame: CGRectMake(0,0,30, 30))
    btn1.setImage(UIImage(named: "back_wd"), forState: UIControlState.Normal)
    btn1.tag=101
    btn1.addTarget(self, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
    rightView.addSubview(btn1)
    
    let btn2 = UIButton(frame: CGRectMake(40,0,30, 30))
    btn2.setImage(UIImage(named: "fb_wd"), forState: UIControlState.Normal)
    btn2.tag=102
    btn2.addTarget(self, action: "menuFromMenu:", forControlEvents: UIControlEvents.TouchUpInside)
    rightView.addSubview(btn2)
    
    
    let rightBtn = UIBarButtonItem(customView: rightView)
    self.navigationItem.rightBarButtonItem = rightBtn;
    // Do any additional setup after loading the view.
  }
  
  func showMenu() {
    popoverContent!.modalPresentationStyle = UIModalPresentationStyle.Popover
    popoverContent!.preferredContentSize = CGSizeMake(100,100)
    let nav = popoverContent!.popoverPresentationController
    nav?.delegate = self
    nav?.sourceView = self.view
    let xPosition = self.view.frame.width
    let yPosition = self.view.frame.minY + 52
    nav?.permittedArrowDirections = UIPopoverArrowDirection.Up
    nav?.sourceRect = CGRectMake(xPosition, yPosition , 0, 0)
    self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
    
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }

}

extension BaseViewController  : MenuCallBackExtension {
  func menuFromMenu(sender : UIButton){
    self.showMenu()
  }
}

