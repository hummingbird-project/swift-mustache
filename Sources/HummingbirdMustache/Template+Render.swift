
extension HBMustacheTemplate {
    /// Render template using object
    /// - Parameters:
    ///   - stack: Object
    ///   - context: Context that render is occurring in. Contains information about position in sequence
    ///   - indentation: indentation of partial
    /// - Returns: Rendered text
    func render(_ stack: [Any], context: HBMustacheSequenceContext? = nil, indentation: String? = nil) -> String {
        var string = ""
        if let indentation = indentation, indentation != "" {
            for token in tokens {
                if string.last == "\n" {
                    string += indentation
                }
                string += renderToken(token, stack: stack, context: context)
            }
        } else {
            for token in tokens {
                string += renderToken(token, stack: stack, context: context)
            }
        }
        return string
    }

    func renderToken(_ token: Token, stack: [Any], context: HBMustacheSequenceContext? = nil) -> String {
        switch token {
        case let .text(text):
            return text
        case let .variable(variable, method):
            if let child = getChild(named: variable, from: stack, method: method, context: context) {
                if let template = child as? HBMustacheTemplate {
                    return template.render(stack)
                } else {
                    return String(describing: child).htmlEscape()
                }
            }
        case let .unescapedVariable(variable, method):
            if let child = getChild(named: variable, from: stack, method: method, context: context) {
                return String(describing: child)
            }
        case let .section(variable, method, template):
            let child = getChild(named: variable, from: stack, method: method, context: context)
            return renderSection(child, stack: stack, with: template)

        case let .invertedSection(variable, method, template):
            let child = getChild(named: variable, from: stack, method: method, context: context)
            return renderInvertedSection(child, stack: stack, with: template)

        case let .partial(name, indentation):
            if let template = library?.getTemplate(named: name) {
                return template.render(stack, indentation: indentation)
            }
        }
        return ""
    }

    /// Render a section
    /// - Parameters:
    ///   - child: Object to render section for
    ///   - parent: Current object being rendered
    ///   - template: Template to render with
    /// - Returns: Rendered text
    func renderSection(_ child: Any?, stack: [Any], with template: HBMustacheTemplate) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderSection(with: template, stack: stack + [array])
        case let bool as Bool:
            return bool ? template.render(stack) : ""
        case let lambda as HBMustacheLambda:
            return lambda.run(stack.last!, template)
        case let .some(value):
            return template.render(stack + [value])
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
    func renderInvertedSection(_ child: Any?, stack: [Any], with template: HBMustacheTemplate) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderInvertedSection(with: template, stack: stack)
        case let bool as Bool:
            return bool ? "" : template.render(stack)
        case .some:
            return ""
        case .none:
            return template.render(stack)
        }
    }

    /// Get child object from variable name
    func getChild(named name: String, from stack: [Any], method: String?, context: HBMustacheSequenceContext?) -> Any? {
        func _getImmediateChild(named name: String, from object: Any) -> Any? {
            if let customBox = object as? HBMustacheParent {
                return customBox.child(named: name)
            } else {
                let mirror = Mirror(reflecting: object)
                return mirror.getValue(forKey: name)
            }
        }

        func _getChild(named names: ArraySlice<String>, from object: Any) -> Any? {
            guard let name = names.first else { return object }
            guard let childObject = _getImmediateChild(named: name, from: object) else { return nil }
            let names2 = names.dropFirst()
            return _getChild(named: names2, from: childObject)
        }

        func _getChildInStack(named names: ArraySlice<String>, from stack: [Any]) -> Any? {
            guard let name = names.first else { return stack.last }
            for object in stack.reversed() {
                if let childObject = _getImmediateChild(named: name, from: object) {
                    let names2 = names.dropFirst()
                    return _getChild(named: names2, from: childObject)
                }
            }
            return nil
        }

        // work out which object to access. "." means the current object, if the variable name is ""
        // and we have a method to run on the variable then we need the context object, otherwise
        // the name is split by "." and we use mirror to get the correct child object
        let child: Any?
        if name == "." {
            child = stack.last!
        } else if name == "", method != nil {
            child = context
        } else {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChildInStack(named: nameSplit[...], from: stack)
        }
        // if we want to run a method and the current child can have methods applied to it then
        // run method on the current child
        if let method = method,
           let runnable = child as? HBMustacheTransformable
        {
            if let result = runnable.transform(method) {
                return result
            }
        }
        return child
    }
}
