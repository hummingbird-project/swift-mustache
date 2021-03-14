
struct HBMustacheContext {
    let first: Bool
    let last: Bool
    
    init(first: Bool = false, last: Bool = false) {
        self.first = first
        self.last = last
    }
}
