//
//  API.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/18/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import Foundation

class API: NSObject {
    
    var lastItem = ""
    let limit = 50
    let itemsPerPage = 2
    
    func createRequest(baseURL: String) -> URLRequest? {
        
        var endpoint: String
        if lastItem.isEmpty {
            endpoint = baseURL + "?after=\(lastItem)&limit=\(itemsPerPage)"
        } else {
            endpoint = baseURL + "?limit=\(itemsPerPage)"
        }
        guard let completeURL = URL(string: endpoint) else {
            print("unable to create URL with: \(endpoint)")
            return nil
        }
        
        var request = URLRequest(url: completeURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"

        return request
    }
    
    func retrieveData(url: String, callback: @escaping ((AnyObject?, Error?) -> ())) {
        
        guard let request = createRequest(baseURL: url) else {
            callback(nil, nil)
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
                callback(nil, error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                
                guard let responseData = data else {
                    print("no response data")
                    callback(nil, error)
                    return
                }
                do {
                    guard let jsonReponse = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as Any? else {
                        callback(nil,error)
                        return
                    }
                    callback(jsonReponse as AnyObject, nil)
                    print(jsonReponse)
                } catch {
                    print("couldn't serialize json")
                    callback(nil, error)
                }
            }
        })
        
        dataTask.resume()
    }
}
