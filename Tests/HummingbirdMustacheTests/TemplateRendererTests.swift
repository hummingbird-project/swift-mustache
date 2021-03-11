import XCTest
@testable import HummingbirdMustache

final class TemplateRendererTests: XCTestCase {
    func testText() throws {
        let template = try HBTemplate("test text")
        XCTAssertEqual(template.render("test"), "test text")
    }

    func testStringVariable() throws {
        let template = try HBTemplate("test {{.}}")
        XCTAssertEqual(template.render("text"), "test text")
    }

    func testIntegerVariable() throws {
        let template = try HBTemplate("test {{.}}")
        XCTAssertEqual(template.render(101), "test 101")
    }

    func testDictionary() throws {
        let template = try HBTemplate("test {{value}} {{bool}}")
        XCTAssertEqual(template.render(["value": "test2", "bool": true]), "test test2 true")
    }

    func testArraySection() throws {
        let template = try HBTemplate("test {{#value}}*{{.}}{{/value}}")
        XCTAssertEqual(template.render(["value": ["test2", "bool"]]), "test *test2*bool")
        XCTAssertEqual(template.render(["value": []]), "test ")
    }

    func testBooleanSection() throws {
        let template = try HBTemplate("test {{#.}}Yep{{/.}}")
        XCTAssertEqual(template.render(true), "test Yep")
        XCTAssertEqual(template.render(false), "test ")
    }

    func testIntegerSection() throws {
        let template = try HBTemplate("test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render(23), "test 23")
        XCTAssertEqual(template.render(0), "test ")
    }

    func testStringSection() throws {
        let template = try HBTemplate("test {{#.}}{{.}}{{/.}}")
        XCTAssertEqual(template.render("Hello"), "test Hello")
    }

    func testInvertedSection() throws {
        let template = try HBTemplate("test {{^.}}Inverted{{/.}}")
        XCTAssertEqual(template.render(true), "test ")
        XCTAssertEqual(template.render(false), "test Inverted")
    }

    func testMirror() throws {
        struct Test {
            let string: String
        }
        let template = try HBTemplate("test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
    }

    func testOptionalMirror() throws {
        struct Test {
            let string: String?
        }
        let template = try HBTemplate("test {{string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
    }
    
    func testOptionalSequence() throws {
        struct Test {
            let string: String?
        }
        let template = try HBTemplate("test {{#string}}*{{.}}{{/string}}")
        XCTAssertEqual(template.render(Test(string: "string")), "test *string")
        XCTAssertEqual(template.render(Test(string: nil)), "test ")
        let template2 = try HBTemplate("test {{^string}}*{{/string}}")
        XCTAssertEqual(template2.render(Test(string: "string")), "test ")
        XCTAssertEqual(template2.render(Test(string: nil)), "test *")
    }
    
    func testDictionarySequence() throws {
        let template = try HBTemplate("test {{#.}}{{value}}{{/.}}")
        XCTAssert(template.render(["one": 1, "two": 2]) == "test 12" ||
                    template.render(["one": 1, "two": 2]) == "test 21")
    }
    
    func testStructureInStructure() throws {
        struct SubTest {
            let string: String?
        }
        struct Test {
            let test: SubTest
        }

        let template = try HBTemplate("test {{test.string}}")
        XCTAssertEqual(template.render(Test(test: .init(string: "sub"))), "test sub")
    }
}
