package = "elua"
version = "dev-1"

source = {
  url = "git://github.com/leafo/elua.git"
}

description = {
  summary = "Embedded templates for Lua",
  detailed = [[
    Allows you to render ERB style templates but with Lua. Supports <% %>, <%=
    %> and <%- %> tags (with optional newline slurping) for embedding code.
  ]],
  homepage = "https://github.com/leafo/elua",
  maintainer = "Leaf Corcoran <leafot@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["elua"] = "elua.lua",
  },
}

