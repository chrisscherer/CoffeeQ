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

public class CompleteRedemptionRequest : Mappable {
    
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
        itemName <- map["itemName"]
        itemPrice <- map["itemPrice"]
        redeemerName <- map["redeemerName"]
        message <- map["message"]
    }
}
