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

/// Objects that can have a transforms run on them. Mustache transforms are specific to this implementation
/// of Mustache. They allow you to process objects before they are rendered.
///
/// The syntax for applying transforms is `{{transform(variable)}}`. Transforms can be applied to both
/// variables, sections and inverted sections.
///
/// A simple example would be ensuring a string is lowercase.
/// ```
/// {{lowercased(myString)}}
/// ```
/// If applying a transform to a sequence then the closing element of the sequence should include the
/// transform name eg
/// ```
/// {{#reversed(sequence)}}{{.}}{{\reversed(sequence)}}
/// ```
public protocol MustacheTransformable {
    func transform(_ name: String) -> Any?
}

public extension StringProtocol {
    /// Transform String/Substring
    ///
    /// Transforms available are `capitalized`, `lowercased`, `uppercased` and `reversed`
    /// - Parameter name: transform name
    /// - Returns: Result
    func transform(_ name: String) -> Any? {
        switch name {
        case "empty":
            return isEmpty
        case "capitalized":
            return capitalized
        case "lowercased":
            return lowercased()
        case "uppercased":
            return uppercased()
        case "reversed":
            return Substring(self.reversed())
        default:
            return nil
        }
    }
}

extension String: MustacheTransformable {}
extension Substring: MustacheTransformable {}

/// Protocol for sequence that can be sorted
private protocol ComparableSequence {
    func comparableTransform(_ name: String) -> Any?
}

extension Array: MustacheTransformable {
    /// Transform Array.
    ///
    /// Transforms available are `first`, `last`, `reversed`, `count`, `empty` and for arrays
    /// with comparable elements `sorted`.
    /// - Parameter name: transform name
    /// - Returns: Result
    public func transform(_ name: String) -> Any? {
        switch name {
        case "first":
            return first
        case "last":
            return last
        case "reversed":
            return reversed()
        case "count":
            return count
        case "empty":
            return isEmpty
        default:
            if let comparableSeq = self as? ComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension Array: ComparableSequence where Element: Comparable {
    func comparableTransform(_ name: String) -> Any? {
        switch name {
        case "sorted":
            return sorted()
        default:
            return nil
        }
    }
}

extension Set: MustacheTransformable {
    /// Transform Set.
    ///
    /// Transforms available are `count`, `empty` and for sets
    /// with comparable elements `sorted`.
    /// - Parameter name: transform name
    /// - Returns: Result
    public func transform(_ name: String) -> Any? {
        switch name {
        case "count":
            return count
        case "empty":
            return isEmpty
        default:
            if let comparableSeq = self as? ComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension Set: ComparableSequence where Element: Comparable {
    func comparableTransform(_ name: String) -> Any? {
        switch name {
        case "sorted":
            return sorted()
        default:
            return nil
        }
    }
}

extension ReversedCollection: MustacheTransformable {
    /// Transform ReversedCollection.
    ///
    /// Transforms available are `first`, `last`, `reversed`, `count`, `empty` and for collections
    /// with comparable elements `sorted`.
    /// - Parameter name: transform name
    /// - Returns: Result
    public func transform(_ name: String) -> Any? {
        switch name {
        case "first":
            return first
        case "last":
            return last
        case "reversed":
            return reversed()
        case "count":
            return count
        case "empty":
            return isEmpty
        default:
            if let comparableSeq = self as? ComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension ReversedCollection: ComparableSequence where Element: Comparable {
    func comparableTransform(_ name: String) -> Any? {
        switch name {
        case "sorted":
            return sorted()
        default:
            return nil
        }
    }
}

extension Dictionary: MustacheTransformable {
    /// Transform Dictionary
    ///
    /// Transforms available are `count`, `enumerated` and for dictionaries
    /// with comparable keys `sorted`.
    /// - Parameter name: transform name
    /// - Returns: Result
    public func transform(_ name: String) -> Any? {
        switch name {
        case "count":
            return count
        case "empty":
            return isEmpty
        case "enumerated":
            return map { (key: $0.key, value: $0.value) }
        default:
            if let comparableSeq = self as? ComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension Dictionary: ComparableSequence where Key: Comparable {
    func comparableTransform(_ name: String) -> Any? {
        switch name {
        case "sorted":
            return map { (key: $0.key, value: $0.value) }.sorted { $0.key < $1.key }
        default:
            return nil
        }
    }
}

public extension FixedWidthInteger {
    /// Transform FixedWidthInteger
    ///
    /// Transforms available are `plusone`, `minusone`, `odd`, `even`
    /// - Parameter name: transform name
    /// - Returns: Result
    func transform(_ name: String) -> Any? {
        switch name {
        case "equalzero":
            return self == 0
        case "plusone":
            return self + 1
        case "minusone":
            return self - 1
        case "even":
            return (self & 1) == 0
        case "odd":
            return (self & 1) == 1
        default:
            return nil
        }
    }
}

extension Int: MustacheTransformable {}
extension Int8: MustacheTransformable {}
extension Int16: MustacheTransformable {}
extension Int32: MustacheTransformable {}
extension Int64: MustacheTransformable {}
extension UInt: MustacheTransformable {}
extension UInt8: MustacheTransformable {}
extension UInt16: MustacheTransformable {}
extension UInt32: MustacheTransformable {}
extension UInt64: MustacheTransformable {}
