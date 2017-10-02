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

public class RedemptionResponse : Mappable {
    
    public var created: String = ""
    public var locationId: String = ""
    public var redemptionId: String = ""
    public var status: String = ""
    public var updated: String = ""

    
    public init(){
    }
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        created <- map["created"]
        updated <- map["updated"]
        status <- map["status"]
        redemptionId <- map["redemptionId"]
        locationId <- map["locationId"]
    }
}
