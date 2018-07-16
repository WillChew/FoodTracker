//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by Jane Appleseed on 10/17/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    
    //MARK: Meal Class Tests
    
    // Confirm that the Meal initializer returns a Meal object when passed valid parameters.
    func testMealInitializationSucceeds() {
        
        // Zero rating
        
        let zeroRatingMeal = Meal.init(name: "Zero", photo: nil, rating: 0, desc: "Awful", calories: 300)
        XCTAssertNotNil(zeroRatingMeal)

        // Positive rating
        let positiveRatingMeal = Meal.init(name: "Positive", photo: nil, rating: 5, desc: "Amazing", calories: 100)
        XCTAssertNotNil(positiveRatingMeal)

    }
    
    // Confirm that the Meal initialier returns nil when passed a negative rating or an empty name.
    func testMealInitializationFails() {
        
        // Negative rating
        let negativeRatingMeal = Meal.init(name: "Negative", photo: nil, rating: -1, desc: "Bad", calories: 250)
        XCTAssertNil(negativeRatingMeal)
        
        // Rating exceeds maximum
        let largeRatingMeal = Meal.init(name: "Large", photo: nil, rating: 6, desc: "Super good", calories: 500)
        XCTAssertNil(largeRatingMeal)

        // Empty String
        let emptyStringMeal = Meal.init(name: "", photo: nil, rating: 0, desc: "Mystery", calories: 1000)
        XCTAssertNil(emptyStringMeal)
        
    }
}
