
/// Protocol for objects that can be rendered as a sequence in Mustache
public protocol HBMustacheSequence {
    /// Render section using template
    func renderSection(with template: HBMustacheTemplate) -> String
    /// Render inverted section using template
    func renderInvertedSection(with template: HBMustacheTemplate) -> String
}

extension Sequence {
    /// Render section using template
    public func renderSection(with template: HBMustacheTemplate) -> String {
        var string = ""
        var context = HBMustacheContext(first: true)
        var iterator = self.makeIterator()
        guard var currentObject = iterator.next() else { return "" }

        while let object = iterator.next() {
            string += template.render(currentObject, context: context)
            currentObject = object
            context.first = false
            context.index += 1
        }

        context.last = true
        string += template.render(currentObject, context: context)
        
        return string
    }
    
    /// Render inverted section using template
    public func renderInvertedSection(with template: HBMustacheTemplate) -> String {
        var iterator = makeIterator()
        if iterator.next() == nil {
            return template.render(self)
        }
        return ""
    }

}

extension Array: HBMustacheSequence {}
extension Set: HBMustacheSequence {}
extension ReversedCollection: HBMustacheSequence {}
