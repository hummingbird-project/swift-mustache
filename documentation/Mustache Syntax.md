# Mustache Syntax

Mustache is a "logic-less" templating engine. The core language has no flow control statements. Instead it has tags that can be replaced with a value, nothing or a series of values. Below we document all the standard tags

## Context

Mustache renders a template with a context stack. A context is a list of key/value pairs. These can be represented by either a `Dictionary` or the reflection information from `Mirror`. Initially the stack will exist of the root context object you want to render. When we enter a section tag we push the associated value onto the context stack.

## Tags

All tags are surrounded by a double curly bracket `{{}}`. When a tag has a reference to a key the associated value will be searched for from the context at the top of the context stack. If the value cannot be found then the next context down will be searched for and so on until either a value is found or we have reached the bottom of the stack.

## Tag types

- `{{key}}`: Render value associated with `key` as text. By default this is HTML escaped.
- `{{{name}}}`: Acts the same as `{{name}}` except the resultant text is not HTML escaped. You can also use `{{&name}}` to avoid HTML escaping.
- `{{#section}}`: Section render blocks either render text once or more times depending on the value of the key in the current context. A section begins with `{{#section}}` and end with `{{/section}}`. If the key represents a `Bool` value it will only render if it is true. If the key represents an `Optional` it will only render if the object is non-nil. If the key represents a `Array` it will then render the text multiple times, once for each element of the `Array`. Otherwise it will render with the selected object pushed onto the top of the context stack.
- `{{^section}}`: An inverted section does the opposite of a section. If the key represents a `Bool` value it will only render if it is false. If the key represents an `Optional` it will only render if it is `nil`. If the key represents a `Array` it will render if the `Array` is empty.
- `{{! comment }}: This is a comment tag and is ignored.
- `{{> partial}}`: A partial tag renders another mustache file, with the current context stack. In Hummingbird Mustache partial tags only work for templates that are a part of a library and the tag is the name of the referenced file without the ".mustache" extension.
- `{{=<% %>=}}`: The set delimiter tag allows you to change from using the double curly brackets as tag delimiters. In the example the delimiters have been changed to `<% %>` but you can change them to whatever you like.

You can find out more about the standard Mustache tags in the [Mustache Manual](https://mustache.github.io/mustache.5.html).
