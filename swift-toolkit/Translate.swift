//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

extension Array {
    mutating func mapInPlace(_ transform: (Element) -> Element) {
        self = map(transform)
    }
}

public class Translate: NSObject {
    fileprivate static var dict = [String:String]()
    
    static public var defaultLanguage = "en"
    static public var locale  = Locale(identifier: "en")
    static public var files = [String]() {
        didSet {
            files.mapInPlace { file in
                return AppGroup.url.appendingPathComponent("\(file).plist").path
            }
        }
    }
    
    static public var language:String = defaultLanguage {
        didSet {
            locale = Locale(identifier: (language == "cn") ? "zh_CN" : language)
            
            dict = [:]
            
            if language == defaultLanguage {
                return
            }
            
            for file in files {
                dict += NSDictionary(contentsOfFile: file) as! [String: String]
            }
        }
    }
    
    static public func s(_ str : String) -> String {
        return dict[str] ?? str
    }
    
    static public func stringFromNumber(_ num : Int) -> String {
        if language == defaultLanguage {
            return String(num)

        } else {
            let formatter = NumberFormatter()
            formatter.locale = locale
            
            if language == "cn" {
                formatter.numberStyle = .spellOut
            }
            
            return formatter.string(from: NSNumber(integerLiteral: num))!
        }
    }
    
    static public func readings(_ reading : String) -> String {
        var reading = reading
        if language == defaultLanguage {
            return reading
        }
        
        let bundle = Bundle.main.path(forResource: "trans_reading_\(language)", ofType: "plist")
        let books = NSDictionary(contentsOfFile: bundle!) as! [String:String]
        
        for (key, value) in books {
            reading = reading.replacingOccurrences(of: key, with: value)
        }
        
        return reading
    }
}
