
protocol HBMustacheParent {
    func child(named: String) -> Any?
}

extension HBMustacheParent {
    // default child to nil
    func child(named: String) -> Any? { return nil }
}

extension Dictionary: HBMustacheParent where Key == String {
    func child(named: String) -> Any? { return self[named] }
}

protocol HBSequence {
    func renderSection(with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String
    func renderInvertedSection(with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String
}

extension Array: HBSequence {
    func renderSection(with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String {
        var string = ""
        for obj in self {
            string += template.render(obj, library: library)
        }
        return string
    }

    func renderInvertedSection(with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String {
        if count == 0 {
            return template.render(self, library: library)
        }
        return ""
    }
}
