#include "sum.h"
#include <stdio.h>

/* 
 * 所有注册给Lua的C函数具有
 * "typedef int (*lua_CFunction) (lua_State *L);"的原型。
 */
static int calc_sum(lua_State *L)
{
    int ind = lua_gettop(L);
    int size = luaL_checknumber(L, ind);   //how many number to sum up.
    
    int ret = 0; 

    lua_pop(L, 1);                                      
    for (int i = 1; i <= size; i++){
        lua_pushnumber(L, i);
        lua_gettable(L, -2);

        ind = lua_gettop(L);
        int tmp = luaL_checknumber(L, ind);
        lua_pop(L, 1);

        ret += tmp;
    }

    lua_pushnumber(L, ret);        //push back the result.
    return 1;                       //return the number of results.
}

//static int calc_sum


static int calc_square(lua_State *L)
{
    return 0;  
}

/*
 * 需要一个"luaL_Reg"类型的结构体，其中每一个元素对应一个提供给Lua的函数。
 * 每一个元素中包含此函数在Lua中的名字，以及该函数在C库中的函数指针。
 * 最后一个元素为“哨兵元素”（两个"NULL"），用于告诉Lua没有其他的函数需要注册。
 * */
static luaL_Reg mylibs[] = {
    {"sum", calc_sum},
    {"sqr", calc_square},
    {NULL, NULL}
};

/*
 *  此函数为C库中的“特殊函数”。
 *  通过调用它注册所有C库中的函数，并将它们存储在适当的位置。
 *  此函数的命名规则应遵循：
 *      1、使用"luaopen_"作为前缀。
 *      2、前缀之后的名字将作为"require"的参数。
 * */
int luaopen_libsum(lua_State* L)
{
        /* 
         * Lua 5.1:
         *  void luaL_register(lua_State *L, const char *libname, const luaL_Reg *l);
         *
         * Lua 5.2:
         * void luaL_newlib(lua_State *L, const luaL_Reg l[]);
         * 创建一个新的"table"，并将"l"中所列出的函数注册为"table"的域。
         * */
        luaL_register(L, "libsum", mylibs);
        return 1;
}

