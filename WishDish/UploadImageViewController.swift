//
//  UploadImageViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class UploadImageViewController: BaseViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dishDescription: UITextField!
    @IBOutlet weak var restaurant: UITextField!
    @IBOutlet weak var instagram: UITextField!
    @IBOutlet weak var image: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var restaurantList = [Restaurant]()
    var restaurantId = 0
    var isRestaurantSelected = false
    var isLocationAccessGranted = false
    
    var coordinates = CLLocationCoordinate2D()
    var street = ""
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        initLocationManager()
    }
    
    override func takePhoto(sender: UIButton) {
            }

    
    @IBAction func chooseImage(sender: AnyObject) {
        self.addPhoto()
    }
    
    @IBAction func uploadImage(sender: UIButton) {
        
        guard let _ = self.image.backgroundImageForState(.Normal) else{
            showAlertMessage("Please, pick image for the dish",handler: nil)
            return
        }
        
        if self.name.text?.characters.count == 0{
            showAlertMessage("Please, fill in dish name",handler: nil)
            return
        }
        
        if self.dishDescription.text?.characters.count == 0{
            showAlertMessage("Please, fill in dish description",handler: nil)
            return
        }
        
        if self.restaurant.text?.characters.count == 0{
            showAlertMessage("Please, choose restaurant from the list",handler: nil)
            return
        }
        
        if !self.isRestaurantSelected{
            showAlertMessage("Please, choose restaurant from the list",handler: nil)
            return
        }
        showProgress(true)
        
        let compressedImage = compressForUploadImage(self.image.backgroundImageForState(.Normal)!, scale: 0.5)
        let data = UIImageJPEGRepresentation(compressedImage, 0.5)
        let encodedImage = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        let parameters = [
            "restaurant_id" : self.restaurantId,
            "description" : self.dishDescription.text!,
            "name" : self.name.text!,
            "photo" : encodedImage!,
            "user_id" : Defaults.getUserId(),
            "url_instagram" : self.instagram.text!
        ]
        
        Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/dish", parameters: parameters as? [String : AnyObject], headers: self.headers).responseJSON {
            response in
            print("Response : \(response.result.value)")
            self.showProgress(false)
            self.showAlertMessage("Dish uploaded succesfully"){
                action in
                self.navigationController?.popViewControllerAnimated(true)
            }
            print(response)
        }
    }
    
    func showProgress(show : Bool){
        self.uploadButton.hidden = show
        self.progressBar.hidden = !show
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
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locationObj, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.street = self.street + String(locationName)
            }else{
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    self.street = self.street + String(street)
                }
            }
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                self.street = self.street + ", \(String(city))"
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                self.street = self.street + ", \(String(country))"
            }
            
            print(self.street)
            
        })
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
            self.restaurantId = self.restaurantList[indexPath.row].id
            self.isRestaurantSelected = true
        }else{
            if isLocationAccessGranted{
                showRestaurantBuilder()
            }else{
                
            }
            self.restaurant.endEditing(true)
        }
    }
    
    func showAlertMessage(message : String, handler : ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: "Upload dish", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler : handler)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    func showRestaurantBuilder(){
        if isLocationAccessGranted{
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
                    "address" : "\(self.street)",
                    "coordinates" : "\(self.coordinates.latitude),\(self.coordinates.longitude)",
                    "url_site" : "\((alertController.textFields![1].text)!)",
                    "url_booking" : "\((alertController.textFields![2].text)!)"
                    ]
                ]
                Alamofire.request(.POST, "http://wdl.webdecision.com.ua/api/restaurant", parameters: parameters, headers: self.headers).response
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
        }else{
            let alertController = UIAlertController(title: "Add new restaurant", message: "Please, enable location access to add new restaurant", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(okAction)
            var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
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
        let url = "http://wdl.webdecision.com.ua/api/restaurants/\(string)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, url,  headers: self.headers).responseJSON {
            response in
            if response.result.value != nil {
                self.restaurantList.removeAll()
                let json = JSON(response.result.value!)
                print(json)
                for (_,subJson):(String, JSON) in json {
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
}
