
protocol HBMustacheBaseMethods {
    func runMethod(_ name: String) -> Any?
}
protocol HBMustacheMethods {
    typealias Method = (Self) -> Any
    static var methods: [String: Method] { get set }
}

extension HBMustacheMethods {
    static func addMethod(named name: String, method: @escaping Method) {
        Self.methods[name] = method
    }
    func runMethod(_ name: String) -> Any? {
        guard let method = Self.methods[name] else { return nil }
        return method(self)
    }
}

extension String: HBMustacheBaseMethods {
    func runMethod(_ name: String) -> Any? {
        switch name {
        case "lowercased":
            return self.lowercased()
        default:
            return nil
        }
    }
}
