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

public class RedemptionFinalizedResponse : Mappable {
    
    public var created: String = ""
    public var locationId: String = ""
    public var redemptionId: String = ""
    public var status: String = ""
    public var updated: String = ""
    public var itemName: String = ""
    public var itemPrice: Float = 0.0
    public var redeemerName: String = ""
    public var message: String = ""
    
    
    public init(){
    }
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        created <- map["created"]
        locationId <- map["locationId"]
        redemptionId <- map["redemptionId"]
        status <- map["status"]
        updated <- map["updated"]
        itemName <- map["itemName"]
        itemPrice <- map["itemPrice"]
        redeemerName <- map["redeemerName"]
        message <- map["message"]
    }
}
