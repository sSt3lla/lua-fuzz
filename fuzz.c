#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

__AFL_FUZZ_INIT();

#pragma clang optimize off
int main(void) {
    #ifdef __AFL_HAVE_MANUAL_CONTROL
        __AFL_INIT();
    #endif

    unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

    while (__AFL_LOOP(10000)) {
        int len = __AFL_FUZZ_TESTCASE_LEN;

        lua_State *L = luaL_newstate(); // Create a Lua state
        luaL_openlibs(L); // Open Lua standard libraries

        if (luaL_dostring(L, buf)) {
            fprintf(stderr, "Error running Lua code: %s\n", lua_tostring(L, -1));
            lua_close(L);
            return 1;
        }

        lua_close(L);
    }
    return 0;
}