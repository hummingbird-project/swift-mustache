struct HBMustacheContext {
    let stack: [Any]
    let sequenceContext: HBMustacheSequenceContext?
    let indentation: String?
    let inherited: [String: HBMustacheTemplate]?
    
    init(_ object: Any) {
        self.stack = [object]
        self.sequenceContext = nil
        self.indentation = nil
        self.inherited = nil
    }
    
    private init(
        stack: [Any],
        sequenceContext: HBMustacheSequenceContext?,
        indentation: String?,
        inherited: [String: HBMustacheTemplate]?
    ) {
        self.stack = stack
        self.sequenceContext = sequenceContext
        self.indentation = indentation
        self.inherited = inherited
    }
    
    func withObject(_ object: Any) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(stack: stack, sequenceContext: nil, indentation: self.indentation, inherited: self.inherited)
    }
    
    func withPartial(indented: String?, inheriting: [String: HBMustacheTemplate]?) -> HBMustacheContext {
        let indentation: String?
        if let indented = indented {
            indentation = (self.indentation ?? "") + indented
        } else {
            indentation = self.indentation
        }
        let inherits: [String: HBMustacheTemplate]?
        if let inheriting = inheriting {
            if let originalInherits = self.inherited {
                inherits = originalInherits.merging(inheriting) { value,_ in value }
            } else {
                inherits = inheriting
            }
        } else {
            inherits = self.inherited
        }
        return .init(stack: self.stack, sequenceContext: nil, indentation: indentation, inherited: inherits)
    }
    
    func withSequence(_ object: Any, sequenceContext: HBMustacheSequenceContext) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(stack: stack, sequenceContext: sequenceContext, indentation: self.indentation, inherited: self.inherited)
    }
}
