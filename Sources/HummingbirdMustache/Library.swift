
public class HBMustacheLibrary {
    public init() {
        self.templates = [:]
    }
    
    public init(directory: String) {
        self.templates = [:]
        self.loadTemplates(from: directory)
    }
    
    public func register(_ template: HBMustacheTemplate, named name: String) {
        template.setLibrary(self)
        templates[name] = template
    }
    
    public func getTemplate(named name: String) -> HBMustacheTemplate? {
        templates[name]
    }
    
    public func render(_ object: Any, withTemplateNamed name: String) -> String? {
        guard let template = templates[name] else { return nil }
        return template.render(object)
    }
    
    private var templates: [String: HBMustacheTemplate]
}
