
extension HBMustacheTemplate {
    public func render(_ object: Any, library: HBMustacheLibrary? = nil) -> String {
        var string = ""
        for token in tokens {
            switch token {
            case .text(let text):
                string += text
            case .variable(let variable, let method):
                if var child = getChild(named: variable, from: object) {
                    if let method = method,
                       let runnable = child as? HBMustacheBaseMethods {
                        if let result = runnable.runMethod(method) {
                            child = result
                        }
                    }
                    if let template = child as? HBMustacheTemplate {
                        string += template.render(object, library: library)
                    } else {
                        string += htmlEscape(String(describing: child))
                    }
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
                childObject = mirror.getValue(forKey: name)
            }
            guard childObject != nil else { return nil }
            let names2 = names.dropFirst()
            return _getChild(named: names2, from: childObject!)
        }

        if name == "." { return object }
        let nameSplit = name.split(separator: ".").map { String($0) }
        return _getChild(named: nameSplit[...], from: object)
    }

    private static let htmlEscapedCharacters: [Character: String] = [
        "<": "&lt;",
        ">": "&gt;",
        "&": "&amp;",
    ]
    func htmlEscape(_ string: String) -> String {
        var newString = ""
        newString.reserveCapacity(string.count)
        for c in string {
            if let replacement = Self.htmlEscapedCharacters[c] {
                newString += replacement
            } else {
                newString.append(c)
            }
        }
        return newString
    }
}

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
