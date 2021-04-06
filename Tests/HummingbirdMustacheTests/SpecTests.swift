import Foundation
#if os(Linux)
import FoundationNetworking
#endif
import HummingbirdMustache
import XCTest

public struct AnyDecodable: Decodable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

public extension AnyDecodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            #if canImport(Foundation)
            self.init(NSNull())
            #else
            self.init(Self?.none)
            #endif
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
                print("Test: \(self.name)")
                if let partials = self.partials {
                    let library = HBMustacheLibrary()
                    let template = try HBMustacheTemplate(string: self.template)
                    library.register(template, named: "__test__")
                    for (key, value) in partials {
                        let template = try HBMustacheTemplate(string: value)
                        library.register(template, named: key)
                    }
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
        for test in spec.tests {
            guard !ignoring.contains(test.name) else { continue }
            XCTAssertNoThrow(try test.run())
        }
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
        let url = URL(
            string: "https://raw.githubusercontent.com/mustache/spec/ab227509e64961943ca374c09c08b63f59da014a/specs/inheritance.json"
        )!
        try self.testSpec(url: url)
    }
}
