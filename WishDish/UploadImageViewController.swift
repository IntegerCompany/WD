//
//  UploadImageViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
import Alamofire

class UploadImageViewController: BaseViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dishDescription: UITextField!
    @IBOutlet weak var restaurant: UITextField!
    @IBOutlet weak var instagram: UITextField!
    @IBOutlet weak var image: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    var restaurantList = [Restaurant]()
    var restaurantId = 0
    var isRestaurantSelected = false
    var isLocationAccessGranted = false
    
    var coordinates = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        initLocationManager()
    }
    
    
    @IBAction func chooseImage(sender: AnyObject) {
        self.addPhoto()
    }
    
    @IBAction func uploadImage(sender: UIButton) {
        if self.dishDescription.text?.characters.count == 0{
            print("No dish description")
            return
        }
        if self.restaurant.text?.characters.count == 0{
            print("No restaurant")
            return
        }
        if self.name.text?.characters.count == 0{
            print("No name")
            return
        }
        if !self.isRestaurantSelected{
            print("No restaurant selected")
            return
        }
        let compressedImage = compressForUploadImage(self.image.backgroundImageForState(.Normal)!, scale: 0.5)
        let data = UIImageJPEGRepresentation(compressedImage, 0.5)
        let encodedImage = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        let parameters = [
            "restaurant" : 1,
            "dish" : [
                "description" : "full shit",
                "name" : "testDishFromUser",
                "photo" : encodedImage!,
                "owner" : FBSDKAccessToken.currentAccessToken().userID,
                "url_instagram" : self.instagram.text!
            ]
        ]
        Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/dishes", parameters: parameters, headers: self.headers).responseJSON {
            response in
            print(response)
        }
    }
    
    func setDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
        
        restaurant.delegate = self
    }
    
    func addPhoto() {
        
        let alert = UIAlertController(title: "Upload/Take a Picture", message: "Choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Open Gallery", style: .Default, handler: {
            action in self.getPhotoFromGallery("Open Gallery")
        }))
        alert.addAction(UIAlertAction(title: "Take a Picture", style: .Default, handler: {
            action in self.getPhotoFromGallery("Take a Picture")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func compressForUploadImage(original: UIImage, scale: CGFloat) -> UIImage {
        
        // Calculate new size given scale factor.
        let originalSize: CGSize = original.size
        let newSize: CGSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale)
        
        // Scale the original image to match the new size.
        UIGraphicsBeginImageContext(newSize)
        original.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let compressedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return compressedImage
    }
    
}

extension UploadImageViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getPhotoFromGallery(string: String) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        if string == "Open Gallery" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                picker.sourceType = UIImagePickerControllerSourceType.Camera
            }
        }
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            self.image.setBackgroundImage(pickedImage, forState: .Normal)
            self.image.setTitle("", forState: .Normal)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension UploadImageViewController : CLLocationManagerDelegate{
    
    func initLocationManager() {
        print("Initing location manager")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating finished")
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        self.coordinates = locationObj.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            print("Access granted")
            self.isLocationAccessGranted = true
        }else{
            print("Access denied")
            self.isLocationAccessGranted = false
        }
    }
    
}

extension UploadImageViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RestaurantCell")!
        if self.restaurantList.count != 0{
            cell.textLabel?.text = self.restaurantList[indexPath.row].name
        }else{
            cell.textLabel?.text = "Add new restaurant"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restaurantList.count != 0{
            return restaurantList.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.restaurantList.count != 0 {
            self.restaurant.text = self.restaurantList[indexPath.row].name
            self.restaurant.endEditing(true)
            self.isRestaurantSelected = true
        }else{
            showAlertController()
            self.restaurant.endEditing(true)
        }
    }
    
    func showAlertController(){
        let alertController = UIAlertController(title: "Add new restaurant", message: "Please, fill in the information about the restaurant", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
            textField.addTarget(self, action: "alertTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Site url(optional)"
            textField.keyboardType = .EmailAddress
            
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Booking url(optional)"
            textField.keyboardType = .EmailAddress
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            let parameters = ["restaurant" : [
                "name" : "\((alertController.textFields![0].text)!)",
                "address" : "Shitty St.",
                "coordinates" : "\(self.coordinates.latitude),\(self.coordinates.longitude)",
                "url_site" : "\((alertController.textFields![1].text)!)",
                "url_booking" : "\((alertController.textFields![2].text)!)"
                ]
            ]
            Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/restaurants", parameters: parameters, headers: self.headers).response
                {response in
                    self.restaurantId = Int(String(NSString(data: response.2!, encoding:NSUTF8StringEncoding)!))!
                    self.restaurant.text = (alertController.textFields![0].text)!
                    self.isRestaurantSelected = true
                    self.tableView.hidden = true
            }
        }
        okAction.enabled = false
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    func alertTextFieldDidChange(sender : UITextField){
        if let alertController = self.presentedViewController as? UIAlertController{
            let login = alertController.textFields![0];
            let okAction = alertController.actions[alertController.actions.count-1];
            okAction.enabled = login.text?.characters.count > 1;
        }
    }
}

extension UploadImageViewController : UITextFieldDelegate{
    override func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == restaurant){
            tableView.hidden = false
            getRestaurantsFromApi(restaurant.text!)
        }
        self.activeTextField = textField
        
        if(self.keyboardIsShowing)
        {
            self.arrangeViewOffsetFromKeyboard()
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        getRestaurantsFromApi(txtAfterUpdate as String)
        self.isRestaurantSelected = false
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField == restaurant){
            tableView.hidden = true
        }
    }
    
    func getRestaurantsFromApi(string : String){
        Alamofire.request(.GET, "http://wdl.webdecision.com.ua/api/restaurants/\(string)",  headers: self.headers).responseJSON {
            response in
            self.restaurantList.removeAll()
            let json = JSON(response.result.value!)
            for (_,subJson):(String, JSON) in json {
                var restaurant = Restaurant()
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
