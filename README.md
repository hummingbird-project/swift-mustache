# HummingbirdMustache

Package for rendering Mustache templates. Mustache is a "logic-less" templating language commonly used in web and mobile platforms. You can find out more about Mustache [here](http://mustache.github.io/mustache.5.html).

While Hummingbird Mustache has been designed to be used with the Hummingbird server framework it has no dependencies and can be used as a standalone library.

## Usage

Load your templates from the filesystem 
```swift
let library = HBMustacheLibrary("folder/my/templates/are/in")
```
This will look for all the files with the extension ".mustache" in the specified folder and subfolders and attempt to load them. Each file is registed with the name of the file (with subfolder, if inside a subfolder) minus the "mustache" extension.

Render an object with a template 
```swift
let output = library.render(object, withTemplate: "myTemplate")
```
`HummingbirdMustache` treats an object as a set of key/value pairs when rendering and will render both dictionaries and objects via `Mirror` reflection. Find out more on how Mustache renders objects [here](https://hummingbird-project.github.io/hummingbird/current/hummingbird-mustache/mustache-syntax.html).

### Using with Hummingbird

HummingbirdMustache doesn't have any integration with Hummingbird as I wanted to keep the library dependency free. But if you are going to use the library with Hummingbird it is recommended you extend `HBApplication` to store an instance of your library.

```swift
extension HBApplication {
    var mustache: HBMustacheLibrary {
        get { self.extensions.get(\.mustache) }
        set { self.extensions.set(\.mustache, value: newValue) }
    }
}

extension HBRequest {
    var mustache: HBMustacheLibrary { self.application.mustache }
}
// load mustache templates from templates folder
application.mustache = try .init(directory: "templates")
```
You can now access your mustache templates via `HBRequest` eg `HBRequest.mustache.render(obj, withTemplate: "myTemplate")`

## Support

Hummingbird Mustache supports all standard Mustache tags and is fully compliant with the Mustache [spec](https://github.com/mustache/spec) with the exception of the Lambda support.  

## Additional features

Hummingbird Mustache includes some features that are specific to its implementation. Please follow the links below to find out more.

- [Lambda Implementation](https://hummingbird-project.github.io/hummingbird/current/hummingbird-mustache/lambdas.html)
- [Transforms](https://hummingbird-project.github.io/hummingbird/current/hummingbird-mustache/transforms.html)
- [Template Inheritance](https://hummingbird-project.github.io/hummingbird/current/hummingbird-mustache/template-inheritance.html)
- [Pragmas](https://hummingbird-project.github.io/hummingbird/current/hummingbird-mustache/pragmas.html)
