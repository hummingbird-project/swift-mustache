//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Mustache
import XCTest

final class TransformTests: XCTestCase {
    func testLowercased() throws {
        let template = try MustacheTemplate(string: """
        {{ lowercased(name) }}
        """)
        let object: [String: Any] = ["name": "Test"]
        XCTAssertEqual(template.render(object), "test")
    }

    func testUppercased() throws {
        let template = try MustacheTemplate(string: """
        {{ uppercased(name) }}
        """)
        let object: [String: Any] = ["name": "Test"]
        XCTAssertEqual(template.render(object), "TEST")
    }

    func testNewline() throws {
        let template = try MustacheTemplate(string: """
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
        let template = try MustacheTemplate(string: """
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
        let template = try MustacheTemplate(string: """
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

    /// Expected failure, but you're welcome to fix it if you find a way.
    /// Use the recursive-transforms syntax instead, like the next test below.
    func testNestedSequenceTransformDoesNotWork() throws {
        let template = try MustacheTemplate(string: """
        {{#repo}}
        {{#reversed(numbers)}}{{count(.)}}{{/reversed(numbers)}}
        {{/repo}}

        """)
        let object: [String: Any] = ["repo": ["numbers": [1, 2, 3]]]
        XCTAssertEqual(template.render(object), "\n")
    }

    func testDoubleSequenceTransformWorks() throws {
        let template = try MustacheTemplate(string: """
        {{#repo}}
        {{count(reversed(numbers))}}
        {{/repo}}

        """)
        let object: [String: Any] = ["repo": ["numbers": [1, 2, 3]]]
        XCTAssertEqual(template.render(object), """
        3

        """)
    }

    func testNestedTransformWorks() throws {
        let template = try MustacheTemplate(string: """
        {{#repo}}
        {{minusone(plusone(last(reversed(numbers))))}}
        {{/repo}}

        """)
        let object: [String: Any] = ["repo": ["numbers": [5, 4, 3]]]
        XCTAssertEqual(template.render(object), """
        5

        """)
    }

    func testDoubleTransformWorks() throws {
        let template = try MustacheTemplate(string: """
        {{#repo}}
        {{#uppercased(string)}}{{reversed(.)}}{{/uppercased(string)}}
        {{/repo}}

        """)
        let object: [String: Any] = ["repo": ["string": "a123a"]]
        XCTAssertEqual(template.render(object), """
        A321A

        """)
    }

    func testEvenOdd() throws {
        let template = try MustacheTemplate(string: """
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
        let template = try MustacheTemplate(string: """
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
        let template = try MustacheTemplate(string: """
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
        let template = try MustacheTemplate(string: """
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

    func testDictionaryEmpty() throws {
        let template = try MustacheTemplate(string: """
        {{#empty(array)}}Array{{/empty(array)}}{{#empty(dictionary)}}Dictionary{{/empty(dictionary)}}
        """)
        let object: [String: Any] = ["array": [], "dictionary": [:]]
        XCTAssertEqual(template.render(object), "ArrayDictionary")
    }

    func testListOutput() throws {
        let object = [1, 2, 3, 4]
        let template = try MustacheTemplate(string: "{{#.}}{{.}}{{^last()}}, {{/last()}}{{/.}}")
        XCTAssertEqual(template.render(object), "1, 2, 3, 4")
    }

    func testDictionaryEnumerated() throws {
        let template = try MustacheTemplate(string: """
        {{#enumerated(.)}}<b>{{ key }} = {{ value }}</b>{{/enumerated(.)}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2]
        let result = template.render(object)
        XCTAssertTrue(result == "<b>one = 1</b><b>two = 2</b>" || result == "<b>two = 2</b><b>one = 1</b>")
    }

    func testDictionarySortedByKey() throws {
        let template = try MustacheTemplate(string: """
        {{#sorted(.)}}<b>{{ key }} = {{ value }}</b>{{/sorted(.)}}
        """)
        let object: [String: Any] = ["one": 1, "two": 2, "three": 3]
        let result = template.render(object)
        XCTAssertEqual(result, "<b>one = 1</b><b>three = 3</b><b>two = 2</b>")
    }
}
