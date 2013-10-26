
test:
	busted

build::
	moonc etlua.moon

local: build
	luarocks make --local etlua-dev-1.rockspec
