//
//  DetailsViewController.swift
//  Yelp
//
//  Created by William Tong on 2/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//
import MapKit
import UIKit
import CoreLocation

class DetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    var locationManager : CLLocationManager!
    var business: Business!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        initProperties()
        setLocation()
    }
    
    
    func initProperties()
    {
        businessImageView.setImageWithURL(business.imageURL!)
        nameLabel.text = business.name!
        ratingImageView.setImageWithURL(business.ratingImageURL!)
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        categoriesLabel.text = business.categories!
        distanceLabel.text = business.distance!
        addressLabel.text = business.address!
        addAnnotationAtCoordinate(business.location!.coordinate, annotationTitle: business.name!, annotationSubtitle: business.address!)
    }
    
    //location manager methods
    func setLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first
            {
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(location.coordinate, span)
                mapView.setRegion(region, animated: false)
        }
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, annotationTitle: String, annotationSubtitle: String)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = annotationTitle
        annotation.subtitle = annotationSubtitle
        mapView.addAnnotation(annotation)
        print(annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
