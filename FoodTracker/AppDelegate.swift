//
//  AppDelegate.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 10/17/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let wasLaunchedKey = "wasLaunched"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaults.standard.set(false, forKey: "wasLaunched")
        UserDefaults.standard.set(false, forKey: "existing")
        
        UserDefaults.standard.set(false, forKey: "wrongInfo")
        
        
        window = UIWindow()
        let wasLaunched = UserDefaults.standard.bool(forKey: wasLaunchedKey)
        
        if wasLaunched {
            loadMainApp()
        } else {
            loadSignup()
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    
    
    private func loadSignup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let rootVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as UIViewController
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        self.window?.rootViewController = navigationController
        
    }
    private func loadMainApp() {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "MealTableViewController") as UIViewController
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        self.window?.rootViewController = navigationController
        
    }
    
    
    
}

