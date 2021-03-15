import HummingbirdMustache
import XCTest

final class MethodTests: XCTestCase {
    func testLowercased() throws {
        let template = try HBMustacheTemplate(string: """
        {{ lowercased(name) }}
        """)
        let object: [String: Any] = ["name": "Test"]
        XCTAssertEqual(template.render(object), "test")
    }

    func testUppercased() throws {
        let template = try HBMustacheTemplate(string: """
        {{ uppercased(name) }}
        """)
        let object: [String: Any] = ["name": "Test"]
        XCTAssertEqual(template.render(object), "TEST")
    }

    func testFirstLast() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
        <b>{{#first()}}first: {{/}}{{#last()}}last: {{/}}{{ name }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
        <b>first: resque</b>
        <b>hub</b>
        <b>last: rip</b>

        """)
    }

    func testIndex() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
        <b>{{#index()}}{{plusone(.)}}{{/}}) {{ name }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
        <b>1) resque</b>
        <b>2) hub</b>
        <b>3) rip</b>

        """)
    }

    func testEvenOdd() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
        <b>{{index()}}) {{#even()}}even {{/}}{{#odd()}}odd {{/}}{{ name }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
        <b>0) even resque</b>
        <b>1) odd hub</b>
        <b>2) even rip</b>

        """)
    }

    func testReversed() throws {
        let template = try HBMustacheTemplate(string: """
        {{#reversed(repo)}}
          <b>{{ name }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
          <b>rip</b>
          <b>hub</b>
          <b>resque</b>

        """)
    }

    func testArrayIndex() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
          <b>{{ index() }}) {{ name }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
          <b>0) resque</b>
          <b>1) hub</b>
          <b>2) rip</b>

        """)
    }

    func testArraySorted() throws {
        let template = try HBMustacheTemplate(string: """
        {{#sorted(repo)}}
          <b>{{ index() }}) {{ . }}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": ["resque", "hub", "rip"]]
        XCTAssertEqual(template.render(object), """
          <b>0) hub</b>
          <b>1) resque</b>
          <b>2) rip</b>

        """)
    }

    func testDictionaryEnumerated() throws {
        let template = try HBMustacheTemplate(string: """
        {{#enumerated(.)}}<b>{{ key }} = {{ value }}</b>{{/.}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2]
        let result = template.render(object)
        XCTAssertTrue(result == "<b>one = 1</b><b>two = 2</b>" || result == "<b>two = 2</b><b>one = 1</b>")
    }

    func testDictionarySortedByKey() throws {
        let template = try HBMustacheTemplate(string: """
        {{#sorted(.)}}<b>{{ key }} = {{ value }}</b>{{/.}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2, "three": 3]
        let result = template.render(object)
        XCTAssertEqual(result, "<b>one = 1</b><b>three = 3</b><b>two = 2</b>")
    }
}
