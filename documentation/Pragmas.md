# Pragmas/Configuration variables

The syntax `{{% var: value}}` can be used to set template rendering configuration variables specific to Hummingbird Mustache. The only variable you can set at the moment is `CONTENT_TYPE`. This can be set to either to `HTML` or `TEXT` and defines how variables are escaped. A content type of `TEXT` means no variables are escaped and a content type of `HTML` will do HTML escaping of the rendered text. The content type defaults to `HTML`.

Given input object "<>", template `{{%CONTENT_TYPE: HTML}}{{.}}` will render as `&lt;&gt;` and `{{%CONTENT_TYPE: TEXT}}{{.}}` will render as `<>`.


