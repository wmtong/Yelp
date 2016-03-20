//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by William Tong on 2/10/16.
//  Copyright (c) 2016 William Tong. All rights reserved.
//

import UIKit
import SVPullToRefresh
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate  {

    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var filteredIndex: [Int]!
    var categories: [String]!
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocation()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.addInfiniteScrollingWithActionHandler(infiniteScroll)
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        setBusinesses(nil, offset: 0, categories: categories, deals: false)
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196/255, green: 18/255, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func setBusinesses(var term: String?, offset: Int, categories: [String]?, deals: Bool?)
    {
        var newdata: [String] = []
        
        if term == nil {
            term = "Restaurants"
        }
        
        Business.searchWithTerm(term!, limit: 20, offset: offset, sort: nil, categories: categories, deals: deals, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            for(var x=0; x<businesses.count; x++){
                newdata.append(businesses[x].name!)
                print(businesses[x].name!)
                print(businesses[x].address!)
            }
            self.data = newdata
        })
    }
    
    //search methods
    var data: [String]?
    var filteredData: [String]!
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = data
            filteredBusinesses = businesses
        } else {
            var tempTitleList: [String] = []
            var tempIndexList: [Int] = []
            var tempBusinesses: [Business] = []
            
            let lcSearch = searchText.lowercaseString
            
            // Go through each element in data
            for var filterIndex = 0; filterIndex < data!.count; ++filterIndex {
                
                // For each that matches the filter
                
                if data![filterIndex].lowercaseString.containsString(lcSearch) {
                    // Add index to temporary list
                    tempTitleList.append(data![filterIndex])
                    tempIndexList.append(filterIndex)
                    tempBusinesses.append(businesses![filterIndex])
                    
                }
            }
            
            // Change filtered list to temporary list
            filteredData = tempTitleList
            filteredBusinesses = tempBusinesses
            filteredIndex = tempIndexList
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    //tableview methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if filteredBusinesses != nil
        {
            return filteredBusinesses.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //scroll methods
    
    var isMoreDataLoading = false
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                loadMoreData()
                // ... Code to load more results ...
            }
        }
    }
    
    func loadMoreData()
    {
        var term = String()
        if let text = searchBar.text
        {
            term = text
        }
        else
        {
            term = "Restaurants"
        }
        Business.searchWithTerm(term, limit: 20, offset: 5, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            if businesses != nil
            {
                for business in businesses
                {
                    self.businesses.append(business)
                }
            }
            for(var x=0; x<businesses.count; x++){
                self.filteredBusinesses.append(businesses[x])
                print(businesses[x].name!)
                print(businesses[x].address!)
            }
        }
        self.tableView.reloadData()
    }
    
    func infiniteScroll()
    {
        loadMoreData()
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    
    var locationManager : CLLocationManager!

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
    
    
/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let business = filteredBusinesses![indexPath!.row]
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.business = business
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
