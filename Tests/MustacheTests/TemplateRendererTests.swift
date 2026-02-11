//
// This source file is part of the Hummingbird server framework project
// Copyright (c) the Hummingbird authors
//
// See LICENSE.txt for license information
// SPDX-License-Identifier: Apache-2.0
//

import Mustache
import XCTest

final class TemplateRendererTests: XCTestCase {
    func testText() throws {
        let template = try MustacheTemplate(string: "test text")
        XCTAssertEqual(template.render("test"), "test text")
    }

    func testStringVariable() throws {
        let template = try MustacheTemplate(string: "test {{.}}")
        XCTAssertEqual(template.render("text"), "test text")
    }

    func testIntegerVariable() throws {
        let template = try MustacheTemplate(string: "test {{.}}")
        XCTAssertEqual(template.render(101), "test 101")
    }

    func testDictionary() throws {
        let template = try MustacheTemplate(string: "test {{value}} {{bool}}")
        XCTAssertEqual(template.render(["value": "test2", "bool": true]), "test test2 true")
    }

    func testArraySection() throws {
        let template = try MustacheTemplate(string: "test {{#value}}*{{.}}{{/value}}")
        XCTAssertEqual(template.render(["value": ["test2", "bool"]]), "test *test2*bool")
        XCTAssertEqual(template.render(["value": ["test2"]]), "test *test2")
        XCTAssertEqual(template.render(["value": []]), "test ")
    }

    func testBooleanSection() throws {
        let template = try MustacheTemplate(string: "test {{#.}}Yep{{/.}}")
        XCTAssertEqual(template.render(true), "test Yep")
        XCTAssertEqual(template.render(false), "test ")
    }

