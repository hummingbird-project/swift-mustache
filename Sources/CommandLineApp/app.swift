import ArgumentParser
import Foundation
import Mustache
import Yams

@main
struct MustacheApp: ParsableCommand {
    var configuration: CommandConfiguration {
        .init(commandName: "mustache")
    }

    @Argument(help: "Context file")
    var contextFile: String

    @Argument(help: "Mustache template file")
    var templateFile: String

    func run() throws {
        guard let templateString = loadString(filename: self.templateFile) else {
            fatalError("Failed to load template file \(self.templateFile)")
        }
        let template = try MustacheTemplate(string: templateString)
        let context = try loadYaml(filename: self.contextFile)
        let rendered = template.render(context)
        print(rendered)
    }

    func loadString(filename: String) -> String? {
        guard let data = FileManager.default.contents(atPath: filename) else { return nil }
        return String(decoding: data, as: Unicode.UTF8.self)
    }

    func loadStdin() -> String {
        let input = AnyIterator { readLine() }.joined(separator: "\n")
        return input
    }

    func loadContext(filename: String) throws -> Any {
        let pathExtension = URL(fileURLWithPath: filename).pathExtension
        if pathExtension == "json" {
            return try self.loadJSON(filename: filename)
        } else {
            return try self.loadYaml(filename: filename)
        }
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
                fatalError("Failed to load context file \(filename)")
            }
            yamlString = string
        }
        guard let yaml = try Yams.load(yaml: yamlString) else {
            fatalError("YAML context file is empty\(filename)")
        }
        return convertObject(yaml)
    }

    func loadJSON(filename: String) throws -> Any {
        func convertObject(_ object: Any) -> Any {
            guard var dictionary = object as? [String: Any] else { return object }
            for (key, value) in dictionary {
                dictionary[key] = convertObject(value)
            }
            return dictionary
        }

        guard let jsonData = FileManager.default.contents(atPath: filename) else {
            fatalError("Failed to load json file \(filename)")
        }
        let json = try JSONSerialization.jsonObject(with: jsonData)

        return json
    }
}
