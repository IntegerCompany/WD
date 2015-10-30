//
//  WishListViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import Alamofire

class WishListViewController: UITableViewController ,UIPopoverPresentationControllerDelegate{
  var popoverContent : MenuViewController!
  var dishes = [Dish]()
  var dishIdList = [Int]()
  let headers = [
    "Hash-Key": "34d1a24d7a47f12b38d49bedbe2ffead"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initBarMenus()
    getDishesFromApi()
    popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dishes.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("WishDish") as! WishDishlistCell
    cell.counter.text = "\(indexPath.row + 1)."
    let url = dishes[indexPath.row].photoUrl
    Alamofire.request(.GET, url)
      .response{ response in
        cell.dishImage.image = UIImage(data: response.2!)
    }
    cell.dishDescription.text = dishes[indexPath.row].name
    
    return cell
  }
  
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {    
    let itemToMove = dishes[fromIndexPath.row]
    dishes.removeAtIndex(fromIndexPath.row)
    dishes.insert(itemToMove, atIndex: toIndexPath.row)
    dishIdList.removeAtIndex(fromIndexPath.row)
    dishIdList.insert(itemToMove.id, atIndex: toIndexPath.row)
    let parameters = ["update" : [
      "user_id" : "\(Defaults.getUserId())",
      "dishes" : dishIdList
      ]
    ]
    Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/likes", parameters: parameters, headers: headers).responseJSON{
      response in
      print(response.result.value)
    }
  }
  
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  @IBAction func reorder(sender: UIButton) {
    if self.tableView.editing {
      self.tableView.setEditing(false, animated: true)
    }else{
      self.tableView.setEditing(true, animated: true)
    }
  }
  
  func initBarMenus(){
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
  
  func getDishesFromApi(){
    Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/likes/\(Defaults.getUserId())", headers: self.headers).responseJSON{
      response in
      print(JSON(response.result.value!))
      let json = JSON(response.result.value!)
      for (_,subJson) : (String, JSON) in json{
        let dish = Dish()
        dish.description = subJson["description"].string!
        dish.restaurantId = Int(subJson["restaurant_id"].string!)!
        dish.id = Int(subJson["id"].string!)!
        dish.instagramUrl = subJson["url_instagram"].string!
        dish.photoUrl = subJson["photo"].string!
        dish.name = subJson["name"].string!
        self.dishes.append(dish)
        self.dishIdList.append(dish.id)
        self.tableView.reloadData()
      }
    }
  }
  
}

extension WishListViewController  : MenuCallBackExtension {
  func menuFromMenu(sender : UIButton){
    self.showMenu()
  }
}