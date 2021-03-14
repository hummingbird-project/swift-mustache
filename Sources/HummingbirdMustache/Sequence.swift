
protocol HBMustacheSequence {
    func renderSection(with template: HBMustacheTemplate) -> String
    func renderInvertedSection(with template: HBMustacheTemplate) -> String
}

extension Sequence {
    func renderSection(with template: HBMustacheTemplate) -> String {
        var string = ""
        for obj in self {
            string += template.render(obj)
        }
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
