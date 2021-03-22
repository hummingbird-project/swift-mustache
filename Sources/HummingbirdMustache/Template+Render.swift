
extension HBMustacheTemplate {
    /// Render template using object
    /// - Parameters:
    ///   - stack: Object
    ///   - context: Context that render is occurring in. Contains information about position in sequence
    ///   - indentation: indentation of partial
    /// - Returns: Rendered text
    func render(context: HBMustacheContext) -> String {
        var string = ""
        if let indentation = context.indentation, indentation != "" {
            for token in tokens {
                if string.last == "\n" {
                    string += indentation
                }
                string += self.renderToken(token, context: context)
            }
        } else {
            for token in tokens {
                string += self.renderToken(token, context: context)
            }
        }
        return string
    }

    func renderToken(_ token: Token, context: HBMustacheContext) -> String {
        switch token {
        case .text(let text):
            return text
        case .variable(let variable, let method):
            if let child = getChild(named: variable, method: method, context: context) {
                if let template = child as? HBMustacheTemplate {
                    return template.render(context: context)
                } else {
                    return String(describing: child).htmlEscape()
                }
            }
        case .unescapedVariable(let variable, let method):
            if let child = getChild(named: variable, method: method, context: context) {
                return String(describing: child)
            }
        case .section(let variable, let method, let template):
            let child = self.getChild(named: variable, method: method, context: context)
            return self.renderSection(child, with: template, context: context)

        case .invertedSection(let variable, let method, let template):
            let child = self.getChild(named: variable, method: method, context: context)
            return self.renderInvertedSection(child, with: template, context: context)

        case .inheritedSection(let name, let template):
            if let override = context.inherited?[name] {
                return override.render(context: context)
            } else {
                return template.render(context: context)
            }

        case .partial(let name, let indentation, let overrides):
            if let template = library?.getTemplate(named: name) {
                return template.render(context: context.withPartial(indented: indentation, inheriting: overrides))
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
    func renderSection(_ child: Any?, with template: HBMustacheTemplate, context: HBMustacheContext) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderSection(with: template, context: context)
        case let bool as Bool:
            return bool ? template.render(context: context) : ""
        case let lambda as HBMustacheLambda:
            return lambda.run(context.stack.last!, template)
        case .some(let value):
            return template.render(context: context.withObject(value))
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
    func renderInvertedSection(_ child: Any?, with template: HBMustacheTemplate, context: HBMustacheContext) -> String {
        switch child {
        case let array as HBMustacheSequence:
            return array.renderInvertedSection(with: template, context: context)
        case let bool as Bool:
            return bool ? "" : template.render(context: context)
        case .some:
            return ""
        case .none:
            return template.render(context: context)
        }
    }

    /// Get child object from variable name
    func getChild(named name: String, method: String?, context: HBMustacheContext) -> Any? {
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
            child = context.stack.last!
        } else if name == "", method != nil {
            child = context.sequenceContext
        } else {
            let nameSplit = name.split(separator: ".").map { String($0) }
            child = _getChildInStack(named: nameSplit[...], from: context.stack)
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
