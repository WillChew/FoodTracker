//
//  RequestManager.swift
//  FoodTracker
//
//  Created by Will Chew on 2018-07-16.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import UIKit

enum Constants {
    static let content = "application/json"
    static let token = "mzLeVQvHeMyoJy71stmYK99A"
    static let clientID = "887c27b7d390539"
}

class RequestManager {
    var meal: Meal!
    
    
    func sendRequest(_ meal: Meal){
        
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
        var request = URLRequest(url: components.url!)
        
        request.setValue(Constants.content, forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.token, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if (error == nil) {
                // success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session task succeeded: HTTP \(statusCode)")
                
                
            } else if let e = error {
                //failure
                print("URL session task failed: \(e.localizedDescription)")
            }
            // guard on the data
            guard let data = data else { return }
            // do a do-catch on the try
            guard let jsonResult = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String, Dictionary<String, Any?>> else { return }
            //            let jsonP = jsonResult?["id"] as! [String: Any]
            //            meal.id = jsonP["id"] as? Int
            guard let mealData = jsonResult["meal"], let id = mealData["id"] as? Int else {return}
            
            meal.id = id
//            self.sendRequestToUpdateRating(meal, mealRating: meal.rating!)
            
        })
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func sendRequestToUpdateRating(_ meal: Meal!, mealRating: Int) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://cloud-tracker.herokuapp.com")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        guard let mealID = meal.id else {
            return
        }
        components.path = "/users/me/meals/\(mealID)/rate"
        
        let ratingStr = String(mealRating)
       
        
        let ratingQueryItem = URLQueryItem(name: "rating", value: ratingStr)
        components.queryItems = [ratingQueryItem] as [URLQueryItem]
        
        var request = URLRequest(url: components.url!)
        
        request.setValue(Constants.content, forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.token, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session task succeeded: \(statusCode)")
            } else {
                //error
                print("URL session task failed: \(error!.localizedDescription)")
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func getAllMeals(completion: @escaping ([Meal]) -> Void) {
         var mealArrayOriginal = [Meal]()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        var request = URLRequest(url: url)
        
        request.setValue("", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.token, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session task succeeded: \(statusCode)")
            } else if let error = error{
                //error
                print("error: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            guard let jsonResult = try! JSONSerialization.jsonObject(with: data) as? Array<Dictionary<String, Any?>> else { return }
            
            
           
//            var mealArray = [Meal]()

            for meals in jsonResult {
                
                guard let title = meals["title"], let photo = meals["imagePath"], let desc = meals["description"] else {
                    return
                }
                
                guard let rating = meals["rating"] else {
                   let rating = 0
                    return
                }
                
                
                
                let newMeal = Meal(name: title as! String, photo: photo as? UIImage, rating: rating as? Int, desc: desc as! String, calories: meals["calories"] as! Int)
//                self.sendRequestToUpdateRating(newMeal)
                
            mealArrayOriginal.append(newMeal!)
                            }
            completion(mealArrayOriginal)

        })
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    
}
