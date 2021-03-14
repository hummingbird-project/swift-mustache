
struct HBMustacheContext: HBMustacheMethods {
    var first: Bool
    var last: Bool
    
    init(first: Bool = false, last: Bool = false) {
        self.first = first
        self.last = last
    }

    func runMethod(_ name: String) -> Any? {
        switch name {
        case "first":
            return self.first
        case "last":
            return self.last
        default:
            return nil
        }
    }

}
