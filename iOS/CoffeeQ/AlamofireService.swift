//
//  AlamofireService.swift
//  CoffeeQ
//
//  Created by Christopher Scherer on 5/3/17.
//  Copyright © 2017 CoffeeQ. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class AlamofireService {
    func makeRequest<T : BaseMappable>(_ url:String, _ parameters:Parameters, _ dumpType: T.Type, _ handler:@escaping (_ results: [T]) -> Void){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, parameters: parameters).responseJSON {
                response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch response.result {
                case .success:
                    if let jsonArray = response.result.value as? [[String:Any]] {
                        var results = [T]()
                        
                        for json in jsonArray {
                            results.append(self.processJsonObject(json))
                        }
                        
                        handler(results)
                    }
                    else if let json = response.result.value as? [String:Any] {
                        let resultItem: T = self.processJsonObject(json)
                        handler([resultItem])
                    }
                    break
                case .failure:
                    break
                }
            }
        }
        
    private func processJsonObject<T : BaseMappable>(_ json: [String:Any]) -> T{
            let fixedJson = fixMapKeys(json)
            return Mapper<T>().map(JSON: fixedJson)!
        }
        
        private func fixMapKeys(_ map: [String:Any]) -> [String:Any]{
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
        
        private func pascalCaseString(_ string: String) -> String {
            let index = string.index(string.startIndex, offsetBy: 1)
            
            var firstChar = string.substring(to: index)
            
            firstChar = firstChar.lowercased()
            
            return firstChar + string.substring(from: index)
        }
}
