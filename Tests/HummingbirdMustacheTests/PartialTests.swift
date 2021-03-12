import XCTest
@testable import HummingbirdMustache

final class PartialTests: XCTestCase {

    /// Testing partials
    func testMustacheManualExample9() throws {
        let library = HBMustacheLibrary()
        let template = try HBMustacheTemplate(string: """
            <h2>Names</h2>
            {{#names}}
              {{> user}}
            {{/names}}
            """)
        let template2 = try HBMustacheTemplate(string: """
            <strong>{{.}}</strong>
            """)
        library.register(template, named: "base")
        library.register(template2, named: "user")
        
        let object: [String: Any] = ["names": ["john", "adam", "claire"]]
        XCTAssertEqual(library.render(object, withTemplateNamed: "base"), """
            <h2>Names</h2>
              <strong>john</strong>
              <strong>adam</strong>
              <strong>claire</strong>

            """)
    }

    /// Testing dynamic partials
    func testDynamicPartials() throws {
        let library = HBMustacheLibrary()
        let template = try HBMustacheTemplate(string: """
            <h2>Names</h2>
            {{partial}}
            """)
        let template2 = try HBMustacheTemplate(string: """
            {{#names}}
              <strong>{{.}}</strong>
            {{/names}}
            """)
        library.register(template, named: "base")
        
        let object: [String: Any] = ["names": ["john", "adam", "claire"], "partial": template2]
        XCTAssertEqual(library.render(object, withTemplateNamed: "base"), """
            <h2>Names</h2>
              <strong>john</strong>
              <strong>adam</strong>
              <strong>claire</strong>

            """)
    }
}
