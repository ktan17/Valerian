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
}

class HTTPDelegate: NSObject, FelixHTTPDelegate {
    
    func get(url: String, completion: @escaping (String?) -> Void) {
        Alamofire.request(url).responseString { (response) in
            completion(response.result.value)
        }
    }
    
}
