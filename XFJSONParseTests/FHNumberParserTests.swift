//
//  FHParseJSONTests.swift
//  FHParseJSONTests
//
//  Created by 李腾芳 on 2019/11/8.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

@testable import XFJSONParse
import XCTest

class FHNumberParserTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testNormal() {
        let integer = try! NumberStringParser(str: "12345").getNumber()
        XCTAssert(integer == 12345)

        let integerWithFraction = try! NumberStringParser(str: "12345.5").getNumber()
        XCTAssert(integerWithFraction == 12345.5)

        let integerWithExponent = try! NumberStringParser(str: "12345e2").getNumber()
        XCTAssert(integerWithExponent == 12345e2)

        let integerWithFractionAndExponent = try! NumberStringParser(str: "12345.5e3").getNumber()
        XCTAssert(integerWithFractionAndExponent == 12345.5e3)
    }

    func testEmptyInput() {
        XCTAssertThrowsError(try NumberStringParser(str: "").getNumber(), "testEmptyInput failed") { error in

            let parseError = error as! NumberStringParserError

            XCTAssert(parseError == NumberStringParserError.inputEmpty)
        }
    }

    func testDismissInteger() {
        XCTAssertThrowsError(try NumberStringParser(str: ".5e3").getNumber(), "testDismissInteger failed") { _ in
        }

        XCTAssertThrowsError(try NumberStringParser(str: ".5").getNumber(), "testDismissInteger failed") { _ in
        }

        XCTAssertThrowsError(try NumberStringParser(str: ".5e3").getNumber(), "testDismissInteger failed") { _ in
        }

        XCTAssertThrowsError(try NumberStringParser(str: "-.5e3").getNumber(), "testDismissInteger failed") { _ in
        }

        XCTAssertThrowsError(try NumberStringParser(str: "+.5e3").getNumber(), "testDismissInteger failed") { _ in
        }
    }

    func testUnvalidString() {
        for i in 0 ..< 9 {
            var input = "12345.5e3"
            let index = input.index(input.startIndex, offsetBy: i)
            input.insert("v", at: index)

            XCTAssertThrowsError(try NumberStringParser(str: input).getNumber(), "testDismissInteger failed") { _ in
            }
        }
    }
}
