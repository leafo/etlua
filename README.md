# elua

Embedded Lua (5.1/5.2) templating 

## Tutorial

```lua
local elua = require "elua"
local template = elua.compile([[
  Hello <%= name %>,
  Here are your items:
  <% for i, item in pairs(items) do %>
   * <%= name -%>
  <% end %>
]])

print(template({
  name: "leafo",
  items: { "Shoe", "Reflector", "Scarf" }
}))

```

## Reference

The following tags are supported

* `<% lua_code %>` runs lua code verbatim
* `<%= lua_expression %>` writes result of expression to output, HTML escaped
* `<%- lua_expression %>` same as above but with no HTML escaping

Any of the embedded Lua tags can use the `-%>` closing tag to suppress a
following newline if there is one, for example: `<%= 'hello' -%>`.

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

## License

MIT

