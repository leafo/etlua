
test:
	busted

build::
	moonc elua.moon

local: build
	luarocks make --local elua-dev-1.rockspec
