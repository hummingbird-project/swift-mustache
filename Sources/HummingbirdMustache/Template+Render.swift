
extension HBTemplate {
    public func render(_ object: Any) -> String {
        var string = ""
        for token in tokens {
            switch token {
            case .text(let text):
                string += text
            case .variable(let variable):
                if let child = getChild(named: variable, from: object) {
                    string += String(describing: child)
                }
            case .section(let variable, let template):
                let child = getChild(named: variable, from: object)
                string += renderSection(child, with: template)
                
            case .invertedSection(let variable, let template):
                let child = getChild(named: variable, from: object)
                string += renderInvertedSection(child, with: template)
                
            }
        }
        return string
    }
    
    func renderSection(_ object: Any?, with template: HBTemplate) -> String {
        switch object {
        case let array as HBSequence:
            return array.renderSection(with: template)
        case let bool as Bool:
            return bool ? template.render(true) : ""
        case let int as Int:
            return int != 0 ? template.render(int) : ""
        case let int as Int8:
            return int != 0 ? template.render(int) : ""
        case let int as Int16:
            return int != 0 ? template.render(int) : ""
        case let int as Int32:
            return int != 0 ? template.render(int) : ""
        case let int as Int64:
            return int != 0 ? template.render(int) : ""
        case let int as UInt:
            return int != 0 ? template.render(int) : ""
        case let int as UInt8:
            return int != 0 ? template.render(int) : ""
        case let int as UInt16:
            return int != 0 ? template.render(int) : ""
        case let int as UInt32:
            return int != 0 ? template.render(int) : ""
        case let int as UInt64:
            return int != 0 ? template.render(int) : ""
        case .some(let value):
            return template.render(value)
        case .none:
            return ""
        }
    }
    
    func renderInvertedSection(_ object: Any?, with template: HBTemplate) -> String {
        switch object {
        case let array as HBSequence:
            return array.renderInvertedSection(with: template)
        case let bool as Bool:
            return bool ? "" : template.render(true)
        case let int as Int:
            return int == 0 ? template.render(int) : ""
        case let int as Int8:
            return int == 0 ? template.render(int) : ""
        case let int as Int16:
            return int == 0 ? template.render(int) : ""
        case let int as Int32:
            return int == 0 ? template.render(int) : ""
        case let int as Int64:
            return int == 0 ? template.render(int) : ""
        case let int as UInt:
            return int == 0 ? template.render(int) : ""
        case let int as UInt8:
            return int == 0 ? template.render(int) : ""
        case let int as UInt16:
            return int == 0 ? template.render(int) : ""
        case let int as UInt32:
            return int == 0 ? template.render(int) : ""
        case let int as UInt64:
            return int == 0 ? template.render(int) : ""
        case .some:
            return ""
        case .none:
            return template.render(Void())
        }
    }
    
    func getChild(named name: String, from: Any) -> Any? {
        if name == "." { return from }
        if let customBox = from as? HBMustacheParent {
            return customBox.child(named: name)
        }
        let mirror = Mirror(reflecting: from)
        return mirror.getAttribute(forKey: name)
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

