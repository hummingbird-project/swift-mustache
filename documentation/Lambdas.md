# Lambda Implementation

The library doesn't provide a lambda implementation but it does provide something akin to the lambda feature. 

Add a `HBMustacheLambda` to the object you want to be rendered and it can be used in a similar way to lambdas are used in Mustache. When you create a section referencing the lambda the contents of the section are passed as a template along with the current object to the lamdba function. This is slightly different from the standard implementation where the unprocessed text is passed to the lambda. 

Given the object `person` defined below
```swift
struct Person {
    let name: String
    let wrapped: HBMustacheLambda
}
let person = Person(
    name: "John", 
    wrapped: HBMustacheLambda { object, template in
        return "<b>\(template.render(object))</b>"
    }
)

```
and the following mustache template  
```swift
let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
let template = try HBMustacheTemplate(string: mustache)
```
Then `template.render(person)` will output 
```
<b>John is awesome.</b>
```
In this example the template constructed from the contents of the `wrapped` section of the mustache is passed to my `wrapped` function inside the `Person` type.
