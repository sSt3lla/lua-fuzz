


if _soft then
  return 'a'
end

print "testing large tables"

local debug = require"debug" 

local lim = 2^18 + 1000
local prog = { "local y = {0" }
for i = 1, lim do prog[#prog + 1] = i  end
prog[#prog + 1] = "}\n"
prog[#prog + 1] = "X = y\n"
prog[#prog + 1] = ("assert(X[%d] == %d)"):format(lim - 1, lim - 2)
prog[#prog + 1] = "return 0"
prog = table.concat(prog, ";")

local env = {string = string, assert = assert}
local f = assert(load(prog, nil, nil, env))

f()
assert(env.X[lim] == lim - 1 and env.X[lim + 1] == lim)
for k in pairs(env) do env[k] = undef end


setmetatable(env, {
  __index = function (t, n) coroutine.yield('g'); return _G[n] end,
  __newindex = function (t, n, v) coroutine.yield('s'); _G[n] = v end,
})

X = nil
local co = coroutine.wrap(f)
assert(co() == 's')
assert(co() == 'g')
assert(co() == 'g')
assert(co() == 0)

assert(X[lim] == lim - 1 and X[lim + 1] == lim)


getmetatable(env).__index = function () end
getmetatable(env).__newindex = function () end
local e, m = pcall(f)
assert(not e and m:find("global 'X'"))


getmetatable(env).__newindex = function () error("hi") end
local e, m = xpcall(f, debug.traceback)
assert(not e and m:find("'newindex'"))

f, X = nil

coroutine.yield'b'

if 2^32 == 0 then   

print "testing string length overflow"

local repstrings = 192          
local ssize = math.ceil(2.0^32 / repstrings) + 1   

assert(repstrings * ssize > 2.0^32)  

local longs = string.rep("\0", ssize)   


local rep = assert(load(
  "local a = ...; return " .. string.rep("a", repstrings, "..")))

local a, b = pcall(rep, longs)   


assert(not a and string.find(b, "overflow"))

end   

print'OK'

return 'a'
