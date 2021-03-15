# HummingbirdMustache

Package for rendering Mustache templates. Mustache is a templating language commonly used in server frameworks for generating HTML files (although it is not limited to HTML). You can find out more about Mustache [here](http://mustache.github.io/mustache.5.html).

## Usage

Load your templates from the filesystem 
```swift
let library = HBMustacheLibrary("folder/my/templates/are/in")
```
This will look for all the files with the extension ".mustache" and attempt to load them

Render an object with a template 
```swift
let output = library.render(object, withTemplate: "myTemplate")
```
`HummingbirdMustache` will render both dictionaries and objects via `Mirror` reflection. The following two examples will both produce the same output
```swift
let object = ["name": "John Smith", "age": 68]
let output = library.render(object, withTemplate: "myTemplate")
```
and
```swift
struct Person {
    let name: String
    let age: Int
}
let object = Person(name: "John Smith", age: 68)
let output = library.render(object, withTemplate: "myTemplate")
```

