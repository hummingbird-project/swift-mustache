
protocol HBMustacheSequence {
    func renderSection(with template: HBMustacheTemplate) -> String
    func renderInvertedSection(with template: HBMustacheTemplate) -> String
}

extension Sequence {
    func renderSection(with template: HBMustacheTemplate) -> String {
        var string = ""
        var context = HBMustacheContext(first: true)
        var iterator = self.makeIterator()
        guard var currentObject = iterator.next() else { return "" }

        while let object = iterator.next() {
            string += template.render(currentObject, context: context)
            currentObject = object
            context.first = false
        }

        context.last = true
        string += template.render(currentObject, context: context)
        
        return string
    }
    
    func renderInvertedSection(with template: HBMustacheTemplate) -> String {
        var iterator = makeIterator()
        if iterator.next() == nil {
            return template.render(self)
        }
        return ""
    }

}

extension Array: HBMustacheSequence {}
extension ReversedCollection: HBMustacheSequence {}
extension EnumeratedSequence: HBMustacheSequence {}
