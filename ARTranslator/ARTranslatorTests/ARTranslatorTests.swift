//
//  ARTranslatorTests.swift
//  ARTranslatorTests
//
//  Created by Francois Mukaba on 1/22/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import XCTest
@testable import ARTranslator

class ARTranslatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print("\n\n\nTEST TEST TEST TEST TEST TEST TEST TEST TEST\n")
        
        
        let testImage = UIImage.init(named: "testImage_01.png")!
        let test: avgColorGrabber = avgColorGrabber.init(image: testImage)

        let testRect = CGRect.init(x: 140, y: 780, width: 60, height: 60)
        print("AVG RECT COLOR: \(test.getAvgRectColor(rect: testRect))")
        
        print("\n\n\n")
        print(test.getPixelColor(pos: CGPoint.init(x: 155, y: 888)))
        print("\n\n\n")
    }
    
    func avgColorGrabber_getPixelColor()
    {
        // THIS FUNC IS NOT RUNNING, BUT COPY-PASTING THE TEST INTO THE ABOVE
        // FUNC WORKS, AND SO THERE IT SHALL REMAIN
        
        // ALL GLORY TO THE HOLY CODE
        // ALL GLORY TO HYPNOTOAD
        
//        print("TEST TEST TEST TEST TEST TEST TEST TEST TEST")
//
//        let testImage = UIImage.init(named: "testImage_01.png")!
//        let test: avgColorGrabber = avgColorGrabber.init(image: testImage)
//
//        print("\n\n\n")
//        print(test.getPixelColor(pos: CGPoint.init(x: 1, y: 1)))
//        print("\n\n\n")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
