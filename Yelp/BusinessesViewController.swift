//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {

    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var filteredIndex: [Int]!
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var newdata: [String] = []

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar

        
        Business.searchWithTerm("Restaurants", offset: 20, completion: { (businesses: [Business]!, error: NSError!) -> Void in
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
            
            // Go through each element in data
            for var filterIndex = 0; filterIndex < data!.count; ++filterIndex {
                
                // For each that matches the filter
                
                if data![filterIndex].lowercaseString.containsString(searchText) {
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
        //searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filteredBusinesses != nil){
            return filteredBusinesses.count
        }else{
            return 0
        }
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
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
    
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
       // let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
         //   completionHandler: { (data, response, error) in
                
                // Update flag
                self.isMoreDataLoading = false
        
        var newdata: [String] = []
                // ... Use the new data to update the data source ...
        Business.searchWithTerm("Restaurants",  offset: 20, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                    self.businesses = businesses
                    //self.filteredBusinesses = businesses
                    self.tableView.reloadData()
                    for(var x=0; x<businesses.count; x++){
                        self.filteredBusinesses.append(businesses[x])
                        print(businesses[x].name!)
                        print(businesses[x].address!)
                    }
                    //self.filteredBusinesses = businesses
                    //self.data = newdata
                })
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
        //});
      //  task.resume()
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
