//
//  API.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/18/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import Foundation

class API: NSObject {
    
    var lastItem:String? = ""
    let itemsPerPage = 20
    
    func createRequest(baseURL: String) -> URLRequest? {
        
        var endpoint: String
        if lastItem != nil && !lastItem!.isEmpty {
            endpoint = baseURL + "?after=\(lastItem!)&limit=\(itemsPerPage)"
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
        
        print("*** Request:\(String(describing: request.url?.absoluteString))")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
                callback(nil, error)
            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse!)
                
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
    //    func retrieveData(url: String, callback: @escaping ((AnyObject?, Error?) -> ())) {

    func retrieveItems(lastSeenItem: String?, callback: @escaping (([TopItem]?) -> ())) {
        if self.lastItem == nil && lastSeenItem != nil {
            self.lastItem = "t3_" + lastSeenItem!
        }
        retrieveData(url: "https://api.reddit.com/top") { (jsonResponse, error) in
            if error == nil {
                //parse json
                print(jsonResponse!)
                guard let dict = jsonResponse as? JsonDict else {
                    print("couldn't create dictionary")
                    callback(nil)
                    return
                }
                let type = dict["kind"] as? String
                
                if type == "Listing" {
                    guard let data = dict["data"] as? JsonDict else {
                        print("no data in resonse")
                        callback(nil)
                        return
                    }
                    if let after = data["after"] as? String {
                        self.lastItem = after
                    }
                    
                    
                    guard let items = data["children"] as? [JsonDict] else {
                        print("no items in response")
                        callback(nil)
                        return
                    }
                    
                    print("got \(items.count) items")
                    var topItems: [TopItem] = []
                    for item in items {
                        guard item["kind"] as? String == "t3" else {
                            print("wrong type of item")
                            continue
                        }
                        guard let itemDict = item["data"] as? JsonDict else {
                            print("item had no data")
                            continue
                        }
                        let newItem = TopItem()
                        newItem.setupTopItem(json: itemDict)
                        
                        topItems.append(newItem)
                    }
                    callback(topItems)
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
                } else {
                    print("invalid response type")
                    callback(nil)
                    return
                }
            } else {
                print(error!.localizedDescription)
                callback(nil)
            }
        }
    }
}
