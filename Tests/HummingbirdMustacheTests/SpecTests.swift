import HummingbirdMustache
import XCTest

/// Mustache spec tests. These are the formal standard for Mustache. More details
/// can be found at https://github.com/mustache/spec

func test(_ object: Any, _ template: String, _ expected: String) throws {
    let template = try HBMustacheTemplate(string: template)
    let result = template.render(object)
    XCTAssertEqual(result, expected)
}

// MARK: Comments

final class SpecCommentsTests: XCTestCase {
    func testInline() throws {
        let object = {}
        let template = "12345{{! Comment Block! }}67890"
        let expected = "1234567890"
        try test(object, template, expected)
    }

    func testMultiline() throws {
        let object = {}
        let template = """
        12345{{!
                This is a
                multi-line comment...
              }}67890
        """
        let expected = "1234567890"
        try test(object, template, expected)
    }

    func testStandalone() throws {
        let object = {}
        let template = """
        Begin.
        {{! Comment Block! }}
        End.
        """
        let expected = """
        Begin.
        End.
        """
        try test(object, template, expected)
    }

    func testIndentedStandalone() throws {
        let object = {}
        let template = """
        Begin.
          {{! Comment Block! }}
        End.
        """
        let expected = """
        Begin.
        End.
        """
        try test(object, template, expected)
    }

    func testStandaloneLineEndings() throws {
        let object = {}
        let template = "\r\n{{! Standalone Comment }}\r\n"
        let expected = "\r\n"
        try test(object, template, expected)
    }

    func testStandaloneWithoutPreviousLine() throws {
        let object = {}
        let template = "  {{! I'm Still Standalone }}\n!"
        let expected = "!"
        try test(object, template, expected)
    }

    func testStandaloneWithoutNewLine() throws {
        let object = {}
        let template = "!\n  {{! I'm Still Standalone }}"
        let expected = "!\n"
        try test(object, template, expected)
    }

    func testStandaloneMultiLine() throws {
        let object = {}
        let template = """
        Begin.
          {{!
            Something's going on here...
          }}
        End.
        """
        let expected = """
        Begin.
        End.
        """
        try test(object, template, expected)
    }

    func testIndentedInline() throws {
        let object = {}
        let template = "  12 {{! 34 }}\n"
        let expected = "  12 \n"
        try test(object, template, expected)
    }

    func testSurroundingWhitespace() throws {
        let object = {}
        let template = "12345 {{! Comment Block! }} 67890"
        let expected = "12345  67890"
        try test(object, template, expected)
    }
}

// MARK: Interpolation

final class SpecInterpolationTests: XCTestCase {
    func testNoInterpolation() throws {
        let object = {}
        let template = "Hello from {Mustache}!"
        let expected = "Hello from {Mustache}!"
        try test(object, template, expected)
    }

    func testBasicInterpolation() throws {
        let object = ["subject": "world"]
        let template = "Hello, {{subject}}!"
        let expected = "Hello, world!"
        try test(object, template, expected)
    }

