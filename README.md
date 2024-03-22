# Swift-Mustache

Package for rendering Mustache templates. Mustache is a "logic-less" templating language commonly used in web and mobile platforms. You can find out more about Mustache [here](http://mustache.github.io/mustache.5.html).

## Usage

Load your templates from the filesystem 
```swift
import Mustache
let library = MustacheLibrary("folder/my/templates/are/in")
```
This will look for all the files with the extension ".mustache" in the specified folder and subfolders and attempt to load them. Each file is registed with the name of the file (with subfolder, if inside a subfolder) minus the "mustache" extension.

Render an object with a template 
```swift
let output = library.render(object, withTemplate: "myTemplate")
```
`Swift-Mustache` treats an object as a set of key/value pairs when rendering and will render both dictionaries and objects via `Mirror` reflection. Find out more on how Mustache renders objects [here](https://docs.hummingbird.codes/2.0/documentation/hummingbird/mustachesyntax).

## Support

Swift-Mustache supports all standard Mustache tags and is fully compliant with the Mustache [spec](https://github.com/mustache/spec) with the exception of the Lambda support.  

## Additional features

Swift-Mustache includes some features that are specific to its implementation. Please follow the links below to find out more.

- [Lambda Implementation](https://docs.hummingbird.codes/2.0/documentation/hummingbird/lambdas)
- [Transforms](https://https://docs.hummingbird.codes/2.0/documentation/hummingbird/transforms)
- [Template Inheritance](https://docs.hummingbird.codes/2.0/documentation/hummingbird/templateinheritance)
- [Pragmas](https://docs.hummingbird.codes/2.0/documentation/hummingbird/pragmas)

## Documentation

Reference documentation for swift-mustache can be found [here](https://docs.hummingbird.codes/2.0/documentation/mustache)
