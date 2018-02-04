//
//  FelixHTTPDelegate.swift
//  Felix
//
//  Created by Kevin Tan on 2/3/18.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import Foundation
import Alamofire

protocol FelixHTTPDelegate: class {
    func get(url: String, completion: @escaping (String?) -> Void)
    func post(url: String, message: String, state: State, completion: @escaping ([String: Any]) -> Void)
}

class HTTPDelegate: NSObject, FelixHTTPDelegate {
    
    func get(url: String, completion: @escaping (String?) -> Void) {
        Alamofire.request(url).responseString { (response) in
            completion(response.result.value)
        }
    }
    
    func post(url: String, message: String, state: State, completion: @escaping ([String : Any]) -> Void) {
        print("make add post")
        Alamofire.request(url, method: .post, parameters: ["message" : message, "state" : state.rawValue], encoding: JSONEncoding(), headers: nil).responseJSON { (response) in
            guard response.result.isSuccess else {
                return
            }

            guard let data = response.result.value as? [String: Any] else {
                return
            }
            
            completion(data)
        }
        
    }
}
