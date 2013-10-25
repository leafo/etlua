package = "elua"
version = "dev-1"

source = {
	url = "git://github.com/leafo/elua.git"
}

description = {
	summary = "Embedded templates for Lua",
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

