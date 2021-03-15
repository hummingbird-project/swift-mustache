import Foundation
import Logging

extension HBMustacheLibrary {
    /// Load templates from a folder
    func loadTemplates(from directory: String, withExtension extension: String = "mustache", logger: Logger?) {
        var directory = directory
        if !directory.hasSuffix("/") {
            directory += "/"
        }
        let extWithDot = ".\(`extension`)"
        let fs = FileManager()
        guard let enumerator = fs.enumerator(atPath: directory) else { return }
        for case let path as String in enumerator {
            guard path.hasSuffix(extWithDot) else { continue }
            guard let data = fs.contents(atPath: directory + path) else { continue}
            let string = String(decoding: data, as: Unicode.UTF8.self)
            guard let template = try? HBMustacheTemplate(string: string) else {
                logger?.error("Failed to load \(path)")
                continue
            }
            logger?.debug("Loading \(path)")
            // drop ".mustache" from path to get name
            let name = String(path.dropLast(extWithDot.count))
            register(template, named: name)
        }
    }
}
