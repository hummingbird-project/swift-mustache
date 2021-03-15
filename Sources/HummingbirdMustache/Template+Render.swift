
extension HBMustacheTemplate {
    /// Render template using object
    /// - Parameters:
    ///   - object: Object
    ///   - context: Context that render is occurring in. Contains information about position in sequence
    /// - Returns: Rendered text
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
                        string += String(describing: child).htmlEscape()
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

    /// Render a section
    /// - Parameters:
    ///   - child: Object to render section for
    ///   - parent: Current object being rendered
    ///   - template: Template to render with
    /// - Returns: Rendered text
    func renderSection(_ child: Any?, parent: Any, with template: HBMustacheTemplate) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderSection(with: template)
        case let bool as Bool:
            return bool ? template.render(parent) : ""
        case let lambda as HBMustacheLambda:
            return lambda.run(parent, template)
        case .some(let value):
            return template.render(value)
        case .none:
            return ""
        }
    }
    
    /// Render an inverted section
    /// - Parameters:
    ///   - child: Object to render section for
    ///   - parent: Current object being rendered
    ///   - template: Template to render with
    /// - Returns: Rendered text
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

    /// Get child object from variable name
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

        // work out which object to access. "." means the current object, if the variable name is ""
        // and we have a method to run on the variable then we need the context object, otherwise
        // the name is split by "." and we use mirror to get the correct child object
        let child: Any?
        if name == "." {
            child = object
        } else if name == "", method != nil {
            child = context
        } else {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChild(named: nameSplit[...], from: object)
        }
        // if we want to run a method and the current child can have methods applied to it then
        // run method on the current child
        if let method = method,
           let runnable = child as? HBMustacheMethods {
            if let result = runnable.runMethod(method) {
                return result
            }
        }
        return child
    }
}

