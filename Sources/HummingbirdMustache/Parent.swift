
/// Protocol for object that has a custom method for accessing their children, instead
/// of using Mirror
protocol HBMustacheParent {
    func child(named: String) -> Any?
}

/// Extend dictionary where the key is a string so that it uses the key values to access
/// it values
extension Dictionary: HBMustacheParent where Key == String {
    func child(named: String) -> Any? { return self[named] }
}

