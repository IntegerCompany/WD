//
//  Defaults.swift
//  WishDish
//
//  Created by Dmytro Lohush on 10/30/15.
//  Copyright © 2015 integer. All rights reserved.
//

import Foundation

class Defaults {
  
  private static let UserId = "USER_ID"
  
  class func setUserId(userId : Int){
    NSUserDefaults.standardUserDefaults().setObject(userId,
      forKey: Defaults.UserId
    )
  }
  
  class func getUserId() -> (Int){
    let userId = NSUserDefaults.standardUserDefaults().integerForKey(Defaults.UserId)
    return userId
  }
  
}
