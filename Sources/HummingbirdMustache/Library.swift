
public class HBMustacheLibrary {
    init() {
        self.templates = [:]
    }
    
    public func register(_ template: HBMustacheTemplate, named name: String) {
        templates[name] = template
    }
    
    public func render(_ object: Any, withTemplateNamed name: String) -> String? {
        guard let template = templates[name] else { return nil }
        return template.render(object, library: self)
    }
    
    var templates: [String: HBMustacheTemplate]
}
