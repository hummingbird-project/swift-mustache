import XCTest
@testable import HummingbirdMustache

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
    
    func testMustacheManualExample8() throws {
        let template = try HBMustacheTemplate(string: """
            <h1>Today{{! ignore me }}.</h1>
            """)
        let object: [String: Any] = ["repo": []]
        XCTAssertEqual(template.render(object), """
            <h1>Today.</h1>
            """)
    }
    
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
