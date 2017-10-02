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

public class CompletePurchaseResponse : Mappable {
    
    public var itemName: String = ""
    public var locationId: String = ""
    public var created: String = ""
    public var purchaseId: String = ""
    public var customerEmail: String = ""
    public var redemptionId: Float = 0
    public var itemPrice: Float = 0
    public var message: String = ""
    public var updated: String = ""
    public var customerName: String = ""
    public var status: String = ""
    
    public init(){
    }
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        itemName <- map["itemName"]
        locationId <- map["locationId"]
        created <- map["created"]
        purchaseId <- map["purchaseId"]
        customerEmail <- map["customerEmail"]
        redemptionId <- map["redemptionId"]
        itemPrice <- map["itemPrice"]
        message <- map["message"]
        updated <- map["updated"]
        customerName <- map["customerName"]
        status <- map["status"]
    }
}
