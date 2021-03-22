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
public protocol HBMustacheTransformable {
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
        case "capitalized":
            return capitalized
        case "lowercased":
            return lowercased()
        case "uppercased":
            return uppercased()
        case "reversed":
            return reversed()
        default:
            return nil
        }
    }
}

extension String: HBMustacheTransformable {}
extension Substring: HBMustacheTransformable {}

/// Protocol for sequence that can be sorted
private protocol HBComparableSequence {
    func comparableTransform(_ name: String) -> Any?
}

extension Array: HBMustacheTransformable {
    /// Transform Array.
    ///
    /// Transforms available are `first`, `last`, `reversed`, `count` and for arrays
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
        default:
            if let comparableSeq = self as? HBComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension Array: HBComparableSequence where Element: Comparable {
    func comparableTransform(_ name: String) -> Any? {
        switch name {
        case "sorted":
            return sorted()
        default:
            return nil
        }
    }
}

extension Dictionary: HBMustacheTransformable {
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
        case "enumerated":
            return map { (key: $0.key, value: $0.value) }
        default:
            if let comparableSeq = self as? HBComparableSequence {
                return comparableSeq.comparableTransform(name)
            }
            return nil
        }
    }
}

extension Dictionary: HBComparableSequence where Key: Comparable {
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

extension Int: HBMustacheTransformable {}
extension Int8: HBMustacheTransformable {}
extension Int16: HBMustacheTransformable {}
extension Int32: HBMustacheTransformable {}
extension Int64: HBMustacheTransformable {}
extension UInt: HBMustacheTransformable {}
extension UInt8: HBMustacheTransformable {}
extension UInt16: HBMustacheTransformable {}
extension UInt32: HBMustacheTransformable {}
extension UInt64: HBMustacheTransformable {}
