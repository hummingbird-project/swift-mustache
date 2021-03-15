import Logging

/// Class holding a collection of mustache templates.
///
/// Each template can reference the others via a partial using the name the template is registered under
/// ```
/// {{#sequence}}{{>entry}}{{/sequence}}
/// ```
public final class HBMustacheLibrary {
    /// Initialize empty library
    public init() {
        templates = [:]
    }

    /// Initialize library with contents of folder.
    ///
    /// Each template is registered with the name of the file minus its extension. The search through
    /// the folder is recursive and templates in subfolders will be registered with the name `subfolder/template`.
    /// - Parameter directory: Directory to look for mustache templates
    /// - Parameter extension: Extension of files to look for
    public init(directory: String, withExtension extension: String = "mustache", logger: Logger? = nil) {
        templates = [:]
        loadTemplates(from: directory, withExtension: `extension`, logger: logger)
    }

    /// Register template under name
    /// - Parameters:
    ///   - template: Template
    ///   - name: Name of template
    public func register(_ template: HBMustacheTemplate, named name: String) {
        template.setLibrary(self)
        templates[name] = template
    }

    /// Return template registed with name
    /// - Parameter name: name to search for
    /// - Returns: Template
    public func getTemplate(named name: String) -> HBMustacheTemplate? {
        templates[name]
    }

    /// Render object using templated with name
    /// - Parameters:
    ///   - object: Object to render
    ///   - name: Name of template
    /// - Returns: Rendered text
    public func render(_ object: Any, withTemplate name: String) -> String? {
        guard let template = templates[name] else { return nil }
        return template.render(object)
    }

    private var templates: [String: HBMustacheTemplate]
}
