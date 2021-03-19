import Foundation
import HummingbirdMustache
import XCTest

public struct AnyDecodable: Decodable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension AnyDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            #if canImport(Foundation)
                self.init(NSNull())
            #else
                self.init(Optional<Self>.none)
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
            self.init(array.map { $0.value })
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
    func loadSpec(name: String) throws -> Data {
        let url = URL(string: "https://raw.githubusercontent.com/mustache/spec/master/specs/\(name).json")!
        return try Data(contentsOf: url)
    }
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
                    let result = library.render(data.value, withTemplate: "__test__")
                    XCTAssertEqual(result, expected)
                } else {
                    let template = try HBMustacheTemplate(string: self.template)
                    let result = template.render(data.value)
                    XCTAssertEqual(result, expected)
                }
            }
        }
        let overview: String
        let tests: [Test]
    }

    func testSpec(name: String) throws {
        let data = try loadSpec(name: name)
        let spec = try JSONDecoder().decode(Spec.self, from: data)

        print(spec.overview)
        for test in spec.tests {
            XCTAssertNoThrow(try test.run())
        }
    }

    func testCommentsSpec() throws {
        try testSpec(name: "comments")
    }

    func testDelimitersSpec() throws {
        try testSpec(name: "delimiters")
    }

    func testInterpolationSpec() throws {
        try testSpec(name: "interpolation")
    }

    func testInvertedSpec() throws {
        try testSpec(name: "inverted")
    }

    func testPartialsSpec() throws {
        try testSpec(name: "partials")
    }

    func testSectionsSpec() throws {
        try testSpec(name: "sections")
    }
}
