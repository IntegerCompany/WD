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
  
    let regionRadius: CLLocationDistance = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getInfoFromApi()
    
  }
  
  @IBAction func book(sender: UIButton) {
    let parameters = ["dish_id": "\(self.dishId)",
    "user_id":"\(Defaults.getUserId())"]
    print(parameters)
    Alamofire.request(.POST,"http://wdl.webdecision.com.ua/api/book",headers:self.headers,parameters:parameters).responseJSON{
      response in
      print(response.result.value!)
    }
  }
  
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 2.0, regionRadius * 2.0)
    wdMap.setRegion(coordinateRegion, animated: true)
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
    self.dishId = dishList[indexPath.row].id
    self.dishName.text = dishList[indexPath.row].name
  }
}
