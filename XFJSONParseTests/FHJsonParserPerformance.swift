//
//  FHJsonParserPerformance.swift
//  FHParseJSONTests
//
//  Created by 李腾芳 on 2019/11/12.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import XCTest
@testable import XFJSONParse

class FHJsonParserPerformance: XCTestCase {
    
    lazy var testString: String = { () -> String in
        let jsonFile = Bundle(for: FHJsonParserTests.self).path(forResource: "complex", ofType: "json")!
        let jsonString = try! String(contentsOfFile: jsonFile, encoding: String.Encoding.utf8)
        return jsonString
    }()
    
    lazy var testData: Data = { () -> Data in
        return testString.data(using: String.Encoding.utf8)!
    }()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<1 {
                
                try! FHJSONParse(testString).parse()
  
            }
            
        }
    }
    
    
    func testJSONSerializationPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<1 {
               try! JSONSerialization.jsonObject(with: testData, options: JSONSerialization.ReadingOptions.allowFragments)
              
            }
            
        }
    }


}
