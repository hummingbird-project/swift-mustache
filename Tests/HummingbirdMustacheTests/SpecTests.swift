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

import Foundation
#if os(Linux)
import FoundationNetworking
#endif
import HummingbirdMustache
import XCTest

public struct AnyDecodable: Decodable {
    public let value: Any

    public init(_ value: some Any) {
        self.value = value
    }
}

public extension AnyDecodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyDecodable].self) {
            self.init(array.map(\.value))
        } else if let dictionary = try? container.decode([String: AnyDecodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

/// Verify implementation against formal standard for Mustache.
/// https://github.com/mustache/spec
final class MustacheSpecTests: XCTestCase {
    struct Spec: Decodable {
        struct Test: Decodable {
            let name: String
            let desc: String
            let data: AnyDecodable
            let partials: [String: String]?
            let template: String
            let expected: String

            func run() throws {
                // print("Test: \(self.name)")
                if let partials = self.partials {
                    let template = try HBMustacheTemplate(string: self.template)
                    var templates: [String: HBMustacheTemplate] = ["__test__": template]
                    for (key, value) in partials {
                        let template = try HBMustacheTemplate(string: value)
                        templates[key] = template
                    }
                    let library = HBMustacheLibrary(templates: templates)
                    let result = library.render(self.data.value, withTemplate: "__test__")
                    self.XCTAssertSpecEqual(result, self)
                } else {
                    let template = try HBMustacheTemplate(string: self.template)
                    let result = template.render(self.data.value)
                    self.XCTAssertSpecEqual(result, self)
                }
            }

            func XCTAssertSpecEqual(_ result: String?, _ test: Spec.Test) {
                if result != test.expected {
                    XCTFail("\n\(test.desc)result:\n\(result ?? "nil")\nexpected:\n\(test.expected)")
                }
            }
        }

        let overview: String
        let tests: [Test]
    }

    func testSpec(name: String, ignoring: [String] = []) throws {
        let url = URL(string: "https://raw.githubusercontent.com/mustache/spec/master/specs/\(name).json")!
        try testSpec(url: url, ignoring: ignoring)
    }

    func testSpec(url: URL, ignoring: [String] = []) throws {
        let data = try Data(contentsOf: url)
        let spec = try JSONDecoder().decode(Spec.self, from: data)

        print(spec.overview)
        let date = Date()
        for test in spec.tests {
            guard !ignoring.contains(test.name) else { continue }
            XCTAssertNoThrow(try test.run())
        }
        print(-date.timeIntervalSinceNow)
    }

    func testCommentsSpec() throws {
        try self.testSpec(name: "comments")
    }

    func testDelimitersSpec() throws {
        try self.testSpec(name: "delimiters")
    }

    func testInterpolationSpec() throws {
        try self.testSpec(name: "interpolation")
    }

    func testInvertedSpec() throws {
        try self.testSpec(name: "inverted")
    }

    func testPartialsSpec() throws {
        try self.testSpec(name: "partials")
    }

    func testSectionsSpec() throws {
        try self.testSpec(name: "sections")
    }

    func testInheritanceSpec() throws {
        try XCTSkipIf(true) // inheritance spec has been updated and has added requirements, we don't yet support
        try self.testSpec(name: "~inheritance")
    }
}
