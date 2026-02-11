//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

extension String {
    private static let htmlEscapedCharacters: [Character: String] = [
        "<": "&lt;",
        ">": "&gt;",
        "&": "&amp;",
        "\"": "&quot;",
        "'": "&#39;",
    ]
    /// HTML escape string. Replace '<', '>' and '&' with HTML escaped versions
    func htmlEscape() -> String {
        var newString = ""
        newString.reserveCapacity(count)
        // currently doing this by going through each character could speed
        // this us by treating as an array of UInt8's
        for c in self {
            if let replacement = Self.htmlEscapedCharacters[c] {
                newString += replacement
            } else {
                newString.append(c)
            }
        }
        return newString
    }
}
