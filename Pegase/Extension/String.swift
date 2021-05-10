//
//  String.swift
//  Pegase
//
//  Created by thierryH24 on 09/05/2021.
//  Copyright © 2021 thierry hentic. All rights reserved.
//

import Foundation


extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


// https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
//extension StringProtocol {
//    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
//    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
//    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
//    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
//    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
//    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
//}
//extension LosslessStringConvertible {
//    var string: String { .init(self) }
//}
//extension BidirectionalCollection {
//    subscript(safe offset: Int) -> Element? {
//        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
//        return self[i]
//    }
//}


//Testing
//
//let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[safe: 10]   // "🇺🇸"
//test[11]   // "!"
//test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[10..<12]   // "🇺🇸!"
//test[10...12]   // "🇺🇸!!"
//test[...10]   // "Hello USA 🇺🇸"
//test[..<10]   // "Hello USA "
//test.first   // "H"
//test.last    // "!"
//
//// Subscripting the Substring
// test[...][...3]  // "Hell"
//
//// Note that they all return a Substring of the original String.
//// To create a new String from a substring
//test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
