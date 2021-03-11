
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
    func renderSection(with template: HBTemplate) -> String
    func renderInvertedSection(with template: HBTemplate) -> String
}

extension Array: HBSequence {
    func renderSection(with template: HBTemplate) -> String {
        var string = ""
        for obj in self {
            string += template.render(obj)
        }
        return string
    }

    func renderInvertedSection(with template: HBTemplate) -> String {
        if count == 0 {
            return template.render(self)
        }
        return ""
    }
}

extension Dictionary: HBSequence {
    func renderSection(with template: HBTemplate) -> String {
        var string = ""
        for obj in self {
            string += template.render(obj)
        }
        return string
    }

    func renderInvertedSection(with template: HBTemplate) -> String {
        if count == 0 {
            return template.render(self)
        }
        return ""
    }
}
