

func unwrapOptional(_ object: Any) -> Any? {
    let mirror = Mirror(reflecting: object)
    guard mirror.displayStyle == .optional else { return object }
    guard let first = mirror.children.first else { return nil }
    return first.value
}

extension Mirror {
    func getValue(forKey key: String) -> Any? {
        guard let matched = children.filter({ $0.label == key }).first else {
            return nil
        }
        return unwrapOptional(matched.value)
    }
}
