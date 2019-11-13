//
//  ViewController.swift
//  XFJSONParse
//
//  Created by 李腾芳 on 2019/11/12.
//  Copyright © 2019 HSBC Holdings plc. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet var inputTextView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inputTextView.isAutomaticQuoteSubstitutionEnabled = false
        inputTextView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        
        if let textview = notification.object as? NSTextView {
            if textview === inputTextView {
                let string = textview.string
            //    print(textview.string)
                
                
                do {
//                    if let result = try FHJSONParse(textview.string).parse() {
//
//
//                        if let array = result as? Array<Any?> {
//                            let compactArray = array.compactMap { $0 }
//
//                            outputTextView.string = "\(compactArray)"
//                        } else if let dic =  result as? Dictionary<String,Any> {
//                            //    print(dic)
//
//                            outputTextView.string = dic.description
//                        }
//
//
//
//                    }
                    
                    
                    let result = try FHJSONParse(textview.string).parse()
                        
                        
                        if let array = result as? Array<Any?> {
                            let compactArray = array.compactMap { $0 }
                            
                            outputTextView.string = "\(compactArray)"
                        } else if let dic =  result as? Dictionary<String,Any> {
                            //    print(dic)
                            
                            outputTextView.string = dic.description
                        }
                        
                        
                        
                    
                    
                } catch {
                    if let parseError = error as? FHJSONParseError {
                        var errorInfo = ""
                        switch parseError {
                            
                        case .redundantChars(let str):
                            errorInfo = "JSON syntax error: redundant chars in \"\n \(str.suffix(10))\""
                            
                        case .unvalidValue(let str):
                            errorInfo = "JSON syntax error: unvalid value in \"\n \(str.suffix(10))\""
                        case .dismissStartSymbol(let str):
                            errorInfo = "JSON syntax error: miss `{` or `[` in  \"\n \(str.suffix(10))\""
                            
                        case .dismissComma(let str):
                            errorInfo = "JSON syntax error: miss `,` in  \"\n \(str.suffix(10))\""
                        case .dismissColon(let str):
                            errorInfo = "JSON syntax error: miss `:` in  \"\n \(str.suffix(10))\""
                        case .dismissQuotes(let str):
                            errorInfo = "JSON syntax error: miss `\"` in  \"\n \(str.suffix(10))\""
                        case .unvalidString(let str):
                            errorInfo = "JSON syntax error: unvalid string in  `\"`\n \(str.suffix(10))\""
                        }
                         outputTextView.string = errorInfo
                    }
                }
                
            } else {
                
            }
            
            
        }
//
//        print(notification)
//        print(notification.object)
    }
}

