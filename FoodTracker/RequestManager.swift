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
    static let clientID = "Client-ID 887c27b7d390539"
}

class RequestManager {
    var meal: Meal!
    
    
    
    func signUpRequest(_ user: User, completion: @escaping () -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://cloud-tracker.herokuapp.com")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/signup"
        let usernameQueryItem = NSURLQueryItem(name: "username", value: user.username)
        let passwordQueryItem = NSURLQueryItem(name: "password", value: user.password)
        components.queryItems = [usernameQueryItem, passwordQueryItem] as [URLQueryItem]
        var request = URLRequest(url: components.url!)
        
        request.setValue(Constants.content, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil){
                //success
                let theStatusCode = (response as! HTTPURLResponse).statusCode
                if theStatusCode == 409 {
                    UserDefaults.standard.set(true, forKey: "existing")
                } else {
                    print("signup succeeded: \(theStatusCode)")
                    UserDefaults.standard.set(true, forKey: "wasLaunched")
                }
            } else if let error = error {
                //failed
                print("URL Session task failed: \(error.localizedDescription)")
            }
            
            guard let data = data else { return }
            guard let jsonresult = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any?>  else { return }
            let token = jsonresult["token"] as? String
            UserDefaults.standard.set(token, forKey: "token")
            
            completion()
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func loginRequest(_ user: User, completion: @escaping() -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://cloud-tracker.herokuapp.com")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/login"
        let usernameQueryItem = URLQueryItem(name: "username", value: user.username)
        let passwordQueryItem = URLQueryItem(name: "password", value: user.password)
        components.queryItems = [usernameQueryItem, passwordQueryItem]
        var request = URLRequest(url: components.url!)
        request.setValue(Constants.content, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Log in succeeded: \(statusCode)")
                
                if statusCode == 403 {
                    UserDefaults.standard.set(true, forKey: "wrongInfo")
                    
                }
                
                
                
            } else if let error = error {
                //failed
                print("data task failed with error: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            guard let jsonResult = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any?>  else { return }
            let token = jsonResult["token"] as? String
            UserDefaults.standard.set(token, forKey: "token")
            
            completion()
            
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    
    func newMealRequest(_ meal: Meal, completion: @escaping() -> Void){
        
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
        request.setValue(UserDefaults.standard.object(forKey: "token") as? String, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if (error == nil) {
                // success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("adding new meal succeeded: \(statusCode)")
                
                
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
            self.sendRequestToUpdateRating(meal, mealRating: meal.rating!) { (rating) in
                meal.rating = rating
                
                self.postPhotoRequest(meal, mealPhoto: meal.photo!) {(imageURLStr) in
                    self.updatePhotoRequest(meal, imageLinkStr: imageURLStr) {
                        guard let imageURL = URL(string: imageURLStr), let imageData = try? Data(contentsOf: imageURL) else { return }
                        
                        let mealImageFromUrl = UIImage(data: imageData)
                        meal.photo = mealImageFromUrl
                        completion()
                        
                    }
                    
                }
            }
            
            
        })
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func sendRequestToUpdateRating(_ meal: Meal!, mealRating: Int, completion: @escaping(Int) -> ())  {
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
        request.setValue(UserDefaults.standard.object(forKey: "token") as? String, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("updating rating succeeded: \(statusCode)")
            } else {
                //error
                print("URL session task failed: \(error!.localizedDescription)")
            }
            completion(mealRating)
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
        request.setValue(UserDefaults.standard.object(forKey: "token") as? String, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("getting meals succeeded: \(statusCode)")
            } else if let error = error{
                //error
                print("error: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            guard let jsonResult = try! JSONSerialization.jsonObject(with: data) as? Array<Dictionary<String, Any?>> else { return }
            
            for meals in jsonResult {
                
                guard let title = meals["title"], let photo = meals["imagePath"] , let desc = meals["description"], let rating = meals["rating"] else {
                    return
                }
                
                var mealPhoto: UIImage? 
                if let photoString = photo as? String, let imageUrl = URL(string: photoString), let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                    mealPhoto = image
                }
                
                let newMeal = Meal(name: title as! String, photo: mealPhoto, rating: rating as? Int, desc: desc as! String, calories: meals["calories"] as! Int)
                
                mealArrayOriginal.append(newMeal!)
            }
            completion(mealArrayOriginal)
            
        })
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func updatePhotoRequest(_ meal: Meal!, imageLinkStr: String, completion: @escaping() -> ()) {
        
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://cloud-tracker.herokuapp.com")!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        guard let mealID = meal.id else { return }
        components.path = "/users/me/meals/\(mealID)/photo"
        let linkQueryItem = URLQueryItem(name: "photo", value: imageLinkStr)
        components.queryItems = [linkQueryItem]
        
        
        var request = URLRequest(url: components.url!)
        request.setValue(UserDefaults.standard.object(forKey: "token") as? String, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                //success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("updating image success \(statusCode)")
                
            } else if let error = error{
                //fail
                print("posting image failed with error: \(error.localizedDescription)")
            }
            
            completion()
        }
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func postPhotoRequest(_ meal: Meal, mealPhoto: UIImage, completion: @escaping(String) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: "https://api.imgur.com/3/image")!
        
        
        guard  let imageData = UIImagePNGRepresentation(mealPhoto) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(Constants.clientID, forHTTPHeaderField: "Authorization")
        request.setValue("image/png", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = imageData
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Photo posting successful : \(statusCode)")
            } else {
                print("Error with code: \(error?.localizedDescription)")
            }
            guard let data = data else { return }
            guard let jsonResult = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any?>, let jsonData = jsonResult["data"] as? Dictionary<String, Any?> else { return }
            guard let link = jsonData["link"] as? String else { return }
            
            
            
            //            guard let mealImage = UIImage(data: imageData) else { return }
            completion(link)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    
    
}
