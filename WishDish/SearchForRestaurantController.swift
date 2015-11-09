//
//  SearchForRestaurantController.swift
//  WishDish
//
//  Created by Max Vitruk on 15.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import FBSDKShareKit
import FBSDKLoginKit

class SearchForRestaurantController: BaseViewController {
  
  @IBOutlet weak var wdlButton: UIButton!
  @IBOutlet weak var nextDishButton: UIButton!
  @IBOutlet weak var bookDishButton: UIButton!
  @IBOutlet weak var likeDishButton: UIButton!
  @IBOutlet weak var wdMap: MKMapView!
  
  @IBOutlet weak var dishName: UILabel!
  @IBOutlet weak var restaurantName: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var website: UILabel!
  
  var restaurantId = 0;
  var dishId = 0;
  var dishList = [Dish]()
  var wishDishIdList = [Int]()
  var counter = 0{
    didSet{
      setInfo()
    }
  }
  var isCustomSegue = false
  
  let regionRadius: CLLocationDistance = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getInfoFromApi()
  }
  override func willMoveToParentViewController(parent: UIViewController?) {
    print("Move to \(parent?.nibName)")
  }
  
  override func viewWillDisappear(animated: Bool) {
    if !self.isCustomSegue {
      let parent = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 1] as! ImHungryViewController
      parent.wishDishIdList = self.wishDishIdList
      parent.setInfo()
    }
  }
  
  override func takePhoto(sender: UIButton) {
    self.isCustomSegue = true
    super.takePhoto(sender)
  }
  
  override func keyboardWillHide(notification: NSNotification) {}
  
  override func keyboardWillShow(notification: NSNotification) {}
  
  @IBAction func shareToFacebook(sender: UIButton) {
    if FBSDKAccessToken.currentAccessToken() != nil {
      makeSharingContent()
    }else{
      isCustomSegue = true
      let login = FBSDKLoginManager()
      login.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self, handler: { (result, error) -> Void in
        if (error != nil) {
          print("Process error")
        } else if (result.isCancelled) {
          print("Cancelled")
        } else {
          print("Logged in");
          let parameters = ["update_user" : [
            "facebook" : "\(FBSDKAccessToken.currentAccessToken().userID)",
            "user_id" : "\(Defaults.getUserId())"
            ]
          ]
          print(parameters)
          Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/user", parameters: parameters, headers: self.headers).responseJSON{
            response in
            let json = JSON(response.result.value!)
            print(response.result.value!)
            if(response.result.value! as! NSNumber == 1){
              print("updated successfully")
              Defaults.setUserId(json["id"].intValue)
              self.makeSharingContent()
            }
          }         
        }
      })
    }
  }
  @IBAction func nextDish(sender: AnyObject) {
    if counter < dishList.count-1 {
      counter++
    }
  }
  
  @IBAction func addToWishList(sender: AnyObject) {
    if !self.wishDishIdList.contains(dishId){
      self.wishDishIdList.append(dishId)
      setInfo()
      print("Adding to wishlist : \(dishId)")
      let parameters = ["new" : [
        "user_id" : "\(Defaults.getUserId())",
        "dishes" : "\(dishId)"
        ]
      ]
      Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/likes", parameters: parameters, headers: self.headers).responseJSON{
        response in
        print(response.result.value)
      }
    }else{
      self.wishDishIdList = wishDishIdList.filter{$0 != dishId}
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
  
  @IBAction func goToWishList(sender: UIButton) {
    self.isCustomSegue = true
    let wishLish = self.storyboard?.instantiateViewControllerWithIdentifier("WishListViewController") as! WishListViewController
    self.navigationController?.pushViewController(wishLish, animated: true)
  }
  
  @IBAction func book(sender: UIButton) {
    //TODO: booking
    //    let url = NSURL(string: "https://google.com")!
    //    UIApplication.sharedApplication().openURL(url)
    let parameters = ["dish_id": "\(self.dishId)",
      "user_id":"\(Defaults.getUserId())"]
    print(parameters)
    Alamofire.request(.POST,"http://wdl.webdecision.com.ua/api/book",headers:self.headers,parameters:parameters).responseJSON{
      response in
      print(response.result.value!)
    }
  }
  
  func makeSharingContent(){
    let photo = FBSDKSharePhoto()
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: counter, inSection: 0)) as! SearchDishCell
    photo.image = cell.dishImage.image!
    photo.userGenerated = true
    let content = FBSDKSharePhotoContent()
    content.photos = [photo]
    let dialog = FBSDKShareDialog()
    dialog.fromViewController = self
    dialog.shareContent = content
    dialog.mode = .ShareSheet
    dialog.show()
  }
  
  func setInfo(){
    self.dishName.text = self.dishList[counter].name
    self.dishId = dishList[counter].id
    if self.wishDishIdList.contains(dishList[counter].id){
      self.likeDishButton.setBackgroundImage(UIImage(named: "liked"), forState: .Normal)
    }else{
      self.likeDishButton.setBackgroundImage(UIImage(named: "wd_love_wd"), forState: .Normal)
    }
    if(self.counter != 0){
      let indexPath = NSIndexPath(forRow: self.counter, inSection: 0)
      tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
  }
  
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 2.0, regionRadius * 2.0)
    wdMap.setRegion(coordinateRegion, animated: true)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = location.coordinate
    annotation.title = "\(self.restaurantName.text!)"
    wdMap.addAnnotation(annotation)
  }
  
  func getInfoFromApi(){
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/restaurant/\(self.restaurantId)/\(self.dishId)", headers: self.headers).responseJSON{
      response in
      print("http://wdl.webdecision.com.ua/api/restaurant/\(self.restaurantId)/\(self.dishId)")
      print(JSON(response.result.value!))
      let json = JSON(response.result.value!)
      for (_,subJson):(String,JSON) in json["dishes"]{
        let dish = Dish()
        dish.description = subJson["description"].string!
        dish.restaurantId = Int(subJson["restaurant_id"].string!)!
        dish.id = Int(subJson["id"].string!)!
        dish.instagramUrl = subJson["url_instagram"].string!
        dish.photoUrl = subJson["photo"].string!
        dish.name = subJson["name"].string!
        if(dish.id == self.dishId){
          self.dishName.text = dish.name
        }
        self.dishList.append(dish)
      }
      self.dishId = self.dishList[0].id
      self.setInfo()
      self.restaurantName.text = json["restaurant"]["name"].string!
      self.address.text = json["restaurant"]["address"].string!
      self.website.text = json["restaurant"]["url_site"].string!
      let coordinates = json["restaurant"]["coordinates"].string!
      let coordinatesArr = coordinates.characters.split{$0 == ","}.map(String.init)
      let initialLocation = CLLocation(latitude: Double(coordinatesArr[0])!, longitude: Double(coordinatesArr[1])!)
      self.centerMapOnLocation(initialLocation)
      self.tableView.reloadData()
    }
  }
}


extension SearchForRestaurantController : UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dishList.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SearchDishCell") as! SearchDishCell
    Alamofire.request(.GET, dishList[indexPath.row].photoUrl)
      .response{ response in
        cell.dishImage.image = UIImage(data: response.2!)
    }
    return cell
  }
}
extension SearchForRestaurantController : UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.counter = indexPath.row
  }
}
