import HummingbirdMustache
import XCTest

final class TransformTests: XCTestCase {
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

    func testNewline() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
        <b>{{name}}</b>
        {{/repo}}

        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(template.render(object), """
        <b>resque</b>
        <b>hub</b>
        <b>rip</b>

        """)
    }

    func testFirstLast() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
        <b>{{#first()}}first: {{/first()}}{{#last()}}last: {{/last()}}{{ name }}</b>
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
        <b>{{#index()}}{{plusone(.)}}{{/index()}}) {{ name }}</b>
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
        <b>{{index()}}) {{#even()}}even {{/even()}}{{#odd()}}odd {{/odd()}}{{ name }}</b>
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
        {{/reversed(repo)}}

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
        {{/sorted(repo)}}
        """)
        let object: [String: Any] = ["repo": ["resque", "hub", "rip"]]
        XCTAssertEqual(template.render(object), """
          <b>0) hub</b>
          <b>1) resque</b>
          <b>2) rip</b>

        """)
    }

    func testListOutput() throws {
        let object = [1, 2, 3, 4]
        let template = try HBMustacheTemplate(string: "{{#.}}{{.}}{{^last()}}, {{/last()}}{{/.}}")
        XCTAssertEqual(template.render(object), "1, 2, 3, 4")
    }

    func testDictionaryEnumerated() throws {
        let template = try HBMustacheTemplate(string: """
        {{#enumerated(.)}}<b>{{ key }} = {{ value }}</b>{{/enumerated(.)}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2]
        let result = template.render(object)
        XCTAssertTrue(result == "<b>one = 1</b><b>two = 2</b>" || result == "<b>two = 2</b><b>one = 1</b>")
    }

    func testDictionarySortedByKey() throws {
        let template = try HBMustacheTemplate(string: """
        {{#sorted(.)}}<b>{{ key }} = {{ value }}</b>{{/sorted(.)}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2, "three": 3]
        let result = template.render(object)
        XCTAssertEqual(result, "<b>one = 1</b><b>three = 3</b><b>two = 2</b>")
    }
}
