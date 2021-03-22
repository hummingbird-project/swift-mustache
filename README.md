# HummingbirdMustache

Package for rendering Mustache templates. Mustache is a logicless templating language commonly used in web and mobile platforms. You can find out more about Mustache [here](http://mustache.github.io/mustache.5.html).

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

## Support

Hummingbird Mustache supports all standard Mustache tags and is fully compliant with the Mustache [spec](https://github.com/mustache/spec) with the exception of the Lambda support.  

## Additional features

Hummingbird Mustache includes some features that are specific to its implementation. 

### Lambda Implementation

The library doesn't provide a lambda implementation but it does provide something akin to the lambda feature. 

Add a `HBMustacheLambda` to the object you want to be rendered and it can be used in a similar way to lambdas are used in Mustache. When you create a section referencing the lambda the contents of the section are passed as a template along with the current object to the lamdba function. This is slightly different from the standard implementation where the unprocessed text is passed to the lambda. 

Given the following mustache template
```swift
let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
let template = try HBMustacheTemplate(string: mustache)
```
The following object `john` 
```swift
struct Object {
    let name: String
    let wrapped: HBMustacheLambda
}
let john = Object(
    name: "John", 
    wrapped: HBMustacheLambda({ object, template in
        return "<b>\(template.render(object))</b>"
    })
)
let output = template.render(john)
```
Will render as 
```
<b>John is awesome.</b>
```

### Transforms

Transforms are similar to lambdas in that they are functions run on an object but with the difference they return a new object instead of rendered text. Transforms are formatted as a function call inside a tag eg
```
{{uppercase(string)}}
```
They can be applied to variable, section and inverted section tags. If you apply them to a section or inverted section tag the handler name should be included in the end section tag as well eg
```
{{#sorted(array)}}{{.}}{{/sorted(array)}}
```
The library comes with a series of transforms for the Swift standard objects.
- String/Substring
  - capitalized: Return string with first letter capitalized
  - lowercase: Return lowercased version of string
  - uppercase: Return uppercased version of string
  - reversed: Reverse string
- Int/UInt/Int8/Int16...
  - plusone: Add one to integer
  - minusone: Subtract one from integer
  - odd: return if integer is odd
  - even: return if integer is even
- Array
  - first: Return first element of array
  - last: Return last element of array
  - count: Return number of elements in array
  - reversed: Reverse array
  - sorted: If the elements of the array are comparable sort them
- Dictionary
  - count: Return number of elements in dictionary
  - enumerated: Return dictionary as array of key, value pairs
  - sorted: If the keys are comparable return as array of key, value pairs sorted by key

### Sequence context transforms

Sequence context transforms are transforms applied to the current position in the sequence. They are formatted as a function that takes no parameter eg
```
{{#first()}}First{{/first()}}
```
The following sequence context transforms are available
- first: Is this the first element of the sequence
- last: Is this the last element of the sequence
- index: Returns the index of the element within the sequence
- odd: Returns if the index of the element is odd
- even: Returns if the index of the element is even
