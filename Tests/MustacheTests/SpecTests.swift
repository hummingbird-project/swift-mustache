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
import Mustache
import XCTest

#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

public struct AnyDecodable: Decodable {
    public let value: Any

    public init(_ value: some Any) {
        self.value = value
    }
}

extension AnyDecodable {
    public init(from decoder: Decoder) throws {
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
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyDecodable value cannot be decoded"
            )
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
            var data: AnyDecodable
            let partials: [String: String]?
            let template: String
            let expected: String

            func run() throws {
                print("Test: \(self.name)")
                if let partials = self.partials {
                    let template = try MustacheTemplate(string: self.template)
                    var templates: [String: MustacheTemplate] = ["__test__": template]
                    for (key, value) in partials {
                        let template = try MustacheTemplate(string: value)
                        templates[key] = template
                    }
                    let library = MustacheLibrary(templates: templates)
                    let result = library.render(self.data.value, withTemplate: "__test__")
                    self.XCTAssertSpecEqual(result, self)
                } else {
                    let template = try MustacheTemplate(string: self.template)
                    let result = template.render(self.data.value)
                    self.XCTAssertSpecEqual(result, self)
                }
            }

            func XCTAssertSpecEqual(_ result: String?, _ test: Spec.Test) {
                if result != test.expected {
                    XCTFail(
                        """
                        \(test.name)
                        \(test.desc)
                        template:
                        \(test.template)
                        data:
                        \(test.data.value)
                        \(test.partials.map { "partials:\n\($0)" } ?? "")
                        result:
                        \(result ?? "nil")
                        expected:
                        \(test.expected)
                        """
                    )
                }
            }
        }

        let overview: String
        let tests: [Test]
    }

    func testSpec(name: String, ignoring: [String] = []) async throws {
        let url = URL(
            string: "https://raw.githubusercontent.com/mustache/spec/master/specs/\(name).json"
        )!
        try await testSpec(url: url, ignoring: ignoring)
    }

    func testSpec(url: URL, ignoring: [String] = []) async throws {
        #if compiler(>=6.0)
        let (data, _) = try await URLSession.shared.data(from: url)
        #else
        let data = try Data(contentsOf: url)
        #endif
        let spec = try JSONDecoder().decode(Spec.self, from: data)

        let date = Date()
        for test in spec.tests {
            guard !ignoring.contains(test.name) else { continue }
            XCTAssertNoThrow(try test.run())
        }
        print(-date.timeIntervalSinceNow)
    }

    func testSpec(name: String, only: [String]) async throws {
        let url = URL(
            string: "https://raw.githubusercontent.com/mustache/spec/master/specs/\(name).json"
        )!
        try await testSpec(url: url, only: only)
    }

    func testSpec(url: URL, only: [String]) async throws {
        #if compiler(>=6.0)
        let (data, _) = try await URLSession.shared.data(from: url)
        #else
        let data = try Data(contentsOf: url)
        #endif
        let spec = try JSONDecoder().decode(Spec.self, from: data)

        let date = Date()
        for test in spec.tests {
            guard only.contains(test.name) else { continue }
            XCTAssertNoThrow(try test.run())
        }
        print(-date.timeIntervalSinceNow)
    }

    func testLambdaSpec() async throws {
        var g = 0
        let lambdaMap = [
            "Interpolation": MustacheLambda { "world" },
            "Interpolation - Expansion": MustacheLambda { "{{planet}}" },
            "Interpolation - Alternate Delimiters": MustacheLambda { "|planet| => {{planet}}" },
            "Interpolation - Multiple Calls": MustacheLambda {
                MustacheLambda {
                    g += 1
                    return g
                }
            },
            "Escaping": MustacheLambda { ">" },
            "Section": MustacheLambda { text in text == "{{x}}" ? "yes" : "no" },
            "Section - Expansion": MustacheLambda { text in text + "{{planet}}" + text },
            // Not going to bother implementing this requires pushing alternate delimiters through the context
            // "Section - Alternate Delimiters": MustacheLambda { text in return text + "{{planet}} => |planet|" + text },
            "Section - Multiple Calls": MustacheLambda { text in "__" + text + "__" },
            "Inverted Section": MustacheLambda { false },
        ]
        let url = URL(string: "https://raw.githubusercontent.com/mustache/spec/master/specs/~lambdas.json")!
        #if compiler(>=6.0)
        let (data, _) = try await URLSession.shared.data(from: url)
        #else
        let data = try Data(contentsOf: url)
        #endif
        let spec = try JSONDecoder().decode(Spec.self, from: data)
        // edit spec and replace lambda with Swift lambda
        let editedSpecTests = spec.tests.compactMap { test -> Spec.Test? in
            var test = test
            var newTestData: [String: Any] = [:]
            guard let dictionary = test.data.value as? [String: Any] else { return nil }
            for values in dictionary {
                newTestData[values.key] = values.value
            }
            guard let lambda = lambdaMap[test.name] else { return nil }
            newTestData["lambda"] = lambda
            test.data = .init(newTestData)
            return test
        }

        let date = Date()
        for test in editedSpecTests {
            XCTAssertNoThrow(try test.run())
        }
        print(-date.timeIntervalSinceNow)
    }

    func testCommentsSpec() async throws {
        try await self.testSpec(name: "comments")
    }

    func testDelimitersSpec() async throws {
        try await self.testSpec(name: "delimiters")
    }

    func testInterpolationSpec() async throws {
        try await self.testSpec(name: "interpolation")
    }

    func testInvertedSpec() async throws {
        try await self.testSpec(name: "inverted")
    }

    func testPartialsSpec() async throws {
        try await self.testSpec(name: "partials")
    }

    func testSectionsSpec() async throws {
        try await self.testSpec(name: "sections")
    }

    func testInheritanceSpec() async throws {
        try await self.testSpec(
            name: "~inheritance",
            ignoring: [
                "Intrinsic indentation",
                "Nested block reindentation",
            ]
        )
    }

    func testDynamicNamesSpec() async throws {
        try await self.testSpec(name: "~dynamic-names")
    }
}
