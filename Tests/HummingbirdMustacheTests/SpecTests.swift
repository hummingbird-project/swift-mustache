import HummingbirdMustache
import XCTest

/// Mustache spec tests. These are the formal standard for Mustache. More details
/// can be found at https://github.com/mustache/spec

func test(_ object: Any, _ template: String, _ expected: String) throws {
    let template = try HBMustacheTemplate(string: template)
    let result = template.render(object)
    XCTAssertEqual(result, expected)
}

//MARK: Comments

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

    func testIndentedInline()  throws {
        let object = {}
        let template = "  12 {{! 34 }}\n"
        let expected = "  12 \n"
        try test(object, template, expected)
    }

    func testSurroundingWhitespace()  throws {
        let object = {}
        let template = "12345 {{! Comment Block! }} 67890"
        let expected = "12345  67890"
        try test(object, template, expected)
    }
}
