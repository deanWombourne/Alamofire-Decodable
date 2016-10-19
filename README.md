# Alamofire-Decodable

[![CI Status](http://img.shields.io/travis/deanWombourne/Alamofire-Decodable.svg?style=flat)](https://travis-ci.org/deanWombourne/Alamofire-Decodable)
[![Version](https://img.shields.io/cocoapods/v/Alamofire-Decodable.svg?style=flat)](http://cocoapods.org/pods/Alamofire-Decodable)
[![License](https://img.shields.io/cocoapods/l/Alamofire-Decodable.svg?style=flat)](http://cocoapods.org/pods/Alamofire-Decodable)
[![Platform](https://img.shields.io/cocoapods/p/Alamofire-Decodable.svg?style=flat)](http://cocoapods.org/pods/Alamofire-Decodable)

## Brief

A simple pod to connect `Decodable` to `Alamofire`.

Assuming you have a decodable struct called `Post` (check out Post.swift in the example project), then you can just use `responseDecodable` to return you one (or a list) of them, like this:

```swift
Alamofire.request("https://jsonplaceholder.typicode.com/posts/1").responseDecodable { (response: DataResponse<Post>) in
    switch response.result {
    case .success(let post):
        print("Recieved post: \(post)")

    case .failure(let error):
        print("Failed with error: \(error)")
    }
}
```

## Requirements
Alamofire-Decodable requires iOS 9.0, Swift 3 and Xcode 8.

## Example Project

To run the example project, clone the repo and run the project in the Example folder.

## Installation

Alamofire-Decodable is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Alamofire-Decodable"
```

## Author

Sam Dean, deanWombourne@gmail.com

## License

Alamofire-Decodable is available under the MIT license. See the LICENSE file for more info.
