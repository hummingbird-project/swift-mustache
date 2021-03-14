
extension HBMustacheTemplate {
    func render(_ object: Any, context: HBMustacheContext? = nil) -> String {
        var string = ""
        for token in tokens {
            switch token {
            case .text(let text):
                string += text
            case .variable(let variable, let method):
                if let child = getChild(named: variable, from: object, method: method, context: context) {
                    if let template = child as? HBMustacheTemplate {
                        string += template.render(object)
                    } else {
                        string += htmlEscape(String(describing: child))
                    }
                }
            case .unescapedVariable(let variable, let method):
                if let child = getChild(named: variable, from: object, method: method, context: context) {
                    string += String(describing: child)
                }
            case .section(let variable, let method, let template):
                let child = getChild(named: variable, from: object, method: method, context: context)
                string += renderSection(child, parent: object, with: template)
                
            case .invertedSection(let variable, let method, let template):
                let child = getChild(named: variable, from: object, method: method, context: context)
                string += renderInvertedSection(child, parent: object, with: template)
                
            case .partial(let name):
                if let text = library?.render(object, withTemplateNamed: name) {
                    string += text
                }
            }
        }
        return string
    }
    
    func renderSection(_ child: Any?, parent: Any, with template: HBMustacheTemplate) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderSection(with: template)
        case let bool as Bool:
            return bool ? template.render(parent) : ""
        case let lambda as HBMustacheLambda:
            return lambda(parent, template)
        case .some(let value):
            return template.render(value)
        case .none:
            return ""
        }
    }
    
    func renderInvertedSection(_ child: Any?, parent: Any, with template: HBMustacheTemplate) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderInvertedSection(with: template)
        case let bool as Bool:
            return bool ? "" : template.render(parent)
        case .some:
            return ""
        case .none:
            return template.render(parent)
        }
    }
    
    func getChild(named name: String, from object: Any, method: String?, context: HBMustacheContext?) -> Any? {
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

        let child: Any?
        if name == "." {
            child = object
        } else if name == "", method != nil {
            child = context
        } else {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChild(named: nameSplit[...], from: object)
        }
        if let method = method,
           let runnable = child as? HBMustacheMethods {
            if let result = runnable.runMethod(method) {
                return result
            }
        }
        return child
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

