//
//  ViewController.swift
//  Alamofire-Decodable
//
//  Created by Sam Dean on 08/07/2016.
//  Copyright (c) 2016 Sam Dean. All rights reserved.
//

import UIKit

import Alamofire
import Alamofire_Decodable

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Example of Alamofire returning a decoded model object (in this case a Post)
        Alamofire.request(.GET, "https://jsonplaceholder.typicode.com/posts/1").responseDecodable { (response: Response<Post, DecodableResponseError>) in

            switch response.result {

            case .Success(let post):
                print("Recieved post: \(post)")

            case .Failure(let error):
                print("Failed with error: \(error)")
            }
        }

        // Example of Alamofire returning a decoded array of Posts
        Alamofire.request(.GET, "https://jsonplaceholder.typicode.com/posts").responseDecodable { (response: Response<[Post], DecodableResponseError>) in

            switch response.result {

            case .Success(let posts):
                print("Recieved posts: \(posts)")

            case .Failure(let error):
                print("Failed with error: \(error)")
            }
        }
    }
}
