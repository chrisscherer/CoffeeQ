//
//  FoodItem+CoreDataClass.swift
//  CBLTest
//
//  Created by Christopher Scherer on 2/27/17.
//  Copyright © 2017 CBL. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper

public class CompletePurchaseRequest : Mappable {
    
    public var itemName: String = ""
    public var customerEmail: String = ""
    public var itemPrice: Float = 0
    public var message: String = ""
    public var customerName: String = ""
    
    public init(){
    }
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        itemName <- map["itemName"]
        customerEmail <- map["customerEmail"]
        itemPrice <- map["itemPrice"]
        message <- map["message"]
        customerName <- map["customerName"]
    }
}
