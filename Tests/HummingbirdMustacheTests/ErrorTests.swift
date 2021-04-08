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

import HummingbirdMustache
import XCTest

final class ErrorTests: XCTestCase {
    func testSectionCloseNameIncorrect() {
        XCTAssertThrowsError(try HBMustacheTemplate(string: """
        {{#test}}
        {{.}}
        {{/test2}}
        """)) { error in
            switch error {
            case let error as HBMustacheTemplate.ParserError:
                XCTAssertEqual(error.error as? HBMustacheTemplate.Error, .sectionCloseNameIncorrect)
                XCTAssertEqual(error.context.line, "{{/test2}}")
                XCTAssertEqual(error.context.lineNumber, 3)
                XCTAssertEqual(error.context.columnNumber, 4)

            default:
                XCTFail("\(error)")
            }
        }
    }

    func testUnfinishedName() {
        XCTAssertThrowsError(try HBMustacheTemplate(string: """
        {{#test}}
        {{name}
        {{/test2}}
        """)) { error in
            switch error {
            case let error as HBMustacheTemplate.ParserError:
                XCTAssertEqual(error.error as? HBMustacheTemplate.Error, .unfinishedName)
                XCTAssertEqual(error.context.line, "{{name}")
                XCTAssertEqual(error.context.lineNumber, 2)
                XCTAssertEqual(error.context.columnNumber, 7)

            default:
                XCTFail("\(error)")
            }
        }
    }

    func testExpectedSectionEnd() {
        XCTAssertThrowsError(try HBMustacheTemplate(string: """
        {{#test}}
        {{.}}
        """)) { error in
            switch error {
            case let error as HBMustacheTemplate.ParserError:
                XCTAssertEqual(error.error as? HBMustacheTemplate.Error, .expectedSectionEnd)
                XCTAssertEqual(error.context.line, "{{.}}")
                XCTAssertEqual(error.context.lineNumber, 2)
                XCTAssertEqual(error.context.columnNumber, 6)

            default:
                XCTFail("\(error)")
            }
        }
    }

    func testInvalidSetDelimiter() {
        XCTAssertThrowsError(try HBMustacheTemplate(string: """
        {{=<% %>=}}
        <%.%>
        <%={{}}=%>
        """)) { error in
            switch error {
            case let error as HBMustacheTemplate.ParserError:
                XCTAssertEqual(error.error as? HBMustacheTemplate.Error, .invalidSetDelimiter)
                XCTAssertEqual(error.context.line, "<%={{}}=%>")
                XCTAssertEqual(error.context.lineNumber, 3)
                XCTAssertEqual(error.context.columnNumber, 4)

            default:
                XCTFail("\(error)")
            }
        }
    }
}
