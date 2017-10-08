#include "hello.h"

#include <stdio.h>

static int hello(lua_State *L)
{
	lua_pushstring(L, "hello world!\n");
	return 1;
}

static luaL_Reg myapis[] = {
	{"pr_hello", hello},
	{NULL, NULL}
};


int luaopen_libhello(lua_State *L)
{
	luaL_register(L, "libhello", myapis);
	return 1;
}
