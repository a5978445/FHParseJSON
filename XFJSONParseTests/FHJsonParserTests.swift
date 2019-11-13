//
//  FHJsonParserTests.swift
//  FHParseJSONTests
//
//  Created by 李腾芳 on 2019/11/11.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

@testable import XFJSONParse
import XCTest

class FHJsonParserTests: XCTestCase {
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

    func testBasicTypeNormal() {
        func testNumber() {
            XCTAssert(try! FHJSONParse("1234.5").matchingValue() as! Double == 1234.5)
        }

        func testBool() {
            XCTAssert(try! FHJSONParse("true").matchingValue() as! Bool == true)
            XCTAssert(try! FHJSONParse("false").matchingValue() as! Bool == false)
        }

        func testNull() {
            XCTAssert(try! FHJSONParse("null").matchingValue() == nil)
        }

        func testString() {
            XCTAssert(try! FHJSONParse("\"13234\"").matchingValue() as! String == "13234")
        }

        testNumber()
        testBool()
        testNull()
        testString()
    }

    func testEmptyJSON() {
        XCTAssert((try! FHJSONParse("[]").parse() as! Array<Any>).isEmpty)
        XCTAssert((try! FHJSONParse("{}").parse() as! Dictionary<String, Any>).isEmpty)
    }

    func testFlatJSON() {
        func testArray() {
            let jsonFile = Bundle(for: FHJsonParserTests.self).path(forResource: "basicArray", ofType: "json")!
            let jsonString = try! String(contentsOfFile: jsonFile, encoding: String.Encoding.utf8)

            XCTAssertNoThrow(try FHJSONParse(jsonString).parse(), "array parse failure")
        }

        func testDictionary() {
            let jsonFile = Bundle(for: FHJsonParserTests.self).path(forResource: "basicDictionary", ofType: "json")!
            let jsonString = try! String(contentsOfFile: jsonFile, encoding: String.Encoding.utf8)

            XCTAssertNoThrow(try FHJSONParse(jsonString).parse(), "basicDictionary parse failure")
        }

        testArray()
        testDictionary()
    }

    func testNestJSON() {
        let jsonFile = Bundle(for: FHJsonParserTests.self).path(forResource: "nestArrayAndDictionary", ofType: "json")!
        let jsonString = try! String(contentsOfFile: jsonFile, encoding: String.Encoding.utf8)

        XCTAssertNoThrow(try FHJSONParse(jsonString).parse(), "nestArrayAndDictionary parse failure")
    }

    func testValidateString() {
    }

    func testMissStartFlag() {
        // 缺失左括号
        let missLeftBrace = "\"name\":\"fitch\"}"
        XCTAssertThrowsError(try FHJSONParse(missLeftBrace).parse())

        // 缺失左中括号
        let missLeftBracket = "\"fitch\"]"
        XCTAssertThrowsError(try FHJSONParse(missLeftBracket).parse())
        // 缺失左引号
        let missLeftQuotationMark = "[fitch\"]"
        XCTAssertThrowsError(try FHJSONParse(missLeftQuotationMark).parse())
    }

    func testUnvalidateBasicType() {
        let unvalidateType = "False"
        XCTAssertThrowsError(try FHJSONParse(unvalidateType).parse())
    }

    func testDisMissEndFlag() {
        // 缺失右括号
        let missRightBrace = "{\"name\":\"fitch\""
        XCTAssertThrowsError(try FHJSONParse(missRightBrace).parse())

        // 缺失右中括号
        let missRightBracket = "[\"fitch\""
        XCTAssertThrowsError(try FHJSONParse(missRightBracket).parse())
        // 缺失右引号
        let missRightQuotationMark = "[\"fitch]"
        XCTAssertThrowsError(try FHJSONParse(missRightQuotationMark).parse())
    }

    func testRedundantCharacters() {
        let arrayRedundant = "{\"name\":\"fitch\"}..."
        XCTAssertThrowsError(try FHJSONParse(arrayRedundant).parse())

        let dictionaryRedundant = "[12345],"
        XCTAssertThrowsError(try FHJSONParse(dictionaryRedundant).parse())
    }

    func testMatchUnValidateString() {
        XCTAssertThrowsError(try FHJSONParse("abcd\\\"").matchingString())
        XCTAssertThrowsError(try FHJSONParse("abcd\\c\"").matchingString())

        XCTAssertThrowsError(try FHJSONParse("abcd\\u123\"").matchingString())
        XCTAssertThrowsError(try FHJSONParse("abcd\\u123fd\"").matchingString())
        
        
        
    }

    func testMatchValidateString() {
        
        // 测试符号 ? = 
        XCTAssertNoThrow(try FHJSONParse("https://play.google.com/store/apps/details?id=com.hsbc.gcmbcountryguides\"").matchingString())
        
        XCTAssert(try FHJSONParse("\\\\\"").matchingString() == "\\\\")

        XCTAssertNoThrow(try FHJSONParse("aaaaa\\\\\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("*****\\\\\"").matchingString())

        XCTAssertNoThrow(try FHJSONParse("\\\\\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\\"\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\/\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\b\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\f\"").matchingString())

        XCTAssertNoThrow(try FHJSONParse("\\n\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\r\"").matchingString())
        XCTAssertNoThrow(try FHJSONParse("\\t\"").matchingString())

        let result = try! FHJSONParse("aaaa\\n\\r\\t\\b\\f\\/\\\"\\\\*****\"").matchingString()
        XCTAssert(result == "aaaa\\n\\r\\t\\b\\f\\/\\\"\\\\*****")
        XCTAssertNoThrow(try FHJSONParse("aaaa\\n\\r\\t\\b\\f\\/\\\"\\\\*****\"").matchingString())

        XCTAssertNoThrow(try FHJSONParse("abcd\\u12fD\"").matchingString())
    }
}
