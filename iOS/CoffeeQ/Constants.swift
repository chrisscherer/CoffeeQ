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
    public static let darkBlue = UIColor.init(red: 29.0 / 255.0, green: 51.0 / 255.0, blue: 101.0 / 255.0, alpha: 1)
    public static let cancelRed = UIColor.init(red: 221.0 / 255.0, green: 53.0 / 255.0, blue: 37 / 255.0, alpha: 1)
    
    public enum pageState {
        case home
        case buy
        case redeem
        case confirmation
    }
}
