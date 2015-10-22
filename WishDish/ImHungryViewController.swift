//
//  ImHungryViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

class ImHungryViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      initSwipeGestures()
    }
  func initSwipeGestures(){
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    
    leftSwipe.direction = .Left
    rightSwipe.direction = .Right
    
    view.addGestureRecognizer(leftSwipe)
    view.addGestureRecognizer(rightSwipe)
  }
  
  //TODO: implement logic to swipes
  func handleSwipes(sender:UISwipeGestureRecognizer) {
    if (sender.direction == .Left) {
      print("Swipe Left")      
    }
    
    if (sender.direction == .Right) {
      print("Swipe Right")
    }
  }


}
