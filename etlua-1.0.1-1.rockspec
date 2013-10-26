package = "etlua"
version = "1.0.1-1"

source = {
  url = "git://github.com/leafo/etlua.git",
  branch = "v1.0.1"
}

description = {
  summary = "Embedded templates for Lua",
  detailed = [[
    Allows you to render ERB style templates but with Lua. Supports <% %>, <%=
    %> and <%- %> tags (with optional newline slurping) for embedding code.
  ]],
  homepage = "https://github.com/leafo/etlua",
  maintainer = "Leaf Corcoran <leafot@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["etlua"] = "etlua.lua",
  },
}

