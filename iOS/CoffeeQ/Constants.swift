//
//  Constants.swift
//  CoffeeQ
//
//  Created by Christopher Scherer on 4/22/17.
//  Copyright © 2017 CoffeeQ. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    public static let DEV_URL = "https://api.coffeeq.org/stage/"
    
    public static let darkBlue = UIColor.init(red: 29.0 / 255.0, green: 51.0 / 255.0, blue: 101.0 / 255.0, alpha: 1)
    public static let confirmGreen = UIColor.init(red: 83.0 / 255.0, green: 255.0 / 255.0, blue: 26.0 / 255.0, alpha: 1)
    public static let cancelRed = UIColor.init(red: 100.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
    public static let coffeeQGreen = UIColor.init(red: 0.0/255.0, green: 249.0/255.0, blue: 0.0/255.0, alpha: 1)
    
    public enum pageState {
        case home
        case buy
        case redeem
        case confirmation
    }
    
    public enum sizeSelectionState {
        case small
        case medium
        case large
    }
    
    public static let rawKey = "7w+8];w<"
    public static let key = "$2a$10$.9cAZqgRbHJR3tFoQ7UszuXaphjPFooiNd2KVG4QxMIhNJGo23nhe"
    public static let locationId = "0004"
    
    
    
    public static let defaultHeaders = ["Content-Type" : "application/json", "Accept" : "application/json", "Accept-Language" : "en-US;q=1.0"]
    
    public static func getHeaders() -> [String:String] {
        var headers = Constants.defaultHeaders
        
        let username = Constants.locationId
        let password = Constants.rawKey
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        headers["Authorization"] = "Basic \(base64LoginString)"
        
        return headers
    }
}
