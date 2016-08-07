//
//  Post.swift
//  Alamofire-Decodable
//
//  Created by Sam Dean on 07/08/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import Decodable


struct Post {
    let userId: Int
    let id: Int
    let title: String
    let body: String?
}


extension Post: Decodable {

    static func decode(json: AnyObject) throws -> Post {
        return try Post(userId: json => "userId", id: json => "id", title: json => "title", body: json =>? "body")
    }
}
