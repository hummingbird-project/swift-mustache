struct HBMustacheContext {
    let stack: [Any]
    let sequenceContext: HBMustacheSequenceContext?
    let indentation: String?
    
    init(_ object: Any) {
        self.stack = [object]
        self.sequenceContext = nil
        self.indentation = nil
    }
    
    private init(stack: [Any], sequenceContext: HBMustacheSequenceContext?, indentation: String?) {
        self.stack = stack
        self.sequenceContext = sequenceContext
        self.indentation = indentation
    }
    
    func withObject(_ object: Any) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(stack: stack, sequenceContext: nil, indentation: self.indentation)
    }
    
    func withPartial(indented: String?) -> HBMustacheContext {
        let indentation: String?
        if let indented = indented {
            indentation = (self.indentation ?? "") + indented
        } else {
            indentation = self.indentation
        }
        return .init(stack: self.stack, sequenceContext: nil, indentation: indentation)
    }
    
    func withSequence(_ object: Any, sequenceContext: HBMustacheSequenceContext) -> HBMustacheContext {
        var stack = self.stack
        stack.append(object)
        return .init(stack: stack, sequenceContext: sequenceContext, indentation: self.indentation)
    }
}
