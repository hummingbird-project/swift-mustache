@testable import HummingbirdMustache
import XCTest

final class TemplateParserTests: XCTestCase {
    func testText() throws {
        let template = try HBMustacheTemplate(string: "test template")
        XCTAssertEqual(template.tokens, [.text("test template")])
    }

    func testVariable() throws {
        let template = try HBMustacheTemplate(string: "test {{variable}}")
        XCTAssertEqual(template.tokens, [.text("test "), .variable(name: "variable")])
    }

    func testSection() throws {
        let template = try HBMustacheTemplate(string: "test {{#section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .section(name: "section", template: .init([.text("text")]))])
    }

    func testInvertedSection() throws {
        let template = try HBMustacheTemplate(string: "test {{^section}}text{{/section}}")
        XCTAssertEqual(template.tokens, [.text("test "), .invertedSection(name: "section", template: .init([.text("text")]))])
    }

    func testComment() throws {
        let template = try HBMustacheTemplate(string: "test {{!section}}")
        XCTAssertEqual(template.tokens, [.text("test ")])
    }

    func testWhitespace() throws {
        let template = try HBMustacheTemplate(string: "{{ section }}")
        XCTAssertEqual(template.tokens, [.variable(name: "section")])
    }

    func testSectionEndError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{#section}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.expectedSectionEnd:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }

    func testSectionCloseNameIncorrectError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{#section}}{{/error}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.sectionCloseNameIncorrect:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }

    func testUnmatchedNameError() throws {
        XCTAssertThrowsError(_ = try HBMustacheTemplate(string: "test {{section#}}")) { error in
            switch error {
            case HBMustacheTemplate.Error.unfinishedName:
                break
            default:
                XCTFail("\(error)")
            }
        }
    }
}

extension HBMustacheTemplate: Equatable {
    public static func == (lhs: HBMustacheTemplate, rhs: HBMustacheTemplate) -> Bool {
        lhs.tokens == rhs.tokens
    }
}

extension HBMustacheTemplate.Token: Equatable {
    public static func == (lhs: HBMustacheTemplate.Token, rhs: HBMustacheTemplate.Token) -> Bool {
        switch (lhs, rhs) {
        case let (.text(lhs), .text(rhs)):
            return lhs == rhs
        case let (.variable(lhs, lhs2), .variable(rhs, rhs2)):
            return lhs == rhs && lhs2 == rhs2
        case let (.section(lhs1, lhs2, lhs3), .section(rhs1, rhs2, rhs3)):
            return lhs1 == rhs1 && lhs2 == rhs2 && lhs3 == rhs3
        case let (.invertedSection(lhs1, lhs2, lhs3), .invertedSection(rhs1, rhs2, rhs3)):
            return lhs1 == rhs1 && lhs2 == rhs2 && lhs3 == rhs3
        case let (.partial(name1), .partial(name2)):
            return name1 == name2
        default:
            return false
        }
    }
}
