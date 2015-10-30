//
//  ImHungryViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import Alamofire

class ImHungryViewController: BaseViewController {
  
  var counter = 0
  var dishList = [Dish]()
  var wishDishIdList = [Int]()
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getDishes()
    initSwipeGestures()
  }
  
  @IBAction func dislike(sender: UIButton) {
    if(dishList.count != 0){
      counter++
      setInfo()
    }
  }
  
  @IBAction func like(sender: UIButton) {
  }
  
  @IBAction func addToWishList(sender: UIButton) {
    
    if(dishList.count != 0){
      if !self.wishDishIdList.contains(self.dishList[counter].id){
        self.wishDishIdList.append(dishList[counter].id)
        setInfo()
        print("Adding to wishlist : \(dishList[counter].id)")
        let parameters = ["new" : [
          "user_id" : "\(Defaults.getUserId())",
          "dishes" : "\(dishList[counter].id)"
          ]
        ]
        Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/likes", parameters: parameters, headers: self.headers).responseJSON{
          response in
          print(response.result.value)
        }
      }else{
        self.wishDishIdList = wishDishIdList.filter{$0 != dishList[counter].id}
        setInfo()
        let parameters = ["update" : [
          "user_id" : "\(Defaults.getUserId())",
          "dishes" : wishDishIdList
          ]
        ]
        print("Removing from wishlist : \(JSON(parameters))")
        Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/likes", parameters: parameters, headers: self.headers).responseJSON{
          response in
          print(response.result.value)
        }
      }
    }
  }
  
  func getDishes(){
      let headers = [
      "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
    ]
    
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/dishes/\(Defaults.getUserId())", headers:headers)
      .responseJSON{ response in
        self.wishDishIdList.removeAll()
        self.dishList.removeAll()
        let data = JSON(response.result.value!)
        print(data)
        print(data["liked_dishes"])
        for (_,subJson):(String, JSON) in data["liked_dishes"] {
          self.wishDishIdList.append(Int(subJson.rawString()!)!)
        }
        for (_,subJson):(String, JSON) in data["random_dishes"] {
          let dish = Dish()
          dish.description = subJson["description"].string!
          dish.restaurantId = Int(subJson["restaurant_id"].string!)!
          dish.id = Int(subJson["id"].string!)!
          dish.instagramUrl = subJson["url_instagram"].string!
          dish.photoUrl = subJson["photo"].string!
          dish.name = subJson["name"].string!
          self.dishList.append(dish)
        }
        self.counter = 0
        self.setInfo()
    }
  }
  
  func setInfo(){
    if case 0...dishList.count-1 = self.counter {
      let url = self.dishList[counter].photoUrl
      Alamofire.request(.GET, url)
        .response{ response in
          self.image.image = UIImage(data: response.2!)
      }
      self.name.text = self.dishList[counter].name
      if wishDishIdList.contains(self.dishList[counter].id){
        self.likeButton.setBackgroundImage(UIImage(named: "instagram_wd"), forState: .Normal)
      }else{
        self.likeButton.setBackgroundImage(UIImage(named: "wd_love_wd"), forState: .Normal)
      }
    }else{
      getDishes()
    }
  }
  
  func initSwipeGestures(){
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    
    leftSwipe.direction = .Left
    rightSwipe.direction = .Right
    
    view.addGestureRecognizer(leftSwipe)
    view.addGestureRecognizer(rightSwipe)
  }
  
  func handleSwipes(sender:UISwipeGestureRecognizer) {
    if(dishList.count != 0){
      if (sender.direction == .Left) {
        counter++
        setInfo()
      }
      if (sender.direction == .Right) {
        if counter != 0{
          counter--
          setInfo()
        }
      }
    }
  }
  
}
