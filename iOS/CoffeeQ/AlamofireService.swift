//
//  AlamoFireController.swift
//  CBLTest
//
//  Created by Christopher Scherer on 3/13/17.
//  Copyright © 2017 CBL. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper


/// This is a facade around the AlamoFire framework
// TODO: Implement the RequestRetrier for re-auth and errors https://github.com/Alamofire/Alamofire/blob/master/Documentation/Alamofire%204.0%20Migration%20Guide.md#request-retrier
class AlamoFireService {
    
    /// A function used to make HTTP request through the Alamofire framework.
    
    ///
    /// - Parameters:
    ///   - url: The URI as a string to send the request to
    ///   - parameters: A custom data type provided by Alamofire
    ///   - dumpType: A class reference that is used for type inference. Swift doesn't infer types well and a reference like this appears to be the best way to use generic
    ///   - handler: A handler to be executed on success
    func makeRequest<T : Mappable>(_ url:String, _ method: HTTPMethod, _ parameters:Parameters, _ headers: [String:String],
                     _ successHandler:@escaping (_ results: [T]) -> Void ) {
        
        
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().authenticate(user: Constants.locationId, password: Constants.rawKey).responseJSON {
            response in
            
            switch response.result {
            case .success:
                
                if let jsonArray = response.result.value as? [[String:Any]] {
                    var results = [T]()
                    
                    for json in jsonArray {
                        results.append(self.processJsonObject(json))
                    }
                    successHandler(results)
                }
                else if let json = response.result.value as? [String:Any] {
                    let resultItem: T = self.processJsonObject(json)
                    successHandler([resultItem])
                }
                
                break
            case .failure(let error):
                break
            }
        }
    }
    
    /// This function is used to parse JSON returned from an HTTP request into a useable object
    ///
    /// - Parameter json: The json to map
    /// - Returns: An object of type T
    private func processJsonObject<T : Mappable>(_ json: [String:Any]) -> T {
        let fixedJson = fixMapKeys(json)
        return Mapper<T>().map(JSON: fixedJson)!
    }
    
    
    /// This function is used to fix casing issues between our database and the cloud database
    /// The backend database uses CamelCasing, while CoreData enforces pascalCasing
    /// This function uses recursion to make sure we look at any sub objects
    ///
    /// - Parameter map: A dictionary to be converted
    /// - Returns: A parsed and updated Dictionary
    private func fixMapKeys(_ map: [String:Any]) -> [String:Any] {
        var newMap: [String:Any] = [:]
        
        for (key, value) in map {
            var newValue = value
            if let valueAsDictionary = value as? [String:Any] {
                newValue = fixMapKeys(valueAsDictionary)
            }
            
            let newKey = pascalCaseString(key)
            newMap[newKey] = newValue
        }
        return newMap
    }
    
    
    /// Takes a string and enforces pascalCasing on it
    ///
    /// - Parameter string: A string to parse
    /// - Returns: A parsed string that conforms to pascalCasing
    private func pascalCaseString(_ string: String) -> String {
        let index = string.index(string.startIndex, offsetBy: 1)
        
        var firstChar = string.substring(to: index)
        
        firstChar = firstChar.lowercased()
        
        return firstChar + string.substring(from: index)
    }
}
