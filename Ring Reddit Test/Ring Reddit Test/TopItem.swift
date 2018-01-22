//
//  TopItem.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/21/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

class TopItem: NSObject {

    var id: String!
    var title: String!
    var author: String!
    var created: Date!
    var thumbnailURL: String?
    var numberOfComments: Int!
    var link: String?
    
    func setupTopItem(json: JsonDict) {
        print(json)
        
        id = json["id"] as? String
        
        title = json["title"] as? String
        
        author = json["author"] as? String

        if let epochTime = json["created_utc"] as? TimeInterval {
            let date = Date(timeIntervalSince1970: epochTime)
            created = date
        } else {
            created = Date()
        }

        thumbnailURL = json["thumbnail"] as? String

        numberOfComments = json["num_comments"] as! Int

        link = json["url"] as? String

    }
}
