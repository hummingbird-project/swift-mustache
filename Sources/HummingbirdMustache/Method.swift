
protocol HBMustacheMethods {
    func runMethod(_ name: String) -> Any?
}

extension String: HBMustacheMethods {
    func runMethod(_ name: String) -> Any? {
        switch name {
        case "lowercased":
            return self.lowercased()
        case "uppercased":
            return self.uppercased()
        default:
            return nil
        }
    }
}

extension Array: HBMustacheMethods {
    func runMethod(_ name: String) -> Any? {
        switch name {
        case "reversed":
            return self.reversed()
        case "enumerated":
            return self.enumerated()
        default:
            return nil
        }
    }
}

extension Dictionary: HBMustacheMethods {
    func runMethod(_ name: String) -> Any? {
        switch name {
        case "enumerated":
            return self.enumerated()
        default:
            return nil
        }
    }
}

extension Int: HBMustacheMethods {
    func runMethod(_ name: String) -> Any? {
        switch name {
        case "plus1":
            return self + 1
        default:
            return nil
        }
    }
}
