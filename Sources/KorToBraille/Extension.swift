//
//  File.swift
//  
//
//  Created by Nayeon Kim on 2021/12/13.
//

import Foundation

// 문자열 extension
extension String {
    func replace(target: String, withString: String) -> String { return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil) }
    
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    subscript(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}


extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars

        return scalars[scalars.startIndex].value
    }
}
