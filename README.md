# elua

Embedded Lua templating

## Install

```bash
$ luarocks install --server=http://rocks.moonscript.org elua
```

## Tutorial

```lua
local elua = require "elua"
local template = elua.compile([[
  Hello <%= name %>,
  Here are your items:
  <% for i, item in pairs(items) do %>
   * <%= item -%>
  <% end %>
]])

print(template({
  name = "leafo",
  items = { "Shoe", "Reflector", "Scarf" }
}))

```

## Reference

The following tags are supported

* `<% lua_code %>` runs lua code verbatim
* `<%= lua_expression %>` writes result of expression to output, HTML escaped
* `<%- lua_expression %>` same as above but with no HTML escaping

Any of the embedded Lua tags can use the `-%>` closing tag to suppress a
following newline if there is one, for example: `<%= 'hello' -%>`.

The module can be loaded by doing:

```lua
local elua = require "elua"
```

### Methods

#### `func = elua.compile(template_string)`

Compiles the template into a function, the returned function can be called to
render the template. The function takes one argument: a table to use as the
environment within the template. `_G` is used to look up a variable if it can't
be found in the environment.

#### `result = elua.render(template_string, env)`

Compiles and renders the template in a single call. If you are concerned about
high performance this should be avoided in favor of `compile` if it's possible
to cache the compiled template.

### Errors

If any of the methods fail they will return `nil`, followed by the error
message.

### How it works

* Templates are transparently translated into Lua code and then loaded as a
  function. Rendering a compiled template is very fast.
* Any compile time errors are rewritten to show the original source position in
  the template.
* The parser is aware of strings so you can put closing tags inside of a string
  literal without any problems.

## License

MIT, Copyright (C) 2013 by Leaf Corcoran

