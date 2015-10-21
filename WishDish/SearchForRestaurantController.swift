//
//  SearchForRestaurantController.swift
//  WishDish
//
//  Created by Max Vitruk on 15.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit
import MapKit

class SearchForRestaurantController: UIViewController {
    
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
    
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerMapOnLocation(initialLocation)

    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        wdMap.setRegion(coordinateRegion, animated: true)
    }
}


extension SearchForRestaurantController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchDishCell") as! SearchDishCell
        return cell
    }
}
extension SearchForRestaurantController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
