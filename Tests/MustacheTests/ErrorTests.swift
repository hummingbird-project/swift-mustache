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

import Mustache
import XCTest

final class ErrorTests: XCTestCase {
    func testSectionCloseNameIncorrect() {
        XCTAssertThrowsError(try MustacheTemplate(string: """
        {{#test}}
        {{.}}
        {{/test2}}
        """)) { error in
            switch error {
            case let error as MustacheTemplate.ParserError:
                if let mustacheError = error.error as? MustacheTemplate.Error, case .sectionCloseNameIncorrect = mustacheError {
                    XCTAssertEqual(error.context.line, "{{/test2}}")
                    XCTAssertEqual(error.context.lineNumber, 3)
                    XCTAssertEqual(error.context.columnNumber, 4)
                } else {
                    XCTFail("\(error)")
                }

            default:
                XCTFail("\(error)")
            }
        }
    }

    func testUnfinishedName() {
        XCTAssertThrowsError(try MustacheTemplate(string: """
        {{#test}}
        {{name}
        {{/test2}}
        """)) { error in
            switch error {
            case let error as MustacheTemplate.ParserError:
                if let mustacheError = error.error as? MustacheTemplate.Error, case .unfinishedName = mustacheError {
                    XCTAssertEqual(error.context.line, "{{name}")
                    XCTAssertEqual(error.context.lineNumber, 2)
                    XCTAssertEqual(error.context.columnNumber, 3)
                } else {
                    XCTFail("\(error)")
                }
            default:
                XCTFail("\(error)")
            }
        }
    }

    func testExpectedSectionEnd() {
        XCTAssertThrowsError(try MustacheTemplate(string: """
        {{#test}}
        {{.}}
        """)) { error in
            switch error {
            case let error as MustacheTemplate.ParserError:
                if let mustacheError = error.error as? MustacheTemplate.Error, case .expectedSectionEnd = mustacheError {
                    XCTAssertEqual(error.context.line, "{{.}}")
                    XCTAssertEqual(error.context.lineNumber, 2)
                    XCTAssertEqual(error.context.columnNumber, 6)
                } else {
                    XCTFail("\(error)")
                }

            default:
                XCTFail("\(error)")
            }
        }
    }

    func testInvalidSetDelimiter() {
        XCTAssertThrowsError(try MustacheTemplate(string: """
        {{=<% %>=}}
        <%.%>
        <%={{}}=%>
        """)) { error in
            switch error {
            case let error as MustacheTemplate.ParserError:
                if let mustacheError = error.error as? MustacheTemplate.Error, case .invalidSetDelimiter = mustacheError {
                    XCTAssertEqual(error.context.line, "<%={{}}=%>")
                    XCTAssertEqual(error.context.lineNumber, 3)
                    XCTAssertEqual(error.context.columnNumber, 4)
                } else {
                    XCTFail("\(error)")
                }

            default:
                XCTFail("\(error)")
            }
        }
    }
}
