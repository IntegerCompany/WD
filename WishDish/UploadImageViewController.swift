//
//  UploadImageViewController.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

class UploadImageViewController: BaseViewController {
  
  
  @IBOutlet weak var dishDescription: UITextField!
  @IBOutlet weak var restaurant: UITextField!
  @IBOutlet weak var instagram: UITextField!
  @IBOutlet weak var image: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func chooseImage(sender: AnyObject) {
    self.addPhoto()
  }
  
  @IBAction func uploadImage(sender: UIButton) {
    //TODO: upload function
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
      self.image.setBackgroundImage(pickedImage, forState: .Normal)
      self.image.setTitle("", forState: .Normal)
    }
    dismissViewControllerAnimated(true, completion: nil)
    
  }
}