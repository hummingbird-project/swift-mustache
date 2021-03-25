#  Template Inheritance

Template inheritance is not part of the Mustache spec yet but it is a commonly implemented feature. Template inheritance allows you to override elements of an included partial. It allows you to create a base page template and override elements of it with your page content. A partial that includes overriding elements is indicated with a `{{<partial}}`. Note this is different from the normal partial reference which uses `>`. This is a section tag so needs a ending tag as well. Inside the section the tagged sections to override are added using the syntax `{{$tag}}contents{{/tag}}`. If your template and partial were as follows
```
{{! mypage.mustache }}
{{<base}}
{{$head}}<title>My page title</title>{{/head}}
{{$body}}Hello world{{/body}}
{{/base}}
```
```
{{! base.mustache }}
<html>
<head>
{{$head}}{{/head}}
</head>
<body>
{{$body}}Default text{{/body}}
</body>
</html>
```
You would get the following output when rendering `mypage.mustache`.
```
<html>
<head>
<title>My page title</title>
</head>
<body>
Hello world
</body>
```
Note the `{{$head}}` section in `base.mustache` is replaced with the `{{$head}}` section included inside the `{{<base}}` partial reference from `mypage.mustache`. The same occurs with the `{{$body}}` section. In that case though a default value is supplied for the situation where a `{{$body}}` section is not supplied. 

