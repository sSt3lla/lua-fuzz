




local debug = require "debug"

local function dostring(s) return assert(load(s))() end

print"testing debug library and debug information"

do
local a=1
end

assert(not debug.gethook())

local testline = 19         
local function test (s, l, p)     
  collectgarbage()   
  local function f (event, line)
    assert(event == 'line')
    local l = table.remove(l, 1)
    if p then print(l, line) end
    assert(l == line, "wrong trace!!")
  end
  debug.sethook(f,"l"); load(s)(); debug.sethook()
  assert(#l == 0)
end


do
  assert(not pcall(debug.getinfo, print, "X"))   
  assert(not pcall(debug.getinfo, 0, ">"))   
  assert(not debug.getinfo(1000))   
  assert(not debug.getinfo(-1))     
  local a = debug.getinfo(print)
  assert(a.what == "C" and a.short_src == "[C]")
  a = debug.getinfo(print, "L")
  assert(a.activelines == nil)
  local b = debug.getinfo(test, "SfL")
  assert(b.name == nil and b.what == "Lua" and b.linedefined == testline and
         b.lastlinedefined == b.linedefined + 10 and
         b.func == test and not string.find(b.short_src, "%["))
  assert(b.activelines[b.linedefined + 1] and
         b.activelines[b.lastlinedefined])
  assert(not b.activelines[b.linedefined] and
         not b.activelines[b.lastlinedefined + 1])
end



local a = "function f () end"
local function dostring (s, x) return load(s, x)() end
dostring(a)
assert(debug.getinfo(f).short_src == string.format('[string "%s"]', a))
dostring(a..string.format("; %s\n=1", string.rep('p', 400)))
assert(string.find(debug.getinfo(f).short_src, '^%[string [^\n]*%.%.%."%]$'))
dostring(a..string.format("; %s=1", string.rep('p', 400)))
assert(string.find(debug.getinfo(f).short_src, '^%[string [^\n]*%.%.%."%]$'))
dostring("\n"..a)
assert(debug.getinfo(f).short_src == '[string "..."]')
dostring(a, "")
assert(debug.getinfo(f).short_src == '[string ""]')
dostring(a, "@xuxu")
assert(debug.getinfo(f).short_src == "xuxu")
dostring(a, "@"..string.rep('p', 1000)..'t')
assert(string.find(debug.getinfo(f).short_src, "^%.%.%.p*t$"))
dostring(a, "=xuxu")
assert(debug.getinfo(f).short_src == "xuxu")
dostring(a, string.format("=%s", string.rep('x', 500)))
assert(string.find(debug.getinfo(f).short_src, "^x*$"))
dostring(a, "=")
assert(debug.getinfo(f).short_src == "")
_G.a = nil; _G.f = nil;
_G[string.rep("p", 400)] = nil


repeat
  local g = {x = function ()
    local a = debug.getinfo(2)
    assert(a.name == 'f' and a.namewhat == 'local')
    a = debug.getinfo(1)
    assert(a.name == 'x' and a.namewhat == 'field')
    return 'xixi'
  end}
  local f = function () return 1+1 and (not 1 or g.x()) end
  assert(f() == 'xixi')
  g = debug.getinfo(f)
  assert(g.what == "Lua" and g.func == f and g.namewhat == "" and not g.name)

  function f (x, name)   
    name = name or 'f'
    local a = debug.getinfo(1)
    assert(a.name == name and a.namewhat == 'local')
    return x
  end

  
  if 3>4 then break end; f()
  if 3<4 then a=1 else break end; f()
  while 1 do local x=10; break end; f()
  local b = 1
  if 3>4 then return math.sin(1) end; f()
  a = 3<4; f()
  a = 3<4 or 1; f()
  repeat local x=20; if 4>3 then f() else break end; f() until 1
  g = {}
  f(g).x = f(2) and f(10)+f(9)
  assert(g.x == f(19))
  function g(x) if not x then return 3 end return (x('a', 'x')) end
  assert(g(f) == 'a')
until 1

test([[if
math.sin(1)
then
  a=1
else
  a=2
end
]], {2,3,4,7})


test([[
local function foo()
end
foo()
A = 1
A = 2
A = 3
]], {2, 3, 2, 4, 5, 6})
_G.A = nil


test([[
if nil then
  a=1
else
  a=2
end
]], {2,5,6})

test([[a=1
repeat
  a=a+1
until a==3
]], {1,3,4,3,4})

test([[ do
  return
end
]], {2})

test([[local a
a=1
while a<=3 do
  a=a+1
end
]], {1,2,3,4,3,4,3,4,3,5})

test([[while math.sin(1) do
  if math.sin(1)
  then break
  end
end
a=1]], {1,2,3,6})

test([[for i=1,3 do
  a=i
end
]], {1,2,1,2,1,2,1,3})

test([[for i,v in pairs{'a','b'} do
  a=tostring(i) .. v
end
]], {1,2,1,2,1,3})

test([[for i=1,4 do a=1 end]], {1,1,1,1})

_G.a = nil


do   

  local a = {1, 2, 3, 10, 124, 125, 126, 127, 128, 129, 130,
             255, 256, 257, 500, 1000}
  local s = [[
     local b = {10}
     a = b[1] X + Y b[1]
     b = 4
  ]]
  for _, i in ipairs(a) do
    local subs = {X = string.rep("\n", i)}
    for _, j in ipairs(a) do
      subs.Y = string.rep("\n", j)
      local s = string.gsub(s, "[XY]", subs)
      test(s, {1, 2 + i, 2 + i + j, 2 + i, 2 + i + j, 3 + i + j})
    end
  end
end
_G.a = nil


do   
  local function checkactivelines (f, lines)
    local t = debug.getinfo(f, "SL")
    for _, l in pairs(lines) do
      l = l + t.linedefined
      assert(t.activelines[l])
      t.activelines[l] = undef
    end
    assert(next(t.activelines) == nil)   
  end

  checkactivelines(function (...)   
    
    
    
    local a = 20
    
    local b = 30
    
  end, {4, 6, 8})

  checkactivelines(function (a)
    
    
    local a = 20
    local b = 30
    
  end, {3, 4, 6})

  checkactivelines(function (a, b, ...) end, {0})

  checkactivelines(function (a, b)
  end, {1})

  for _, n in pairs{0, 1, 2, 10, 50, 100, 1000, 10000} do
    checkactivelines(
      load(string.format("%s return 1", string.rep("\n", n))),
      {n + 1})
  end

end

print'+'


assert(not pcall(debug.getlocal, 20, 1))
assert(not pcall(debug.setlocal, -1, 1, 10))



local function foo (a,b,...) local d, e end
local co = coroutine.create(foo)

assert(debug.getlocal(foo, 1) == 'a')
assert(debug.getlocal(foo, 2) == 'b')
assert(not debug.getlocal(foo, 3))
assert(debug.getlocal(co, foo, 1) == 'a')
assert(debug.getlocal(co, foo, 2) == 'b')
assert(not debug.getlocal(co, foo, 3))

assert(not debug.getlocal(print, 1))


local function foo () return (debug.getlocal(1, -1)) end
assert(not foo(10))



local function foo (a, ...)
  local t = table.pack(...)
  for i = 1, t.n do
    local n, v = debug.getlocal(1, -i)
    assert(n == "(vararg)" and v == t[i])
  end
  assert(not debug.getlocal(1, -(t.n + 1)))
  assert(not debug.setlocal(1, -(t.n + 1), 30))
  if t.n > 0 then
    (function (x)
      assert(debug.setlocal(2, -1, x) == "(vararg)")
      assert(debug.setlocal(2, -t.n, x) == "(vararg)")
     end)(430)
     assert(... == 430)
  end
end

foo()
foo(print)
foo(200, 3, 4)
local a = {}
for i = 