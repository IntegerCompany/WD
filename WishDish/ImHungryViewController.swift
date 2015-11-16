//
//  ImHungryViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKShareKit

class ImHungryViewController: BaseViewController ,UIDocumentInteractionControllerDelegate{
  
  var counter = 0
  var dishList = [Dish]()
  var wishDishIdList = [Int]()
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  private var documentController = UIDocumentInteractionController!()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getDishes()
    initSwipeGestures()
  }
  
  override func keyboardWillShow(notification: NSNotification) {}
  override func keyboardWillHide(notification: NSNotification) {}
  
  @IBAction func shareToFacebook(sender: UIButton) {
    if FBSDKAccessToken.currentAccessToken() != nil {
      let photo = FBSDKSharePhoto()
      photo.image = image.image!
      photo.userGenerated = true
      let content = FBSDKSharePhotoContent()
      content.photos = [photo]
      let dialog = FBSDKShareDialog()
      dialog.fromViewController = self
      dialog.shareContent = content
      dialog.mode = .ShareSheet
      dialog.show()
    }
  }
  
  @IBAction func shareToInstagram(sender: UIButton) {
    postToInstagram()
  }
  
  @IBAction func goToWishLish(sender: UIButton) {
    let wishLish = self.storyboard?.instantiateViewControllerWithIdentifier("WishListViewController") as! WishListViewController
    self.navigationController?.pushViewController(wishLish, animated: true)
  }
  
  @IBAction func dislike(sender: UIButton) {
    if(dishList.count != 0){
      counter++
      setInfo()
    }
  }
  
  @IBAction func like(sender: UIButton) {
    let restaurantDetail = self.storyboard?.instantiateViewControllerWithIdentifier("SearchForRestaurantController") as! SearchForRestaurantController
    restaurantDetail.restaurantId = self.dishList[counter].restaurantId
    restaurantDetail.dishId = self.dishList[counter].id
    restaurantDetail.wishDishIdList = self.wishDishIdList
    self.navigationController?.pushViewController(restaurantDetail, animated: true)
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
  
  func postToInstagram(){
    
    let instagramUrl = NSURL(string: "instagram://app")
    if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
      
      //Instagram App avaible
      
      let imageData = UIImageJPEGRepresentation(image.image!, 100)
      let captionString = "Your Caption"
      let writePath = NSTemporaryDirectory().stringByAppendingPathComponent("instagram.igo")
      
      if(!imageData!.writeToFile(writePath, atomically: true)){
        //Fail to write. Don't post it
        return
      } else{
        //Safe to post
        
        let fileURL = NSURL(fileURLWithPath: writePath)
        self.documentController = UIDocumentInteractionController(URL: fileURL)
        self.documentController.delegate = self
        self.documentController.UTI = "com.instagram.exclusivegram"
        self.documentController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
        self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
      }
    } else {
      //Instagram App NOT avaible...
    }
  }
  
  func getDishes(){
    let headers = [
      "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
    ]
    print("http://wdl.webdecision.com.ua/api/dish/\(Defaults.getUserId())")
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/dish/\(Defaults.getUserId())", headers:headers)
      .responseJSON{ response in
        if response.result.value != nil {
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
          if self.dishList.count != 0{
            self.setInfo()
          }
          
        }
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
        self.likeButton.setBackgroundImage(UIImage(named: "liked"), forState: .Normal)
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
