import XCTest
@testable import hummingbird_mustache

final class hummingbird_mustacheTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(hummingbird_mustache().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
