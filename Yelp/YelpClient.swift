//
//  YelpClient.swift
//  Yelp
//
//  Created by William Tong on 2/10/16.
//  Copyright (c) 2016 William Tong. All rights reserved.
//


import UIKit

import AFNetworking
import BDBOAuth1Manager
import CoreLocation

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
var api = ""

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, limit: Int, offset: Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation
    {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        var parameters: [String : AnyObject]
        
        // Default the location to San Francisco if user didn't allow location services, otherwise use user's location.
        let locationManager = CLLocationManager()
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        
        if CLLocationManager.locationServicesEnabled() && latitude != nil
        {
            parameters = ["term": term, "ll": "\(latitude!), \(longitude!)"]
        }
        else
        {
            parameters = ["term": term, "ll": "37.33,-122.03"]
        }
        
        if sort != nil
        {
            parameters["sort"] = sort!.rawValue
        }
        
        if categories != nil && categories!.count > 0
        {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }
        
        if deals != nil
        {
            parameters["deals_filter"] = deals!
        }
        
        parameters["offset"] = offset
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil
            {
                completion(Business.businesses(array: dictionaries!), nil)
            }
            },
            failure:
            { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
        })!
    }
}
