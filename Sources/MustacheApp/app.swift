import ArgumentParser
import Foundation
import Mustache
import Yams

@main
struct MustacheApp: ParsableCommand {
    var contextFile: String
    var templateFile: String

    func run() throws {
        guard let template = self.loadTemplate(filename: self.templateFile) else {
            fatalError("Failed to load template \(self.templateFile)")
        }
        let context = self.loadContext(filename: self.contextFile) else {
            fatalError("Failed to load context \(self.contextFile)")
        }
        let rendered = template.render(context)
        print(rendered)
    }

    func loadContext(filename: String) -> Any? {
        guard let file = loadString(filename: filename) else { return nil }
        return Yams.load(yaml: file)
    }

    func loadTemplate(filename: String) -> MustacheTemplate? {
        guard let file = loadString(filename: filename) else { return nil }
        return MustacheTemplate(string: file)
    }

    func loadString(filename: String) -> String? {
        let fs = FileManager.shared
        guard let data = fs.contents(atPath: filename) else { return nil }
        return String(decoding: data, as: Unicode.UTF8.self)
    }
}
