//
//  SearchViewController.swift
//  WishDish
//
//  Created by Dmytro Lohush on 11/2/15.
//  Copyright © 2015 integer. All rights reserved.
//

import Foundation
import Alamofire

class SearchViewController : BaseViewController{
  override func viewDidLoad() {
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/screen",headers:self.headers)
  }
}