
/// Protocol for objects that can be rendered as a sequence in Mustache
public protocol HBMustacheSequence {
    /// Render section using template
    func renderSection(with template: HBMustacheTemplate, stack: [Any]) -> String
    /// Render inverted section using template
    func renderInvertedSection(with template: HBMustacheTemplate, stack: [Any]) -> String
}

public extension Sequence {
    /// Render section using template
    func renderSection(with template: HBMustacheTemplate, stack: [Any]) -> String {
        var string = ""
        var context = HBMustacheContext(first: true)

        var iterator = makeIterator()
        guard var currentObject = iterator.next() else { return "" }

        while let object = iterator.next() {
            var stack = stack
            stack.append(currentObject)
            string += template.render(stack, context: context)
            currentObject = object
            context.first = false
            context.index += 1
        }

        context.last = true
        var stack = stack
        stack.append(currentObject)
        string += template.render(stack, context: context)

        return string
    }

    /// Render inverted section using template
    func renderInvertedSection(with template: HBMustacheTemplate, stack: [Any]) -> String {
        var stack = stack
        stack.append(self)

        var iterator = makeIterator()
        if iterator.next() == nil {
            return template.render(stack)
        }
        return ""
    }
}

extension Array: HBMustacheSequence {}
extension Set: HBMustacheSequence {}
extension ReversedCollection: HBMustacheSequence {}
