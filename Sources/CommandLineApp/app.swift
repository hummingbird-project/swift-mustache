import ArgumentParser
import Foundation
import Mustache
import Yams

struct MustacheAppError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

@main
struct MustacheApp: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mustache",
        abstract: """
        Mustache is a logic-less templating system for rendering
        text files.
        """,
        usage: """
        mustache <context-filename> <template-filename>
        mustache - <template-filename>
        """,
        discussion: """
        The mustache command processes a Mustache template with a context 
        defined in YAML/JSON. While the template is always loaded from a file
        the context can be supplied to the process either from a file or from
        stdin.

        Examples:
        mustache context.yml template.mustache
        cat context.yml | mustache - template.mustache
        """
    )

    @Argument(help: "Context file")
    var contextFile: String

    @Argument(help: "Mustache template file")
    var templateFile: String

    func run() throws {
        guard let templateString = loadString(filename: self.templateFile) else {
            throw MustacheAppError("Failed to load template file \(self.templateFile)")
        }
        let template = try MustacheTemplate(string: templateString)
        let context = try loadYaml(filename: self.contextFile)
        let rendered = template.render(context)
        print(rendered)
    }

    /// Load file into string
    func loadString(filename: String) -> String? {
        guard let data = FileManager.default.contents(atPath: filename) else { return nil }
        return String(decoding: data, as: Unicode.UTF8.self)
    }

    /// Pass stdin into a string
    func loadStdin() -> String {
        let input = AnyIterator { readLine(strippingNewline: false) }.joined(separator: "")
        return input
    }

    func loadContext(filename: String) throws -> Any {
        return try self.loadYaml(filename: filename)
    }

    func loadYaml(filename: String) throws -> Any {
        func convertObject(_ object: Any) -> Any {
            guard var dictionary = object as? [String: Any] else { return object }
            for (key, value) in dictionary {
                dictionary[key] = convertObject(value)
            }
            return dictionary
        }

        let yamlString: String
        if filename == "-" {
            yamlString = self.loadStdin()
        } else {
            guard let string = loadString(filename: filename) else {
                throw MustacheAppError("Failed to load context file \(filename)")
            }
            yamlString = string
        }
        guard let yaml = try Yams.load(yaml: yamlString) else {
            throw MustacheAppError("YAML context file is empty\(filename)")
        }
        return convertObject(yaml)
    }
}
