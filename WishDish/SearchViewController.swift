//
//  SearchViewController.swift
//  WishDish
//
//  Created by Dmytro Lohush on 11/2/15.
//  Copyright © 2015 integer. All rights reserved.
//

import Foundation
import Alamofire

class SearchViewController : UIViewController{
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  let headers = [
    "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
  ]
  var dishList = [Dish]()
  var restaurantList = [Restaurant]()
  
  override func viewDidLoad() {
    tableView.delegate = self
    tableView.dataSource = self
    searchBar.delegate = self
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/screen",headers:self.headers)
    getRestaurantsFromApi("")
    getDishesFromApi("")
  }
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    self.tableView.reloadData()
  }
  
  func getDishesFromApi(name : String){
    let url = "http://wdl.webdecision.com.ua/api/dishes/\(name)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    Alamofire.request(.GET, url ,headers:self.headers).responseJSON{response in
      self.dishList.removeAll()
      let data = JSON(response.result.value!)
      for (_,subJson):(String, JSON) in data {
        let dish = Dish()
        dish.description = subJson["description"].string!
        dish.restaurantId = Int(subJson["restaurant_id"].string!)!
        dish.id = Int(subJson["id"].string!)!
        dish.instagramUrl = subJson["url_instagram"].string!
        dish.photoUrl = subJson["photo"].string!
        dish.name = subJson["name"].string!
        self.dishList.append(dish)
      }
      self.tableView.reloadData()
    }
  }
  
  func getRestaurantsFromApi(name : String){
    let url = "http://wdl.webdecision.com.ua/api/restaurants/\(name)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    
    Alamofire.request(.GET, url ,headers:self.headers).responseJSON{response in
      self.restaurantList.removeAll()
      let data = JSON(response.result.value!)
      for (_,subJson):(String, JSON) in data {
        let restaurant = Restaurant()
        restaurant.adress = subJson["address"].string!
        restaurant.id = Int(subJson["id"].string!)!
        restaurant.name = subJson["name"].string!
        restaurant.bookingUrl = subJson["url_booking"].string!
        restaurant.siteUrl = subJson["url_site"].string!
        let coordinateString = subJson["coordinates"].string!
        let coordinatesArr = coordinateString.characters.split{$0 == ","}.map(String.init)
        restaurant.latitude = Double(coordinatesArr[0])!
        restaurant.longitude = Double(coordinatesArr[1])!
        self.restaurantList.append(restaurant)
      }
      self.tableView.reloadData()
    }

  }
  
  
}

extension SearchViewController : UISearchBarDelegate{
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if(segmentControl.selectedSegmentIndex == 0){
      getDishesFromApi(searchText)
    }else{
      getRestaurantsFromApi(searchText)
    }
  }
  
  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.endEditing(true)
  }
}

extension SearchViewController : UITableViewDataSource,UITableViewDelegate{
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell") as! SearchCell
    if(segmentControl.selectedSegmentIndex == 0){
      cell.name.text = dishList[indexPath.row].name
    }else{
      cell.name.text = restaurantList[indexPath.row].name
    }
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if(segmentControl.selectedSegmentIndex == 0){
      let restaurantDetail = self.storyboard?.instantiateViewControllerWithIdentifier("SearchForRestaurantController") as! SearchForRestaurantController
      restaurantDetail.restaurantId = self.dishList[indexPath.row].restaurantId
      restaurantDetail.dishId = self.dishList[indexPath.row].id
      self.navigationController?.pushViewController(restaurantDetail, animated: true)
    }else{
      let restaurantDetail = self.storyboard?.instantiateViewControllerWithIdentifier("SearchForRestaurantController") as! SearchForRestaurantController
      restaurantDetail.restaurantId = self.restaurantList[indexPath.row].id
            self.navigationController?.pushViewController(restaurantDetail, animated: true)
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(segmentControl.selectedSegmentIndex == 0){
      return dishList.count
    }else{
      return restaurantList.count
    }
  }
  
}