    func testIntegerSection() throws {
        let template = try MustacheTemplate(string: "test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render(23), "test 23")
    }

    func testStringSection() throws {
        let template = try MustacheTemplate(string: "test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render("Hello"), "test Hello")
    }

    func testInvertedSection() throws {
        let template = try MustacheTemplate(string: "test {{^.}}Inverted{{/.}}")
        XCTAssertEqual(template.render(true), "test ")
        XCTAssertEqual(template.render(false), "test Inverted")
    }

    func testMirror() throws {
        struct Test {
            let string: String
        }
        let template = try MustacheTemplate(string: "test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
    }

    func testOptionalMirror() throws {
        struct Test {
            let string: String?
        }
        let template = try MustacheTemplate(string: "test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
    }

    func testOptionalSection() throws {
        struct Test {
            let string: String?
        }
        let template = try MustacheTemplate(string: "test {{#string}}*{{.}}{{/string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test *string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
        let template2 = try MustacheTemplate(string: "test {{^string}}*{{/string}}")
        XCTAssertEqual(template2.render(Test(string: "string")), "test ")
        XCTAssertEqual(template2.render(Test(string: nil)), "test *")
    }

    func testOptionalSequence() throws {
        struct Test {
            let string: String?
        }
        let template = try MustacheTemplate(string: "test {{#.}}{{string}}{{/.}}")
        XCTAssertEqual(template.render([Test(string: "string")]), "test string")
    }

    func testOptionalSequenceSection() throws {
        struct Test {
            let string: String?
        }
        let template = try MustacheTemplate(string: "test {{#.}}{{#string}}*{{.}}{{/string}}{{/.}}")
        XCTAssertEqual(template.render([Test(string: "string")]), "test *string")
    }

    func testStructureInStructure() throws {
        struct SubTest {
            let string: String?
        }
        struct Test {
            let test: SubTest
        }

        let template = try MustacheTemplate(string: "test {{test.string}}")
        XCTAssertEqual(template.render(Test(test: .init(string: "sub"))), "test sub")
    }

    func testTextEscaping() throws {
        let template1 = try MustacheTemplate(string: "{{% CONTENT_TYPE:TEXT}}{{.}}")
        XCTAssertEqual(template1.render("<>"), "<>")
        let template2 = try MustacheTemplate(string: "{{% CONTENT_TYPE:HTML}}{{.}}")
        XCTAssertEqual(template2.render("<>"), "&lt;&gt;")
    }

    func testStopClimbingStack() throws {
        let template1 = try MustacheTemplate(string: "{{#test}}{{name}}{{/test}}")
        let template2 = try MustacheTemplate(string: "{{#test}}{{.name}}{{/test}}")
        let object: [String: Any] = ["test": [:], "name": "John"]
        let object2: [String: Any] = ["test": ["name": "Jane"], "name": "John"]
        XCTAssertEqual(template1.render(object), "John")
        XCTAssertEqual(template2.render(object), "")
        XCTAssertEqual(template2.render(object2), "Jane")
    }

    /// variables
    func testMustacheManualVariables() throws {
        let template = try MustacheTemplate(
            string: """
                Hello {{name}}
                You have just won {{value}} dollars!
                {{#in_ca}}
                Well, {{taxed_value}} dollars, after taxes.
                {{/in_ca}}
                """
        )
        let object: [String: Any] = ["name": "Chris", "value": 10000, "taxed_value": 10000 - (10000 * 0.4), "in_ca": true]
        XCTAssertEqual(
            template.render(object),
            """
            Hello Chris
            You have just won 10000 dollars!
            Well, 6000.0 dollars, after taxes.

            """
        )
    }

    /// test escaped and unescaped text
    func testMustacheManualEscapedText() throws {
        let template = try MustacheTemplate(
            string: """
                *{{name}}
                *{{age}}
                *{{company}}
                *{{{company}}}
                """
        )
        let object: [String: Any] = ["name": "Chris", "company": "<b>GitHub</b>"]
        XCTAssertEqual(
            template.render(object),
            """
            *Chris
            *
            *&lt;b&gt;GitHub&lt;/b&gt;
            *<b>GitHub</b>
            """
        )
    }

    /// test dotted names
    func test_MustacheManualDottedNames() throws {
        let template = try MustacheTemplate(
            string: """
                * {{client.name}}
                * {{age}}
                * {{client.company.name}}
                * {{{company.name}}}
                """
        )
        let object: [String: Any] = [
            "client": (
                name: "Chris & Friends",
                age: 50
            ),
            "company": [
                "name": "<b>GitHub</b>"
            ],
        ]
        XCTAssertEqual(
            template.render(object),
            """
            * Chris &amp; Friends
            * 
            * 
            * <b>GitHub</b>
            """
        )
    }

    /// test implicit operator
    func testMustacheManualImplicitOperator() throws {
        let template = try MustacheTemplate(
            string: """
                * {{.}}
                """
        )
        let object = "Hello!"
        XCTAssertEqual(
            template.render(object),
            """
            * Hello!
            """
        )
    }

    /// test lambda
    func test_MustacheManualLambda() throws {
        let template = try MustacheTemplate(
            string: """
                * {{time.hour}}
                * {{today}}
                """
        )
        let object: [String: Any] = [
            "year": 1970,
            "month": 1,
            "day": 1,
            "time": MustacheLambda { _ in
                (
                    hour: 0,
                    minute: 0,
                    second: 0
                )
            },
            "today": MustacheLambda { _ in
                "{{year}}-{{month}}-{{day}}"
            },
        ]
        XCTAssertEqual(
            template.render(object),
            """
            * 0
            * 1970-1-1
            """
        )
    }

    /// test boolean
    func testMustacheManualSectionFalse() throws {
        let template = try MustacheTemplate(
            string: """
                Shown.
                {{#person}}
                  Never shown!
                {{/person}}
                """
        )
        let object: [String: Any] = ["person": false]
        XCTAssertEqual(
            template.render(object),
            """
            Shown.

            """
        )
    }

    /// test non-empty lists
    func testMustacheManualSectionList() throws {
        let template = try MustacheTemplate(
            string: """
                {{#repo}}
                  <b>{{name}}</b>
                {{/repo}}
                """
        )
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        XCTAssertEqual(
            template.render(object),
            """
              <b>resque</b>
              <b>hub</b>
              <b>rip</b>

            """
        )
    }

    /// test non-empty lists
    func testMustacheManualSectionList2() throws {
        let template = try MustacheTemplate(
            string: """
                {{#repo}}
                  <b>{{.}}</b>
                {{/repo}}
                """
        )
        let object: [String: Any] = ["repo": ["resque", "hub", "rip"]]
        XCTAssertEqual(
            template.render(object),
            """
              <b>resque</b>
              <b>hub</b>
              <b>rip</b>

            """
        )
    }

    /// test lambdas
    func testMustacheManualSectionLambda() throws {
        let template = try MustacheTemplate(
            string: """
                {{#wrapped}}{{name}} is awesome.{{/wrapped}}
                """
        )
        func wrapped(_ s: String) -> Any? {
            "<b>\(s)</b>"
        }
        let object: [String: Any] = ["name": "Willy", "wrapped": MustacheLambda(wrapped)]
        XCTAssertEqual(
            template.render(object),
            """
            <b>Willy is awesome.</b>
            """
        )
    }

    /// test setting context object
    func testMustacheManualContextObject() throws {
        let template = try MustacheTemplate(
            string: """
                {{#person?}}
                  Hi {{name}}!
                {{/person?}}
                """
        )
        let object: [String: Any] = ["person?": ["name": "Jon"]]
        XCTAssertEqual(
            template.render(object),
            """
              Hi Jon!

            """
        )
    }

    /// test inverted sections
    func testMustacheManualInvertedSection() throws {
        let template = try MustacheTemplate(
            string: """
                {{#repo}}
                  <b>{{name}}</b>
                {{/repo}}
                {{^repo}}
                  No repos :(
                {{/repo}}
                """
        )
        let object: [String: Any] = ["repo": []]
        XCTAssertEqual(
            template.render(object),
            """
              No repos :(

            """
        )
    }

    /// test comments
    func testMustacheManualComment() throws {
        let template = try MustacheTemplate(
            string: """
                <h1>Today{{! ignore me }}.</h1>
                """
        )
        let object: [String: Any] = ["repo": []]
        XCTAssertEqual(
            template.render(object),
            """
            <h1>Today.</h1>
            """
        )
    }

    /// test dynamic names
    func testMustacheManualDynamicNames() throws {
        var library = MustacheLibrary()
        try library.register(
            "Hello {{>*dynamic}}",
            named: "main"
        )
        try library.register(
            "everyone!",
            named: "world"
        )
        let object = ["dynamic": "world"]
        XCTAssertEqual(library.render(object, withTemplate: "main"), "Hello everyone!")
    }

    /// test block with defaults
    func testMustacheManualBlocksWithDefaults() throws {
        let template = try MustacheTemplate(
            string: """
                <h1>{{$title}}The News of Today{{/title}}</h1>
                {{$body}}
                <p>Nothing special happened.</p>
                {{/body}}

                """
        )
        XCTAssertEqual(
            template.render([]),
            """
            <h1>The News of Today</h1>
            <p>Nothing special happened.</p>

            """
        )
    }

    func testMustacheManualParents() throws {
        var library = MustacheLibrary()
        try library.register(
            """
            {{<article}}
            Never shown
            {{$body}}
                {{#headlines}}
                <p>{{.}}</p>
                {{/headlines}}
            {{/body}}
            {{/article}}

            {{<article}}
            {{$title}}Yesterday{{/title}}
            {{/article}}

            """,
            named: "main"
        )
        try library.register(
            """
            <h1>{{$title}}The News of Today{{/title}}</h1>
            {{$body}}
            <p>Nothing special happened.</p>
            {{/body}}

            """,
            named: "article"
        )
        let object = [
            "headlines": [
                "A pug's handler grew mustaches.",
                "What an exciting day!",
            ]
        ]
        XCTAssertEqual(
            library.render(object, withTemplate: "main"),
            """
            <h1>The News of Today</h1>
            <p>A pug&#39;s handler grew mustaches.</p>
            <p>What an exciting day!</p>

            <h1>Yesterday</h1>
            <p>Nothing special happened.</p>

            """
        )
    }

    func testMustacheManualDynamicNameParents() throws {
        var library = MustacheLibrary()
        try library.register(
            """
            {{<*dynamic}}
              {{$text}}Hello World!{{/text}}
            {{/*dynamic}}

            """,
            named: "dynamic"
        )
        try library.register(
            """
            {{$text}}Here goes nothing.{{/text}}
            """,
            named: "normal"
        )
        try library.register(
            """
            <b>{{$text}}Here also goes nothing but it's bold.{{/text}}</b>
            """,
            named: "bold"
        )
        let object = ["dynamic": "bold"]
        XCTAssertEqual(
            library.render(object, withTemplate: "dynamic"),
            """
            <b>Hello World!</b>
            """
        )
    }

    /// test MustacheCustomRenderable
    func testCustomRenderable() throws {
        let template = try MustacheTemplate(string: "{{.}}")
        let template1 = try MustacheTemplate(string: "{{#.}}not null{{/.}}")
        let template2 = try MustacheTemplate(string: "{{^.}}null{{/.}}")
        struct Object: MustacheCustomRenderable {
            let value: String

            var renderText: String { self.value.uppercased() }
            var isNull: Bool { self.value == "null" }
        }
        let testObject = Object(value: "test")
        let nullObject = Object(value: "null")
        XCTAssertEqual(template.render(testObject), "TEST")
        XCTAssertEqual(template1.render(testObject), "not null")
        XCTAssertEqual(template1.render(nullObject), "")
        XCTAssertEqual(template2.render(testObject), "")
        XCTAssertEqual(template2.render(nullObject), "null")
    }

    func testTypeErasedOptionalContext() throws {
        let object = ["name": "Test" as Any?]

        let template = try MustacheTemplate(string: "{{name}}")
        let result = template.render(object)

        XCTAssertEqual(result, "Test")
    }

    func testPerformance() throws {
        let template = try MustacheTemplate(
            string: """
                {{#repo}}
                  <b>{{name}}</b>
                {{/repo}}
                """
        )
        let object: [String: Any] = ["repo": [["name": "resque"], ["name": "hub"], ["name": "rip"]]]
        let date = Date()
        for _ in 1...10000 {
            _ = template.render(object)
        }
        print(-date.timeIntervalSinceNow)
    }
}
