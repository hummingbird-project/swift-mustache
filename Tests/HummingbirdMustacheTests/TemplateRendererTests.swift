@testable import HummingbirdMustache
import XCTest

final class TemplateRendererTests: XCTestCase {
    func testText() throws {
        let template = try HBMustacheTemplate(string: "test text")
        XCTAssertEqual(template.render("test"), "test text")
    }

    func testStringVariable() throws {
        let template = try HBMustacheTemplate(string: "test {{.}}")
        XCTAssertEqual(template.render("text"), "test text")
    }

    func testIntegerVariable() throws {
        let template = try HBMustacheTemplate(string: "test {{.}}")
        XCTAssertEqual(template.render(101), "test 101")
    }

    func testDictionary() throws {
        let template = try HBMustacheTemplate(string: "test {{value}} {{bool}}")
        XCTAssertEqual(template.render(["value": "test2", "bool": true]), "test test2 true")
    }

    func testArraySection() throws {
        let template = try HBMustacheTemplate(string: "test {{#value}}*{{.}}{{/value}}")
        XCTAssertEqual(template.render(["value": ["test2", "bool"]]), "test *test2*bool")
        XCTAssertEqual(template.render(["value": ["test2"]]), "test *test2")
        XCTAssertEqual(template.render(["value": []]), "test ")
    }

    func testBooleanSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#.}}Yep{{/.}}")
        XCTAssertEqual(template.render(true), "test Yep")
        XCTAssertEqual(template.render(false), "test ")
    }

    func testIntegerSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render(23), "test 23")
    }

    func testStringSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render("Hello"), "test Hello")
    }

    func testInvertedSection() throws {
        let template = try HBMustacheTemplate(string: "test {{^.}}Inverted{{/.}}")
        XCTAssertEqual(template.render(true), "test ")
        XCTAssertEqual(template.render(false), "test Inverted")
    }

    func testMirror() throws {
        struct Test {
            let string: String
        }
        let template = try HBMustacheTemplate(string: "test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
    }

    func testOptionalMirror() throws {
        struct Test {
            let string: String?
        }
        let template = try HBMustacheTemplate(string: "test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
    }

    func testOptionalSequence() throws {
        struct Test {
            let string: String?
        }
        let template = try HBMustacheTemplate(string: "test {{#string}}*{{.}}{{/string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test *string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
        let template2 = try HBMustacheTemplate(string: "test {{^string}}*{{/string}}")
        XCTAssertEqual(template2.render(Test(string: "string")), "test ")
        XCTAssertEqual(template2.render(Test(string: nil)), "test *")
    }

    func testStructureInStructure() throws {
        struct SubTest {
            let string: String?
        }
        struct Test {
            let test: SubTest
        }

        let template = try HBMustacheTemplate(string: "test {{test.string}}")
        XCTAssertEqual(template.render(Test(test: .init(string: "sub"))), "test sub")
    }

    func testTextEscaping() throws {
        let template1 = try HBMustacheTemplate(string: "{{% CONTENT_TYPE:TEXT}}{{.}}")
        XCTAssertEqual(template1.render("<>"), "<>")
        let template2 = try HBMustacheTemplate(string: "{{% CONTENT_TYPE:HTML}}{{.}}")
        XCTAssertEqual(template2.render("<>"), "&lt;&gt;")
    }

    func testStopClimbingStack() throws {
        let template1 = try HBMustacheTemplate(string: "{{#test}}{{name}}{{/test}}")
        let template2 = try HBMustacheTemplate(string: "{{#test}}{{.name}}{{/test}}")
        let object: [String: Any] = ["test": [:], "name": "John"]
        let object2: [String: Any] = ["test": ["name": "Jane"], "name": "John"]
        XCTAssertEqual(template1.render(object), "John")
        XCTAssertEqual(template2.render(object), "")
        XCTAssertEqual(template2.render(object2), "Jane")
    }

    /// variables
    func testMustacheManualExample1() throws {
        let template = try HBMustacheTemplate(string: """
        Hello {{name}}
        You have just won {{value}} dollars!
        {{#in_ca}}
        Well, {{taxed_value}} dollars, after taxes.
        {{/in_ca}}
        """)
        let object: [String: Any] = ["name": "Chris", "value": 10000, "taxed_value": 10000 - (10000 * 0.4), "in_ca": true]
        XCTAssertEqual(template.render(object), """
        Hello Chris
        You have just won 10000 dollars!
        Well, 6000.0 dollars, after taxes.

        """)
    }

    /// test esacped and unescaped text
    func testMustacheManualExample2() throws {
        let template = try HBMustacheTemplate(string: """
        *{{name}}
        *{{age}}
        *{{company}}
        *{{{company}}}
        """)
        let object: [String: Any] = ["name": "Chris", "company": "<b>GitHub</b>"]
        XCTAssertEqual(template.render(object), """
        *Chris
        *
        *&lt;b&gt;GitHub&lt;/b&gt;
        *<b>GitHub</b>
        """)
    }

    /// test boolean
    func testMustacheManualExample3() throws {
        let template = try HBMustacheTemplate(string: """
        Shown.
        {{#person}}
          Never shown!
        {{/person}}
        """)
        let object: [String: Any] = ["person": false]
        XCTAssertEqual(template.render(object), """
        Shown.

        """)
    }

    /// test non-empty lists
    func testMustacheManualExample4() throws {
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

    /// test lambdas
    func testMustacheManualExample5() throws {
        let template = try HBMustacheTemplate(string: """
        {{#wrapped}}{{name}} is awesome.{{/wrapped}}
        """)
        func wrapped(object: Any, template: HBMustacheTemplate) -> String {
            return "<b>\(template.render(object))</b>"
        }
        let object: [String: Any] = ["name": "Willy", "wrapped": HBMustacheLambda(wrapped)]
        XCTAssertEqual(template.render(object), """
        <b>Willy is awesome.</b>
        """)
    }

    /// test setting context object
    func testMustacheManualExample6() throws {
        let template = try HBMustacheTemplate(string: """
        {{#person?}}
          Hi {{name}}!
        {{/person?}}
        """)
        let object: [String: Any] = ["person?": ["name": "Jon"]]
        XCTAssertEqual(template.render(object), """
          Hi Jon!

        """)
    }

    /// test inverted sections
    func testMustacheManualExample7() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
          <b>{{name}}</b>
        {{/repo}}
        {{^repo}}
          No repos :(
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": []]
        XCTAssertEqual(template.render(object), """
          No repos :(

        """)
    }

    /// test comments
    func testMustacheManualExample8() throws {
        let template = try HBMustacheTemplate(string: """
        <h1>Today{{! ignore me }}.</h1>
        """)
        let object: [String: Any] = ["repo": []]
        XCTAssertEqual(template.render(object), """
        <h1>Today.</h1>
        """)
    }

    func testPerformance() throws {
        let template = try HBMustacheTemplate(string: """
        {{#repo}}
          <b>{{name}}</b>
        {{/repo}}
        """)
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        let date = Date()
        for _ in 1...10000 {
            _ = template.render(object)
        }
        print(-date.timeIntervalSinceNow)
    }
}
