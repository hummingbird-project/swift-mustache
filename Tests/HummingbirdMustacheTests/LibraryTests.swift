@testable import HummingbirdMustache
import XCTest

final class LibraryTests: XCTestCase {
    func testDirectoryLoad() throws {
        let fs = FileManager()
        try? fs.createDirectory(atPath: "templates", withIntermediateDirectories: false)
        let mustache = "<test>{{#value}}<value>{{.}}</value>{{/value}}</test>"
        let data = Data(mustache.utf8)
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates")) }
        try data.write(to: URL(fileURLWithPath: "templates/test.mustache"))
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates/test.mustache")) }

        let library = HBMustacheLibrary(directory: "./templates")
        let object = ["value": ["value1", "value2"]]
        XCTAssertEqual(library.render(object, withTemplate: "test"), "<test><value>value1</value><value>value2</value></test>")
    }
}
