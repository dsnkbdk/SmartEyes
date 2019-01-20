//
//  SmartEyesMultiViewUITests.swift
//  SmartEyesMultiViewUITests
//
//  Created by david on 2/05/18.
//  Copyright © 2018 david. All rights reserved.
//

import XCTest

class SmartEyesMultiViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.


        let app = XCUIApplication()
        let loginButton = app.buttons["Login"]
        loginButton.tap()
        loginButton.tap()
        app.images["apple-1600x848"].swipeRight()

        let button = app.buttons["2 circle"]
        button.tap()

        let image = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .image).element
        image/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["3 squre"].tap()
        image/*@START_MENU_TOKEN@*/.press(forDuration: 1.0);/*[[".tap()",".press(forDuration: 1.0);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["4 line"].tap()
        image/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/

        let button2 = app.buttons["5 triangle"]
        button2.tap()
        button2.tap()
        image/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["6 dash"].tap()
        image.swipeUp()

        let button3 = app.buttons["2 red"]
        button3.tap()
        image.swipeLeft()
        button.tap()
        app.buttons["1 pen"].tap()
        app.buttons["1 blue"].tap()
        image.tap()
        button3.tap()
        image/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeDown()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["3 yellow"].tap()
        button.tap()
        image/*@START_MENU_TOKEN@*/.press(forDuration: 0.8);/*[[".tap()",".press(forDuration: 0.8);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.buttons["4 purple"].tap()
        image.swipeDown()
        app.buttons["5 green"].tap()
        image.swipeDown()
        app.buttons["6 eraser"].tap()
        image/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeDown()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        image.tap()
        image.swipeUp()

        let savephotoButton = app.buttons["savephoto"]
        savephotoButton.tap()

        let enjoyDrawingAlert = app.alerts["Enjoy Drawing"]
        enjoyDrawingAlert.buttons["Cancel"].tap()
        savephotoButton.tap()
        enjoyDrawingAlert.buttons["OK"].tap()
        app.staticTexts["Comments"].tap()
        app.buttons["Save"].tap()

        let cancelButton = app.buttons["Cancel"]
        cancelButton.tap()
        app.buttons["shareing"].tap()
        cancelButton.tap()
        app.buttons["Commenting"].tap()
        cancelButton.tap()

        let button4 = app.buttons["0 trash"]
        button4.tap()

        let allDrawingsSticksWillBeDeletedAlert = app.alerts["All drawings & sticks will be deleted"]
        allDrawingsSticksWillBeDeletedAlert.staticTexts["All drawings & sticks will be deleted"].tap()
        allDrawingsSticksWillBeDeletedAlert.buttons["Cancel"].tap()
        button4.tap()
        allDrawingsSticksWillBeDeletedAlert.buttons["Delete All"].tap()
        
    }
    
}
