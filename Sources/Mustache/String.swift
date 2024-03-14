//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

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
