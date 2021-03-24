#  Transforms

Transforms are specific to this implementation of Mustache. They are similar to Lambdas but instead of generating rendered text they allow you to transform an object into another. Transforms are formatted as a function call inside a tag eg
```
{{uppercase(string)}}
```
They can be applied to variable, section and inverted section tags. If you apply them to a section or inverted section tag the transform name should be included in the end section tag as well eg
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
  - equalzero: Returns if equal to zero
  - plusone: Add one to integer
  - minusone: Subtract one from integer
  - odd: return if integer is odd
  - even: return if integer is even
- Array
  - first: Return first element of array
  - last: Return last element of array
  - count: Return number of elements in array
  - empty: Returns if array is empty
  - reversed: Reverse array
  - sorted: If the elements of the array are comparable sort them
- Dictionary
  - count: Return number of elements in dictionary
  - empty: Returns if dictionary is empty
  - enumerated: Return dictionary as array of key, value pairs
  - sorted: If the keys are comparable return as array of key, value pairs sorted by key

If a transform is applied to an object that doesn't recognise it then `nil` is returned.

## Sequence context transforms

Sequence context transforms are transforms applied to the current position in the sequence. They are formatted as a function that takes no parameter eg
```
{{#array}}{{.}}{{^last()}}, {{/last()}}{{/array}}
```
This will render an array as a comma separated list. The inverted section of the `last()` transform ensures we don't add a comma after the last element.

The following sequence context transforms are available
- first: Is this the first element of the sequence
- last: Is this the last element of the sequence
- index: Returns the index of the element within the sequence
- odd: Returns if the index of the element is odd
- even: Returns if the index of the element is even

## Custom transforms

You can add transforms to your own objects. Conform the object to `HBMustacheTransformable` and provide an implementation of the function `transform`. eg 
```swift 
struct Object: HBMustacheTransformable {
    let either: Bool
    let or: Bool
    
    func transform(_ name: String) -> Any? {
        switch name {
        case "eitherOr":
            return either || or
        default:
            break
        }
        return nil
    }
}
```
When we render an instance of this object with `either` or `or` set to true using the following template it will render "Success".
```
{{#eitherOr(object)}}Success{{/eitherOr(object)}}
```
With this we have got around the fact it is not possible to do logical OR statements in Mustache.
