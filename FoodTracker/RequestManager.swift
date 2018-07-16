//
//  RequestManager.swift
//  FoodTracker
//
//  Created by Will Chew on 2018-07-16.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import UIKit



class RequestManager {
    var meal: Meal!
    
    
    func sendRequest(_ meal: Meal) {
        
//        let parameters: [String : Any] = ["title" : meal.name, "description": meal.desc, "calories": meal.calories]
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let url = URL(string: "https://cloud-tracker.herokuapp.com")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!


        components.path = "/users/me/meals"
        
        let titleQueryItem = NSURLQueryItem(name: "title", value: meal.name)
        let descriptionQueryItem = NSURLQueryItem(name: "description", value: meal.desc)
        let caloriesQueryItem = NSURLQueryItem(name: "calories", value: String(meal.calories))
        components.queryItems = [titleQueryItem, descriptionQueryItem, caloriesQueryItem] as [URLQueryItem]
        print(#line, components.url ?? "No url")
        let request = NSMutableURLRequest(url: components.url! )

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("mzLeVQvHeMyoJy71stmYK99A", forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
/*  let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
 if (error == nil) {
 //success
 let statusCode = (response as! HTTPURLResponse).statusCode
 print("URL Session task succeeded: HTTP \(statusCode)")
 } else {
 //failure
 print("URL session task failed \(error.localizedDescription)")
 }
 }
 */
        vvvv
        
        
        
    }
}
