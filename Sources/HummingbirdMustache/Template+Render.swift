
extension HBMustacheTemplate {
    public func render(_ object: Any, library: HBMustacheLibrary? = nil) -> String {
        var string = ""
        for token in tokens {
            switch token {
            case .text(let text):
                string += text
            case .variable(let variable):
                if let child = getChild(named: variable, from: object) {
                    string += encodedEscapedCharacters(String(describing: child))
                }
            case .unescapedVariable(let variable):
                if let child = getChild(named: variable, from: object) {
                    string += String(describing: child)
                }
            case .section(let variable, let template):
                let child = getChild(named: variable, from: object)
                string += renderSection(child, parent: object, with: template, library: library)
                
            case .invertedSection(let variable, let template):
                let child = getChild(named: variable, from: object)
                string += renderInvertedSection(child, parent: object, with: template, library: library)
                
            case .partial(let name):
                if let text = library?.render(object, withTemplateNamed: name) {
                    string += text
                }
            }
        }
        return string
    }
    
    func renderSection(_ child: Any?, parent: Any, with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String {
        switch child {
        case let array as HBSequence:
            return array.renderSection(with: template, library: library)
        case let bool as Bool:
            return bool ? template.render(parent, library: library) : ""
        case .some(let value):
            return template.render(value, library: library)
        case .none:
            return ""
        }
    }
    
    func renderInvertedSection(_ child: Any?, parent: Any, with template: HBMustacheTemplate, library: HBMustacheLibrary?) -> String {
        switch child {
        case let array as HBSequence:
            return array.renderInvertedSection(with: template, library: library)
        case let bool as Bool:
            return bool ? "" : template.render(parent, library: library)
        case .some:
            return ""
        case .none:
            return template.render(parent, library: library)
        }
    }
    
    func getChild(named name: String, from object: Any) -> Any? {
        func _getChild(named names: ArraySlice<String>, from object: Any) -> Any? {
            guard let name = names.first else { return object }
            let childObject: Any?
            if let customBox = object as? HBMustacheParent {
                childObject = customBox.child(named: name)
            } else {
                let mirror = Mirror(reflecting: object)
                childObject = mirror.getAttribute(forKey: name)
            }
            guard childObject != nil else { return nil }
            let names2 = names.dropFirst()
            return _getChild(named: names2, from: childObject!)
        }

        if name == "." { return object }
        let nameSplit = name.split(separator: ".").map { String($0) }
        return _getChild(named: nameSplit[...], from: object)
    }

    private static let escapedCharacters: [Character: String] = [
        "<": "&lt;",
        ">": "&gt;",
        "&": "&amp;",
    ]
    func encodedEscapedCharacters(_ string: String) -> String {
        var newString = ""
        newString.reserveCapacity(string.count)
        for c in string {
            if let replacement = Self.escapedCharacters[c] {
                newString += replacement
            } else {
                newString.append(c)
            }
        }
        return newString
    }
}

func unwrap(_ any: Any) -> Any? {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional else { return any }
    guard let first = mirror.children.first else { return nil }
    return first.value
}

extension Mirror {
    func getAttribute(forKey key: String) -> Any? {
        guard let matched = children.filter({ $0.label == key }).first else {
            return nil
        }
        return unwrap(matched.value)
    }
}

