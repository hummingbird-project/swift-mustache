
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

