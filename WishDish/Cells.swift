//
//  Cells.swift
//  WishDish
//
//  Created by Max Vitruk on 15.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

class SearchDishCell : UITableViewCell {
    @IBOutlet weak var dishImage: UIImageView!
}

class SearchCell : UITableViewCell{
  
  @IBOutlet weak var name: UILabel!
}

class WishDishlistCell : UITableViewCell{
  @IBOutlet weak var dishImage: UIImageView!
  @IBOutlet weak var counter: UILabel!
  @IBOutlet weak var dishDescription: UILabel!
  
  @IBAction func yButton(sender: UIButton) {
  }
  @IBAction func nButton(sender: UIButton) {
  }
}

