//
//  NumberStringParser.swift
//  FHParseJSON
//
//  Created by 李腾芳 on 2019/11/8.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//
//
//#if iOS
//import UIKit
//#endif Mac
import Foundation

class NumberConstructor {
    var isPositive: Bool = true
    var integer: Int?
    var fraction: Double = 0.0
    var exponent: Int = 0

    func asNumber() -> Double? {
        assert(fraction < 1)
        guard let integer = integer else {
            return nil
        }

        return (Double(integer) + fraction) * pow(10, Double(exponent))
    }
}

enum NumberStringParserError: Error {
    case inputEmpty
    case missingIntegerInfo
    case unvalidCharacter
}

class NumberStringParser {
    var index: String.Index!
    var scanerString: String
    var numberConstructor: NumberConstructor

    init(str: String) {
        scanerString = str
        numberConstructor = NumberConstructor()
    }

    func getNumber() throws -> Double {
        guard !scanerString.isEmpty else {
            throw NumberStringParserError.inputEmpty
        }

        index = scanerString.startIndex

        numberConstructor.isPositive = try fetchSigned()

        let (number, bit) = try fetchInteger()
        guard bit > 0 else {
            throw NumberStringParserError.missingIntegerInfo
        }

        numberConstructor.integer = number

        numberConstructor.fraction = try fecthfraction() ?? 0
        numberConstructor.exponent = try fecthExponent() ?? 0

        guard index == scanerString.endIndex else {
            throw NumberStringParserError.unvalidCharacter
        }

        return numberConstructor.asNumber()!
    }

    func fetchSigned() throws -> Bool {
//
//        guard index != scanerString.endIndex  else {
//            throw NumberStringParserError.earlyFinsh
//        }

        if scanerString[index!] == "+" {
            return true
        } else if scanerString[index!] == "-" {
            return false
        } else {
            return true
        }
    }

    func fetchInteger() throws -> (Int, Int) {
        var number = 0
        var bit = 0
        guard index != scanerString.endIndex else {
            throw NumberStringParserError.missingIntegerInfo
        }
        let chars: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var value = chars.firstIndex(of: scanerString[index])
        while value != nil {
            number = number * 10 + value!
            bit += 1
            index = scanerString.index(after: index)
            if index != scanerString.endIndex {
                value = chars.firstIndex(of: scanerString[index])
            } else {
                value = nil
            }
        }

        return (number, bit)
    }

    func fecthfraction() throws -> Double? {
        guard index != scanerString.endIndex else {
            return nil
        }

        if scanerString[index] == "." {
            index = scanerString.index(after: index)
            let (number, bit) = try fetchInteger()
            if bit == 0 {
                return 0.0
            } else {
                return Double(number) / pow(10, Double(bit))
            }

        } else {
            return nil
        }
    }

    func fecthExponent() throws -> Int? {
        guard index != scanerString.endIndex else {
            return nil
        }

        if scanerString[index] == "e" || scanerString[index] == "E" {
            index = scanerString.index(after: index)
            let (number, bit) = try fetchInteger()

            return number

        } else {
            return nil
        }
    }
}