    func testHTMLEscaping() throws {
        let object = ["forbidden": #"& " < >"#]
        let template = "These characters should be HTML escaped: {{forbidden}}"
        let expected = #"These characters should be HTML escaped: &amp; &quot; &lt; &gt;"#
        try test(object, template, expected)
    }

    func testTripleMustache() throws {
        let object = ["forbidden": #"& " < >"#]
        let template = "These characters should not be HTML escaped: {{{forbidden}}}"
        let expected = #"These characters should not be HTML escaped: & " < >"#
        try test(object, template, expected)
    }

    func testAmpersand() throws {
        let object = ["forbidden": #"& " < >"#]
        let template = "These characters should not be HTML escaped: {{&forbidden}}"
        let expected = #"These characters should not be HTML escaped: & " < >"#
        try test(object, template, expected)
    }

    func testBasicInteger() throws {
        let object = ["mph": 85]
        let template = #""{{mph}} miles an hour!""#
        let expected = #""85 miles an hour!""#
        try test(object, template, expected)
    }

    func testTripleMustacheInteger() throws {
        let object = ["mph": 85]
        let template = #""{{{mph}}} miles an hour!""#
        let expected = #""85 miles an hour!""#
        try test(object, template, expected)
    }

    func testBasicDecimal() throws {
        let object = ["power": 1.210]
        let template = #""{{power}} jiggawatts!""#
        let expected = #""1.21 jiggawatts!""#
        try test(object, template, expected)
    }

    func testTripleMustacheDecimal() throws {
        let object = ["power": 1.210]
        let template = #""{{{power}}} jiggawatts!""#
        let expected = #""1.21 jiggawatts!""#
        try test(object, template, expected)
    }

    func testAmpersandDecimal() throws {
        let object = ["power": 1.210]
        let template = #""{{&power}} jiggawatts!""#
        let expected = #""1.21 jiggawatts!""#
        try test(object, template, expected)
    }

    func testContextMiss() throws {
        let object = {}
        let template = #"I ({{cannot}}) be seen!"#
        let expected = #"I () be seen!"#
        try test(object, template, expected)
    }

    func testTripleMustacheContextMiss() throws {
        let object = {}
        let template = #"I ({{{cannot}}}) be seen!"#
        let expected = #"I () be seen!"#
        try test(object, template, expected)
    }

    func testAmpersandContextMiss() throws {
        let object = {}
        let template = #"I ({{&cannot}}) be seen!"#
        let expected = #"I () be seen!"#
        try test(object, template, expected)
    }

    func testDottedName() throws {
        let object = ["person": ["name": "Joe"]]
        let template = #""{{person.name}}" == "{{#person}}{{name}}{{/person}}""#
        let expected = #""Joe" == "Joe""#
        try test(object, template, expected)
    }

    func testTripleMustacheDottedName() throws {
        let object = ["person": ["name": "Joe"]]
        let template = #""{{{person.name}}}" == "{{#person}}{{name}}{{/person}}""#
        let expected = #""Joe" == "Joe""#
        try test(object, template, expected)
    }

    func testAmpersandDottedName() throws {
        let object = ["person": ["name": "Joe"]]
        let template = #""{{&person.name}}" == "{{#person}}{{name}}{{/person}}""#
        let expected = #""Joe" == "Joe""#
        try test(object, template, expected)
    }

    func testArbituaryDepthDottedName() throws {
        let object = ["a": ["b": ["c": ["d": ["e": ["name": "Phil"]]]]]]
        let template = #""{{a.b.c.d.e.name}}" == "Phil""#
        let expected = #""Phil" == "Phil""#
        try test(object, template, expected)
    }

    func testBrokenChainDottedName() throws {
        let object = ["a": ["b": []], "c": ["name": "Jim"]]
        let template = #""{{a.b.c.name}}" == """#
        let expected = "\"\" == \"\""
        try test(object, template, expected)
    }

    func testInitialResolutionDottedName() throws {
        let object = [
            "a": ["b": ["c": ["d": ["e": ["name": "Phil"]]]]],
            "b": ["c": ["d": ["e": ["name": "Wrong"]]]],
        ]
        let template = #""{{#a}}{{b.c.d.e.name}}{{/a}}" == "Phil""#
        let expected = #""Phil" == "Phil""#
        try test(object, template, expected)
    }

    func testContextPrecedenceDottedName() throws {
        let object = [
            "a": ["b": []],
            "b": ["c": "Error"],
        ]
        let template = #"{{#a}}{{b.c}}{{/a}}"#
        let expected = ""
        try test(object, template, expected)
    }

    func testSurroundingWhitespace() throws {
        let object = ["string": "---"]
        let template = "| {{string}} |"
        let expected = "| --- |"
        try test(object, template, expected)
    }

    func testTripleMustacheSurroundingWhitespace() throws {
        let object = ["string": "---"]
        let template = "| {{{string}}} |"
        let expected = "| --- |"
        try test(object, template, expected)
    }

    func testAmpersandSurroundingWhitespace() throws {
        let object = ["string": "---"]
        let template = "| {{&string}} |"
        let expected = "| --- |"
        try test(object, template, expected)
    }

    func testInterpolationStandalone() throws {
        let object = ["string": "---"]
        let template = "  {{string}}\n"
        let expected = "  ---\n"
        try test(object, template, expected)
    }

    func testTripleMustacheStandalone() throws {
        let object = ["string": "---"]
        let template = "  {{{string}}}\n"
        let expected = "  ---\n"
        try test(object, template, expected)
    }

    func testAmpersandStandalone() throws {
        let object = ["string": "---"]
        let template = "  {{&string}}\n"
        let expected = "  ---\n"
        try test(object, template, expected)
    }

    func testInterpolationWithPadding() throws {
        let object = ["string": "---"]
        let template = "|{{ string }}|"
        let expected = "|---|"
        try test(object, template, expected)
    }

    func testTripleMustacheWithPadding() throws {
        let object = ["string": "---"]
        let template = "|{{{ string }}}|"
        let expected = "|---|"
        try test(object, template, expected)
    }

    func testAmpersandWithPadding() throws {
        let object = ["string": "---"]
        let template = "|{{& string }}|"
        let expected = "|---|"
        try test(object, template, expected)
    }
}

// MARK: Inverted

final class SpecInvertedTests: XCTestCase {
    func testFalse() throws {
        let object = ["boolean": false]
        let template = #""{{^boolean}}This should be rendered.{{/boolean}}""#
        let expected = #""This should be rendered.""#
        try test(object, template, expected)
    }

    func testTrue() throws {
        let object = ["boolean": true]
        let template = #""{{^boolean}}This should not be rendered.{{/boolean}}""#
        let expected = "\"\""
        try test(object, template, expected)
    }

    func testContext() throws {
        let object = ["context": ["name": "Joe"]]
        let template = #""{{^context}}Hi {{name}}.{{/context}}""#
        let expected = "\"\""
        try test(object, template, expected)
    }

    func testList() throws {
        let object = ["list": [["n": 1], ["n": 2], ["n": 3]]]
        let template = #""{{^list}}{{n}}{{/list}}""#
        let expected = "\"\""
        try test(object, template, expected)
    }

    func testEmptyList() throws {
        let object = ["list": []]
        let template = #""{{^list}}Yay lists!{{/list}}""#
        let expected = #""Yay lists!""#
        try test(object, template, expected)
    }

    func testDoubled() throws {
        let object: [String: Any] = ["bool": false, "two": "second"]
        let template = """
        {{^bool}}
        * first
        {{/bool}}
        * {{two}}
        {{^bool}}
        * third
        {{/bool}}
        """
        let expected = """
        * first
        * second
        * third

        """
        try test(object, template, expected)
    }

    func testNestedFalse() throws {
        let object = ["bool": false]
        let template = #"| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"#
        let expected = #"| A B C D E |"#
        try test(object, template, expected)
    }

    func testNestedTrue() throws {
        let object = ["bool": true]
        let template = #"| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"#
        let expected = #"| A  E |"#
        try test(object, template, expected)
    }

    func testContextMiss() throws {
        let object = {}
        let template = #"[{{^missing}}Cannot find key 'missing'!{{/missing}}]"#
        let expected = #"[Cannot find key 'missing'!]"#
        try test(object, template, expected)
    }

    func testDottedNamesTrue() throws {
        let object = ["a": ["b": ["c": true]]]
        let template = #""{{^a.b.c}}Not Here{{/a.b.c}}" == """#
        let expected = "\"\" == \"\""
        try test(object, template, expected)
    }

    func testDottedNamesFalse() throws {
        let object = ["a": ["b": ["c": false]]]
        let template = #""{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here""#
        let expected = #""Not Here" == "Not Here""#
        try test(object, template, expected)
    }

    func testDottedNamesBrokenChain() throws {
        let object = ["a": {}]
        let template = #""{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here""#
        let expected = #""Not Here" == "Not Here""#
        try test(object, template, expected)
    }

    func testSurroundingWhitespace() throws {
        let object = ["boolean": false]
        let template = " | {{^boolean}}\t|\t{{/boolean}} | \n"
        let expected = " | \t|\t | \n"
        try test(object, template, expected)
    }

    func testInternalWhitespace() throws {
        let object = ["boolean": false]
        let template = " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
        let expected = " |  \n  | \n"
        try test(object, template, expected)
    }

    func testIndentedInline() throws {
        let object = ["boolean": false]
        let template = " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
        let expected = " NO\n WAY\n"
        try test(object, template, expected)
    }

    func testStandaloneLines() throws {
        let object = ["boolean": false]
        let template = """
        | This Is
        {{^boolean}}
        |
        {{/boolean}}
        | A Line
        """
        let expected = """
        | This Is
        |
        | A Line
        """
        try test(object, template, expected)
    }

    func testStandaloneIndentedLines() throws {
        let object = ["boolean": false]
        let template = """
        | This Is
          {{^boolean}}
        |
          {{/boolean}}
        | A Line
        """
        let expected = """
        | This Is
        |
        | A Line
        """
        try test(object, template, expected)
    }

    func testStandaloneLineEndings() throws {
        let object = ["boolean": false]
        let template = "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
        let expected = "|\r\n|"
        try test(object, template, expected)
    }

    func testStandaloneWithoutPreviousLine() throws {
        let object = ["boolean": false]
        let template = "  {{^boolean}}\n^{{/boolean}}\n/"
        let expected = "^\n/"
        try test(object, template, expected)
    }

    func testStandaloneWithoutNewLine() throws {
        let object = ["boolean": false]
        let template = "^{{^boolean}}\n/\n  {{/boolean}}"
        let expected = "^\n/\n"
        try test(object, template, expected)
    }

    func testPadding() throws {
        let object = ["boolean": false]
        let template = "|{{^ boolean }}={{/ boolean }}|"
        let expected = "|=|"
        try test(object, template, expected)
    }
}

// MARK: Partials

final class SpecPartialsTests: XCTestCase {
    func testPartial(_ object: Any, _ template: String, _ partials: [String: String], _ expected: String) throws {
        let library = HBMustacheLibrary()
        let template = try HBMustacheTemplate(string: template)
        library.register(template, named: "template")
        for (key, value) in partials {
            let template = try HBMustacheTemplate(string: value)
            library.register(template, named: key)
        }
        let result = library.render(object, withTemplate: "template")
        XCTAssertEqual(result, expected)
    }

    func testBasic() throws {
        let object = {}
        let template = #""{{>text}}""#
        let partial = "from partial"
        let expected = #""from partial""#
        try testPartial(object, template, ["text": partial], expected)
    }

    func testFailedLookup() throws {
        let object = {}
        let template = #""{{>text}}""#
        let expected = "\"\""
        try testPartial(object, template, [:], expected)
    }

    func testContext() throws {
        let object = ["text": "content"]
        let template = #""{{>partial}}""#
        let partial = "*{{text}}*"
        let expected = #""*content*""#
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testRecursion() throws {
        let object: [String: Any] = ["content": "X", "nodes": [["content": "Y", "nodes": []]]]
        let template = #"{{>node}}"#
        let partial = "{{content}}<{{#nodes}}{{>node}}{{/nodes}}>"
        let expected = #"X<Y<>>"#
        try testPartial(object, template, ["node": partial], expected)
    }

    func testSurroundingWhitespace() throws {
        let object = {}
        let template = "| {{>partial}} |"
        let partial = "\t|\t"
        let expected = "| \t|\t |"
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testInlineIdention() throws {
        let object = ["data": "|"]
        let template = "  {{data}}  {{> partial}}\n"
        let partial = ">\n>"
        let expected = "  |  >\n>\n"
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testStandaloneLineEndings() throws {
        let object = {}
        let template = "|\r\n{{>partial}}\r\n|"
        let partial = ">"
        let expected = "|\r\n>|"
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testStandaloneWithoutPreviousLine() throws {
        let object = {}
        let template = "  {{>partial}}\n>"
        let partial = ">\n>"
        let expected = "  >\n  >>"
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testStandaloneWithoutNewLine() throws {
        let object = {}
        let template = ">\n  {{>partial}}"
        let partial = ">\n>"
        let expected = ">\n  >\n  >"
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testStandaloneIndentation() throws {
        let object = ["content": "<\n->"]
        let template = """
        \
         {{>partial}}
        /
        """
        let partial = """
        |
        {{{content}}}
        |

        """
        let expected = """
        \
         |
         <
        ->
         |
        /
        """
        try testPartial(object, template, ["partial": partial], expected)
    }

    func testPaddingWhitespace() throws {
        let object = ["boolean": true]
        let template = "|{{> partial }}|"
        let partial = "[]"
        let expected = "|[]|"
        try testPartial(object, template, ["partial": partial], expected)
    }
}

// MARK: Sections

final class SpecSectionTests: XCTestCase {
    func testTrue() throws {
        let object = ["boolean": true]
        let template = #""{{#boolean}}This should be rendered.{{/boolean}}""#
        let expected = #""This should be rendered.""#
        try test(object, template, expected)
    }

    func testFalse() throws {
        let object = ["boolean": false]
        let template = #""{{#boolean}}This should not be rendered.{{/boolean}}""#
        let expected = "\"\""
        try test(object, template, expected)
    }

    func testContext() throws {
        let object = ["context": ["name": "Joe"]]
        let template = #""{{#context}}Hi {{name}}.{{/context}}""#
        let expected = #""Hi Joe.""#
        try test(object, template, expected)
    }

    func testParentContext() throws {
        let object: [String: Any] = ["a": "foo", "b": "wrong", "sec": ["b": "bar"], "c": ["d": "baz"]]
        let template = #""{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}""#
        let expected = #""foo, bar, baz""#
        try test(object, template, expected)
    }

    func testVariables() throws {
        let object: [String: Any] = ["foo": "bar"]
        let template = #""{{#foo}}{{.}} is {{foo}}{{/foo}}""#
        let expected = #""bar is bar""#
        try test(object, template, expected)
    }

    func testListContexts() throws {
        let object: [String: Any] = ["tops": ["tname": ["upper": "A", "lower": "a"], "middles": ["mname": "1", "bottoms": [["bname": "x"], ["bname": "y"]]]]]
        let template = #"{{#tops}}{{#middles}}{{tname.lower}}{{mname}}.{{#bottoms}}{{tname.upper}}{{mname}}{{bname}}.{{/bottoms}}{{/middles}}{{/tops}}"#
        let expected = #"a1.A1x.A1y."#
        try test(object, template, expected)
    }

    func testDeeplyNestedContexts() throws {
        let object: [String: Any] = ["a": ["one": 1], "b": ["two": 2], "c": ["three": 3, "d": ["four": 4, "five": 5]]]
        let template = """
        {{#a}}
        {{one}}
        {{#b}}
        {{one}}{{two}}{{one}}
        {{#c}}
        {{one}}{{two}}{{three}}{{two}}{{one}}
        {{#d}}
        {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
        {{#five}}
        {{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
        {{one}}{{two}}{{three}}{{four}}{{.}}6{{.}}{{four}}{{three}}{{two}}{{one}}
        {{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
        {{/five}}
        {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
        {{/d}}
        {{one}}{{two}}{{three}}{{two}}{{one}}
        {{/c}}
        {{one}}{{two}}{{one}}
        {{/b}}
        {{one}}
        {{/a}}

        """
        let expected = """
        1
        121
        12321
        1234321
        123454321
        12345654321
        123454321
        1234321
        12321
        121
        1

        """
        try test(object, template, expected)
    }

    func testList() throws {
        let object: [String: Any] = ["list": [["item": 1], ["item": 2], ["item": 3]]]
        let template = #""{{#list}}{{item}}{{/list}}""#
        let expected = #""123""#
        try test(object, template, expected)
    }

    func testEmptyList() throws {
        let object: [Any] = []
        let template = #""{{#list}}Yay lists!{{/list}}""#
        let expected = "\"\""
        try test(object, template, expected)
    }

    func testDoubled() throws {
        let object: [String: Any] = ["bool": true, "two": "second"]
        let template = """
        {{#bool}}
        * first
        {{/bool}}
        * {{two}}
        {{#bool}}
        * third
        {{/bool}}

        """
        let expected = """
        * first
        * second
        * third

        """
        try test(object, template, expected)
    }

    func testNestedTrue() throws {
        let object = ["bool": true]
        let template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
        let expected = "| A B C D E |"
        try test(object, template, expected)
    }

    func testNestedFalse() throws {
        let object = ["bool": false]
        let template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
        let expected = "| A  E |"
        try test(object, template, expected)
    }

    func testContextMiss() throws {
        let object = {}
        let template = "[{{#missing}}Found key 'missing'!{{/missing}}]"
        let expected = "[]"
        try test(object, template, expected)
    }

    func testImplicitIteratorString() throws {
        let object = ["list": ["a", "b", "c", "d", "e"]]
        let template = #""{{#list}}({{.}}){{/list}}""#
        let expected = #""(a)(b)(c)(d)(e)""#
        try test(object, template, expected)
    }

    func testImplicitIteratorInteger() throws {
        let object = ["list": [1, 2, 3, 4, 5]]
        let template = #""{{#list}}({{.}}){{/list}}""#
        let expected = #""(1)(2)(3)(4)(5)""#
        try test(object, template, expected)
    }

    func testImplicitIteratorDecimal() throws {
        let object = ["list": [1.1, 2.2, 3.3, 4.4, 5.5]]
        let template = #""{{#list}}({{.}}){{/list}}""#
        let expected = #""(1.1)(2.2)(3.3)(4.4)(5.5)""#
        try test(object, template, expected)
    }

    func testImplicitIteratorArray() throws {
        let object: [String: Any] = ["list": [[1, 2, 3], ["a", "b", "c"]]]
        let template = #""{{#list}}({{#.}}{{.}}{{/.}}){{/list}}""#
        let expected = #""(123)(abc)""#
        try test(object, template, expected)
    }

    func testDottedNameTrue() throws {
        let object = ["a": ["b": ["c": true]]]
        let template = #""{{#a.b.c}}Here{{/a.b.c}}" == "Here""#
        let expected = #""Here" == "Here""#
        try test(object, template, expected)
    }

    func testDottedNameFalse() throws {
        let object = ["a": ["b": ["c": false]]]
        let template = #""{{#a.b.c}}Here{{/a.b.c}}" == """#
        let expected = "\"\" == \"\""
        try test(object, template, expected)
    }

    func testDottedNameBrokenChain() throws {
        let object = ["a": []]
        let template = #""{{#a.b.c}}Here{{/a.b.c}}" == """#
        let expected = "\"\" == \"\""
        try test(object, template, expected)
    }

    func testSurroundingWhitespace() throws {
        let object = ["boolean": true]
        let template = " | {{#boolean}}\t|\t{{/boolean}} | \n"
        let expected = " | \t|\t | \n"
        try test(object, template, expected)
    }

    func testInternalWhitespace() throws {
        let object = ["boolean": true]
        let template = " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
        let expected = " |  \n  | \n"
        try test(object, template, expected)
    }

    func testIndentedInline() throws {
        let object = ["boolean": true]
        let template = " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
        let expected = " YES\n GOOD\n"
        try test(object, template, expected)
    }

    func testStandaloneLines() throws {
        let object = ["boolean": true]
        let template = """
        | This Is
        {{#boolean}}
        |
        {{/boolean}}
        | A Line
        """
        let expected = """
        | This Is
        |
        | A Line
        """
        try test(object, template, expected)
    }

    func testIndentedStandaloneLines() throws {
        let object = ["boolean": true]
        let template = """
        | This Is
          {{#boolean}}
        |
          {{/boolean}}
        | A Line
        """
        let expected = """
        | This Is
        |
        | A Line
        """
        try test(object, template, expected)
    }

    func testStandaloneLineEndings() throws {
        let object = ["boolean": true]
        let template = "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
        let expected = "|\r\n|"
        try test(object, template, expected)
    }

    func testStandaloneWithoutPreviousLine() throws {
        let object = ["boolean": true]
        let template = "  {{#boolean}}\n#{{/boolean}}\n/"
        let expected = "#\n/"
        try test(object, template, expected)
    }

    func testStandaloneWithoutNewLine() throws {
        let object = ["boolean": true]
        let template = "#{{#boolean}}\n/\n  {{/boolean}}"
        let expected = "#\n/\n"
        try test(object, template, expected)
    }

    func testPadding() throws {
        let object = ["boolean": true]
        let template = "|{{# boolean }}={{/ boolean }}|"
        let expected = "|=|"
        try test(object, template, expected)
    }
}
