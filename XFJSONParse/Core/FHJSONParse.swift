//
//  FHJSONParse.swift
//  FHParseJSON
//
//  Created by 李腾芳 on 2019/11/8.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import Foundation

enum FHJSONParseError: Error {
  //  case unvalidFormat
    case redundantChars(String)
    case unvalidValue(String)
    case dismissStartSymbol(String)
    case dismissComma(String)
    case dismissColon(String)
    case dismissQuotes(String)
    case unvalidString(String)
}

func createBasicCharacterSet() -> CharacterSet {
    let basicCharacterSet = NSMutableCharacterSet.alphanumeric()
    basicCharacterSet.formUnion(with: CharacterSet.punctuationCharacters)
    basicCharacterSet.formUnion(with: CharacterSet.whitespacesAndNewlines)
    basicCharacterSet.formUnion(with: CharacterSet.symbols)
    basicCharacterSet.removeCharacters(in: "\"\\")
    return basicCharacterSet as CharacterSet
}

let basicCharacterSet: CharacterSet = createBasicCharacterSet()
let validateChars = ["\"", "\\", "b", "f", "n", "r", "t", "/"]
let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")

class FHJSONParse {
    let scanerString: String
    var scaner: Scanner
    
    var matchOnceString: NSString? = nil
    var matchFinalString = ""
 

    init(_ str: String) {
        scanerString = str
        scaner = Scanner(string: str)
        // 忽略掉空行空格等
        scaner.charactersToBeSkipped = CharacterSet(charactersIn: " \n\t\r")
    }

    func parse() throws -> Any {
        var result: Any
        if scaner.scanString("[", into: nil) {
            result = try matchingArray()
        } else if scaner.scanString("{", into: nil) {
            result = try matchingObject()
        } else {
            throw FHJSONParseError.dismissStartSymbol((scanerString as NSString).substring(from: scaner.scanLocation))
        }

        guard scaner.isAtEnd else {
            throw FHJSONParseError.redundantChars((scanerString as NSString).substring(from: scaner.scanLocation))
        }

        return result
    }

    func matchingObject() throws -> [String: Any] {
        var resultDictionary = [String: Any]()
        while !scaner.scanString("}", into: nil) {
            if !resultDictionary.isEmpty && !scaner.scanString(",", into: nil) {
                throw FHJSONParseError.dismissComma((scanerString as NSString).substring(from: scaner.scanLocation))
            }

            if scaner.scanString("\"", into: nil) {
                let key = try matchingString()

                if !scaner.scanString(":", into: nil) {
                     throw FHJSONParseError.dismissColon((scanerString as NSString).substring(from: scaner.scanLocation))
                }

                let value = try matchingValue()
                resultDictionary[key] = value

            } else {
                throw FHJSONParseError.dismissQuotes((scanerString as NSString).substring(from: scaner.scanLocation))
            }
        }

        return resultDictionary
    }

    func matchingArray() throws -> [Any?] {
        var resultArray = [Any?]()

        while !scaner.scanString("]", into: nil) {
            if !resultArray.isEmpty && !scaner.scanString(",", into: nil) {
                 throw FHJSONParseError.dismissComma((scanerString as NSString).substring(from: scaner.scanLocation))
            }

            let value = try matchingValue()
            resultArray.append(value)
        }

        return resultArray
    }

    func matchingValue() throws -> Any? {
        if scaner.scanString("\"", into: nil) {
            return try matchingString()
        } else if scaner.scanString("true", into: nil) {
            return true
        } else if scaner.scanString("false", into: nil) {
            return false
        } else if scaner.scanString("null", into: nil) {
            return nil
        } else if scaner.scanString("[", into: nil) {
            return try matchingArray()
        } else if scaner.scanString("{", into: nil) {
            return try matchingObject()
        } else {
            var number: Double = 0.0
            if scaner.scanDouble(&number) {
                return number
            }

            throw  FHJSONParseError.unvalidValue((scanerString as NSString).substring(from: scaner.scanLocation))
        }
    }

    // matchingString:  {0-9,a-z} {0,+}"
    func matchingString() throws -> String {
        
        matchFinalString = ""
        
        var isEnd = false
        while !isEnd {
            
            // 加入 autoreleasepool,防止内存暴涨
            try autoreleasepool { () -> Void in
                if scaner.scanCharacters(from: basicCharacterSet, into: &matchOnceString) {
                    matchFinalString += matchOnceString! as String
                } else if try matchingControlerCharacters() {
                    matchFinalString += "\\" + (matchOnceString! as String)
                } else if scaner.scanString("\"", into: nil) {
                  //  return matchFinalString
                    isEnd = true
                } else {
                    throw FHJSONParseError.unvalidString((scanerString as NSString).substring(from: scaner.scanLocation))
                }
            }
            
        }
        
        return matchFinalString
        
    }

    @inline(__always)  func matchingControlerCharacters() throws -> Bool {
        
        
        return try autoreleasepool { () -> Bool in
            if scaner.scanString("\\", into: nil) {
                for controlChars in validateChars {
                    if scaner.scanString(controlChars, into: &matchOnceString) {
                        return true
                    }
                }
                
                if scaner.scanString("u", into: nil) {
                    scaner.scanCharacters(from: hexCharacterSet, into: &matchOnceString)
                    if matchOnceString!.length != 4 {
                        throw FHJSONParseError.unvalidString((scanerString as NSString).substring(from: scaner.scanLocation))
                    } else {
                        matchOnceString = NSString(format: "\\%@", matchOnceString!)
                        return true
                    }
                    
                } else {
                    throw FHJSONParseError.unvalidString((scanerString as NSString).substring(from: scaner.scanLocation))
                }
            } else {
                return false
            }
        }
        
        
        
    }
}
