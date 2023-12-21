


print('testing local variables and environments')

local debug = require"debug"

local tracegc = require"tracegc"




local function f(x) x = nil; return x end
assert(f(10) == nil)

local function f() local x; return x end
assert(f(10) == nil)

local function f(x) x = nil; local y; return x, y end
assert(f(10) == nil and select(2, f(20)) == nil)

do
  local i = 10
  do local i = 100; assert(i==100) end
  do local i = 1000; assert(i==1000) end
  assert(i == 10)
  if i ~= 10 then
    local i = 20
  else
    local i = 30
    assert(i == 30)
  end
end



f = nil

local f
local x = 1

a = nil
load('local a = {}')()
assert(a == nil)

function f (a)
  local _1, _2, _3, _4, _5
  local _6, _7, _8, _9, _10
  local x = 3
  local b = a
  local c,d = a,b
  if (d == b) then
    local x = 'q'
    x = b
    assert(x == 2)
  else
    assert(nil)
  end
  assert(x == 3)
  local f = 10
end

local b=10
local a; repeat local b; a,b=1,2; assert(a+1==b); until a+b==3


assert(x == 1)

f(2)
assert(type(f) == 'function')


local function getenv (f)
  local a,b = debug.getupvalue(f, 1)
  assert(a == '_ENV')
  return b
end


assert(getenv(load"a=3") == _G)
local c = {}; local f = load("a = 3", nil, nil, c)
assert(getenv(f) == c)
assert(c.a == nil)
f()
assert(c.a == 3)


do
  local i = 2
  local p = 4    
  repeat
    for j=-3,3 do
      assert(load(string.format([[local a=%s;
                                        a=a+%s;
                                        assert(a ==2^%s)]], j, p-j, i), '')) ()
      assert(load(string.format([[local a=%s;
                                        a=a-%s;
                                        assert(a==-2^%s)]], -j, p-j, i), '')) ()
      assert(load(string.format([[local a,b=0,%s;
                                        a=b-%s;
                                        assert(a==-2^%s)]], -j, p-j, i), '')) ()
    end
    p = 2 * p;  i = i + 1
  until p <= 0
end

print'+'


if rawget(_G, "T") then
  
  collectgarbage("stop")   
  local a = {[{}] = 4, [3] = 0, alo = 1,
             a1234567890123456789012345678901234567890 = 10}

  local t = T.querytab(a)

  for k,_ in pairs(a) do a[k] = undef end
  collectgarbage()   
  for i=0,t-1 do
    local k = querytab(a, i)
    assert(k == nil or type(k) == 'number' or k == 'alo')
  end

  
  local a = {}
  local function additems ()
    a.x = true; a.y = true; a.z = true
    a[1] = true
    a[2] = true
  end
  for i = 1, math.huge do
    T.alloccount(i)
    local st, msg = pcall(additems)
    T.alloccount()
    local count = 0
    for k, v in pairs(a) do
      assert(a[k] == v)
      count = count + 1
    end
    if st then assert(count == 5); break end
  end
end




assert(_ENV == _G)

do
local dummy
local _ENV = (function (...) return ... end)(_G, dummy)   

do local _ENV = {assert=assert}; assert(true) end
local mt = {_G = _G}
local foo,x
A = false    
do local _ENV = mt
  function foo (x)
    A = x
    do local _ENV =  _G; A = 1000 end
    return function (x) return A .. x end
  end
end
assert(getenv(foo) == mt)
x = foo('hi'); assert(mt.A == 'hi' and A == 1000)
assert(x('*') == mt.A .. '*')

do local _ENV = {assert=assert, A=10};
  do local _ENV = {assert=assert, A=20};
    assert(A==20);x=A
  end
  assert(A==10 and x==20)
end
assert(x==20)

A = nil


do   
  local a<const>, b, c<const> = 10, 20, 30
  b = a + c + b    
  assert(a == 10 and b == 60 and c == 30)
  local function checkro (name, code)
    local st, msg = load(code)
    local gab = string.format("attempt to assign to const variable '%s'", name)
    assert(not st and string.find(msg, gab))
  end
  checkro("y", "local x, y <const>, z = 10, 20, 30; x = 11; y = 12")
  checkro("x", "local x <const>, y, z <const> = 10, 20, 30; x = 11")
  checkro("z", "local x <const>, y, z <const> = 10, 20, 30; y = 10; z = 11")
  checkro("foo", "local foo <const> = 10; function foo() end")
  checkro("foo", "local foo <const> = {}; function foo() end")

  checkro("z", [[
    local a, z <const>, b = 10;
    function foo() a = 20; z = 32; end
  ]])

  checkro("var1", [[
    local a, var1 <const> = 10;
    function foo() a = 20; z = function () var1 = 12; end  end
  ]])
end


print"testing to-be-closed variables"

local function stack(n) n = ((n == 0) or stack(n - 1)) end

local function func2close (f, x, y)
  local obj = setmetatable({}, {__close = f})
  if x then
    return x, obj, y
  else
    return obj
  end
end


do
  local a = {}
  do
    local b <close> = false   
    local x <close> = setmetatable({"x"}, {__close = function (self)
                                                   a[#a + 1] = self[1] end})
    local w, y <close>, z = func2close(function (self, err)
                                assert(err == nil); a[#a + 1] = "y"
                              end, 10, 20)
    local c <close> = nil  
    a[#a + 1] = "in"
    assert(w == 10 and z == 20)
  end
  a[#a + 1] = "out"
  assert(a[1] == "in" and a[2] == "y" and a[3] == "x" and a[4] == "out")
end

do
  local X = false

  local x, closescope = func2close(function (_, msg)
    stack(10);
    assert(msg == nil)
    X = true
  end, 100)
  assert(x == 100);  x = 101;   

  
  local function foo (x)
    local _ <close> = closescope
    return x, X, 23
  end

  local a, b, c = foo(1.5)
  assert(a == 1.5 and b == false and c == 23 and X == true)

  X = false
  foo = function (x)
    local _<close> = func2close(function (_, msg)
      
      
      assert(debug.getinfo(2).name == "foo")
      assert(msg == nil)
    end)
    local  _<close> = closescope
    local y = 15
    return y
  end

  assert(foo() == 15 and X == true)

  X = false
  foo = function ()
    local x <close> = closescope
    return x
  end

  assert(foo() == closescope and X == true)

end





do
  local flag = false
  local x = setmetatable({},
    {__close = function() assert(flag == false); flag = true end})
  local y <const> = nil
  local z <const> = nil
  do
      local a <close> = x
  end
  assert(flag)   
end

do
  
  local flag = false
  local x = setmetatable({},
    {__close = function () assert(flag == false); flag = true end})
  
  local function a ()
    return (function () return nil end), nil, nil, x
  end
  local v <const> = 1
  local w <const> = 1
  local x <const> = 1
  local y <const> = 1
  local z <const> = 1
  for k in a() do
      a = k
  end    
  assert(flag)   
end



do
  
  local X, Y
  local function foo ()
    local _ <close> = func2close(function () Y = 10 end)
    assert(X == true and Y == nil)    
    return 1,2,3
  end

  local function bar ()
    local _ <close> = func2close(function () X = false end)
    X = true
    do
      return foo()    
    end
  end

  local a, b, c, d = bar()
  assert(a == 1 and b == 2 and c == 3 and X == false and Y == 10 and d == nil)
end


do
  
  
  

  local closed = false

  local function foo ()
    return function () return true end, 0, 0,
           func2close(function () closed = true end)
  end

  local function tail() return closed end

  local function foo1 ()
    for k in foo() do return tail() end
  end

  assert(foo1() == false)
  assert(closed == true)
end


do
  
  

  local closed = false

  local o1 = setmetatable({}, {__close=function() closed = true end})

  local function test()
    for k, v in next, {}, nil, o1 do
      local function f() return k end   
      break
    end
    assert(closed)
  end

  test()
end


do print("testing errors in __close")

  
  local function foo ()

    local x <close> =
      func2close(function (self, msg)
        assert(string.find(msg, "@y"))
        error("@x")
      end)

    local x1 <close> =
      func2close(function (self, msg)
        assert(string.find(msg, "@y"))
      end)

    local gc <close> = func2close(function () collectgarbage() end)

    local y <close> =
      func2close(function (self, msg)
        assert(string.find(msg, "@z"))  
        error("@y")
      end)

    local z <close> =
      func2close(function (self, msg)
        assert(msg == nil)
        error("@z")
      end)

    return 200
  end

  local stat, msg = pcall(foo, false)
  assert(string.find(msg, "@x"))


  
  local function foo ()

    local x <close> =
      func2close(function (self, msg)
        
        
        assert(debug.getinfo(2).name == "pcall")
        assert(string.find(msg, "@x1"))
      end)

    local x1 <close> =
      func2close(function (self, msg)
        assert(debug.getinfo(2).name == "pcall")
        assert(string.find(msg, "@y"))
        error("@x1")
      end)

    local gc <close> = func2close(function () collectgarbage() end)

    local y <close> =
      func2close(function (self, msg)
        assert(debug.getinfo(2).name == "pcall")
        assert(string.find(msg, "@z"))
        error("@y")
      end)

    local first = true
    local z <close> =
      func2close(function (self, msg)
        assert(debug.getinfo(2).name == "pcall")
        
        assert(first and msg == 4)
        first = false
        error("@z")
      end)

    error(4)    
  end

  local stat, msg = pcall(foo, true)
  assert(string.find(msg, "@x1"))

  
  local function foo (...)
    do
      local x1 <close> =
        func2close(function (self, msg)
          assert(string.find(msg, "@X"))
          error("@Y")
        end)

      local x123 <close> =
        func2close(function (_, msg)
          assert(msg == nil)
          error("@X")
        end)
    end
    os.exit(false)    
  end

  local st, msg = xpcall(foo, debug.traceback)
  assert(string.match(msg, "^[^ ]* @Y"))

  
  local function foo (...)
    local x123 <close> = func2close(function () error("@x123") end)
  end

  local st, msg = xpcall(foo, debug.traceback)
  assert(string.match(msg, "^[^ ]* @x123"))
  assert(string.find(msg, "in metamethod 'close'"))
end


do   
  local function foo ()
    local x <close> = {}
    os.exit(false)    
  end
  local stat, msg = pcall(foo)
  assert(not stat and
    string.find(msg, "variable 'x' got a non%-closable value"))

  local function foo ()
    local xyz <close> = setmetatable({}, {__close = print})
    getmetatable(xyz).__close = nil   
  end
  local stat, msg = pcall(foo)
  assert(not stat and string.find(msg, "metamethod 'close'"))

  local function foo ()
    local a1 <close> = func2close(function (_, msg)
      assert(string.find(msg, "number value"))
      error(12)
    end)
    local a2 <close> = setmetatable({}, {__close = print})
    local a3 <close> = func2close(function (_, msg)
      assert(msg == nil)
      error(123)
    end)
    getmetatable(a2).__close = 4   
  end
  local stat, msg = pcall(foo)
  assert(not stat and msg == 12)
end


do   
  local track = {}
  local function foo ()
    local x <close> = func2close(function ()
      local xx <close> = func2close(function (_, msg)
        assert(msg == nil)
        track[#track + 1] = "xx"
      end)
      track[#track + 1] = "x"
    end)
    track[#track + 1] = "foo"
    return 20, 30, 40
  end
  local a, b, c, d = foo()
  assert(a == 20 and b == 30 and c == 40 and d == nil)
  assert(track[1] == "foo" and track[2] == "x" and track[3] == "xx")

  
  local track = {}
  local function foo ()
    local x0 <close> = func2close(function (_, msg)
      assert(msg == 202)
        track[#track + 1] = "x0"
    end)
    local x <close> = func2close(function ()
      local xx <close> = func2close(function (_, msg)
        assert(msg == 101)
        track[#track + 1] = "xx"
        error(202)
      end)
      track[#track + 1] = "x"
      error(101)
    end)
    track[#track + 1] = "foo"
    return 20, 30, 40
  end
  local st, msg = pcall(foo)
  assert(not st and msg == 202)
  assert(track[1] == "foo" and track[2] == "x" and track[3] == "xx" and
         track[4] == "x0")
end


local function checktable (t1, t2)
  assert(#t1 == #t2)
  for i = 1, #t1 do
    assert(t1[i] == t2[i])
  end
end


do    

   
  local function overflow (n)
    overflow(n + 1)
  end

  
  
  local function errorh (m)
    assert(string.find(m, "stack overflow"))
    local x <close> = func2close(function (o) o[1] = 10 end)
    return x
  end

  local flag
  local st, obj
  
  local co = coroutine.wrap(function ()
    
    local y <close> = func2close(function (obj, msg)
      assert(msg == nil)
      obj[1] = 100
      flag = obj
    end)
    tracegc.stop()
    st, obj = xpcall(overflow, errorh, 0)
    tracegc.start()
  end)
  co()
  assert(not st and obj[1] == 10 and flag[1] == 100)
end


if rawget(_G, "T") then

  do
    
    

    
    collectgarbage(); collectgarbage(); collectgarbage()

    
    local function loop (n)
      if n < 400 then loop(n + 1) end
    end

    
    local o = setmetatable({}, {__close = function () loop(0) end})

    local script = [[toclose 2; settop 1; return 1]]

    assert(T.testC(script, o) == script)

  end


  
  local function foo ()
    local y <close> = func2close(function () T.alloccount() end)
    local x <close> = setmetatable({}, {__close = function ()
      T.alloccount(0); local x = {}   
    end})
    error(1000)   
  end

  stack(5)    

  
  
  local _, msg = pcall(foo)
  assert(msg == "not enough memory")

  local closemsg
  local close = func2close(function (self, msg)
    T.alloccount()
    closemsg = msg
  end)

  
  local function enter (count)
    stack(10)   
    T.alloccount(count)
    closemsg = nil
    return close
  end

  local function test ()
    local x <close> = enter(0)   
    local y = {}    
  end

  local _, msg = pcall(test)
  assert(msg == "not enough memory" and closemsg == "not enough memory")


  
  local function test ()
    local xxx <close> = func2close(function (self, msg)
      assert(msg == "not enough memory");
      error(1000)   
    end)
    local xx <close> = func2close(function (self, msg)
      assert(msg == "not enough memory");
    end)
    local x <close> = enter(0)   
    local y = {}   
  end

  local _, msg = pcall(test)
  assert(msg == 1000 and closemsg == "not enough memory")

  do    
    collectgarbage()
    local s = string.rep('a', 10000)    
    local m = T.totalmem()
    collectgarbage("stop")
    s = string.upper(s)    
    
    assert(T.totalmem() - m <= 11000)
    collectgarbage("restart")
  end

  do   
    local lim = 10000           
    local extra = 2000          

    local s = string.rep("a", lim)

    
    local a = {s, s}

    collectgarbage(); collectgarbage()

    local m = T.totalmem()
    collectgarbage("stop")

    
    T. totalmem(m + extra)
    assert(not pcall(table.concat, a))
    
    assert(T.totalmem() - m <= extra)

    
    T. totalmem(m + lim + extra)
    assert(not pcall(table.concat, a))
    
    assert(T.totalmem() - m <= extra)

    
    T.totalmem(m + 2 * lim + extra)
    assert(not pcall(table.concat, a))
    
    assert(T.totalmem() - m <= extra)

    
    T.totalmem(m + 4*lim + extra)
    assert(#table.concat(a) == 2*lim)

    T.totalmem(0)     
    collectgarbage("restart")

    print'+'
  end


  do
    
    local trace = {}

    local function hook (event)
      trace[#trace + 1] = event .. " " .. (debug.getinfo(2).name or "?")
    end

    
    local x = func2close(function (_,msg)
      trace[#trace + 1] = "x"
    end)

    local y = func2close(function (_,msg)
      trace[#trace + 1] = "y"
    end)

    debug.sethook(hook, "r")
    local t = {T.testC([[
       toclose 2      # x
       pushnum 10
       pushint 20
       toclose 3      # y
       return 2
    ]], x, y)}
    debug.sethook()

    
    checktable(trace,
       {"return sethook", "y", "return ?", "x", "return ?", "return testC"})
    
    checktable(t, {10, 20})
  end
end


do   
  local trace = {}

  local function hook (event)
    trace[#trace + 1] = event .. " " .. debug.getinfo(2).name
  end

  local function foo (...)
    local x <close> = func2close(function (_,msg)
      trace[#trace + 1] = "x"
    end)

    local y <close> = func2close(function (_,msg)
      debug.sethook(hook, "r")
    end)

    return ...
  end

  local t = {foo(10,20,30)}
  debug.sethook()
  checktable(t, {10, 20, 30})
  checktable(trace,
    {"return sethook", "return close", "x", "return close", "return foo"})
end


print "to-be-closed variables in coroutines"

do
  

  local trace = {}
  local co = coroutine.wrap(function ()

    trace[#trace + 1] = "nowX"

    
    local x <close> = func2close(function (_, msg)
      assert(msg == nil)
      trace[#trace + 1] = "x1"
      coroutine.yield("x")
      trace[#trace + 1] = "x2"
    end)

    return pcall(function ()
      do   
        local z <close> = func2close(function (_, msg)
          assert(msg == nil)
          trace[#trace + 1] = "z1"
          coroutine.yield("z")
          trace[#trace + 1] = "z2"
        end)
      end

      trace[#trace + 1] = "nowY"

      
      local y <close> = func2close(function(_, msg)
        assert(msg == nil)
        trace[#trace + 1] = "y1"
        coroutine.yield("y")
        trace[#trace + 1] = "y2"
      end)

      return 10, 20, 30
    end)
  end)

  assert(co() == "z")
  assert(co() == "y")
  assert(co() == "x")
  checktable({co()}, {true, 10, 20, 30})
  checktable(trace, {"nowX", "z1", "z2", "nowY", "y1", "y2", "x1", "x2"})

end


do
  
  

  local extrares    

  local function check (body, extra, ...)
    local t = table.pack(...)   
    local co = coroutine.wrap(body)
    if extra then
      extrares = co()    
    end
    local res = table.pack(co())   
    assert(res.n == 2 and res[2] == nil)
    local res2 = table.pack(co())   
    assert(res2.n == t.n)
    for i = 1, #t do
      if t[i] == "x" then
        assert(res2[i] == res[1])    
      else
        assert(res2[i] == t[i])
      end
    end
  end

  local function foo ()
    local x <close> = func2close(coroutine.yield)
    local extra <close> = func2close(function (self)
      assert(self == extrares)
      coroutine.yield(100)
    end)
    extrares = extra
    return table.unpack{10, x, 30}
  end
  check(foo, true, 10, "x", 30)
  assert(extrares == 100)

  local function foo ()
    local x <close> = func2close(coroutine.yield)
    return
  end
  check(foo, false)

  local function foo ()
    local x <close> = func2close(coroutine.yield)
    local y, z = 20, 30
    return x
  end
  check(foo, false, "x")

  local function foo ()
    local x <close> = func2close(coroutine.yield)
    local extra <close> = func2close(coroutine.yield)
    return table.unpack({}, 1, 100)   
  end
  check(foo, true, table.unpack({}, 1, 100))

end

do
  

  local co = coroutine.wrap(function ()

    local function foo (err)

      local z <close> = func2close(function(_, msg)
        assert(msg == nil or msg == err + 20)
        coroutine.yield("z")
        return 100, 200
      end)

      local y <close> = func2close(function(_, msg)
        
        assert(msg == err or (msg == nil and err == 1))
        coroutine.yield("y")
        if err then error(err + 20) end   
      end)

      local x <close> = func2close(function(_, msg)
        assert(msg == err or (msg == nil and err == 1))
        coroutine.yield("x")
        return 100, 200
      end)

      if err == 10 then error(err) else return 10, 20 end
    end

    coroutine.yield(pcall(foo, nil))  
    coroutine.yield(pcall(foo, 1))    
    return pcall(foo, 10)     
  end)

  local a, b = co()   
  assert(a == "x" and b == nil)    
  a, b = co()
  assert(a == "y" and b == nil)    
  a, b = co()
  assert(a == "z" and b == nil)    
  local a, b, c = co()
  assert(a and b == 10 and c == 20)   

  local a, b = co()   
  assert(a == "x" and b == nil)    
  a, b = co()
  assert(a == "y" and b == nil)    
  a, b = co()
  assert(a == "z" and b == nil)    
  local st, msg = co()             
  assert(not st and msg == 21)

  local a, b = co()    
  assert(a == "x" and b == nil)    
  a, b = co()
  assert(a == "y" and b == nil)    
  a, b = co()
  assert(a == "z" and b == nil)    
  local st, msg = co()    
  assert(not st and msg == 10 + 20)

end


do
  
  local x = false
  local y = false
  local co = coroutine.wrap(function ()
    local xv <close> = func2close(function () x = true end)
    do
      local yv <close> = func2close(function () y = true end)
      coroutine.yield(100)   
    end
    coroutine.yield(200)   
    error(23)              
  end)

  local b = co()
  assert(b == 100 and not x and not y)
  b = co()
  assert(b == 200 and not x and y)
  local a, b = pcall(co)
  assert(not a and b == 23 and x and y)
end


do

  
  local x = 0
  local co = coroutine.wrap(function ()
    local xx <close> = func2close(function (_, msg)
      x = x + 1;
      assert(string.find(msg, "@XXX"))
      error("@YYY")
    end)
    local xv <close> = func2close(function () x = x + 1; error("@XXX") end)
    coroutine.yield(100)
    error(200)
  end)
  assert(co() == 100); assert(x == 0)
  local st, msg = pcall(co); assert(x == 2)
  assert(not st and string.find(msg, "@YYY"))   

  local x = 0
  local y = 0
  co = coroutine.wrap(function ()
    local xx <close> = func2close(function (_, err)
      y = y + 1;
      assert(string.find(err, "XXX"))
      error("YYY")
    end)
    local xv <close> = func2close(function ()
      x = x + 1; error("XXX")
    end)
    coroutine.yield(100)
    return 200
  end)
  assert(co() == 100); assert(x == 0)
  local st, msg = pcall(co)
  assert(x == 1 and y == 1)
  
  assert(not st and string.find(msg, "%w+%.%w+:%d+: YYY"))

end



local co
co = coroutine.wrap(function()
  
  local x <close> = func2close(function () os.exit(false) end)
  co = nil
  coroutine.yield()
end)
co()                 
assert(co == nil)    
collectgarbage()


if rawget(_G, "T") then
  print("to-be-closed variables x coroutines in C")
  do
    local token = 0
    local count = 0
    local f = T.makeCfunc[[
      toclose 1
      toclose 2
      return .
    ]]

    local obj = func2close(function (_, msg)
      count = count + 1
      token = coroutine.yield(count, token)
    end)

    local co = coroutine.wrap(f)
    local ct, res = co(obj, obj, 10, 20, 30, 3)   
    
    assert(ct == 1 and res == 0)
    
    ct, res = co(100)
    assert(ct == 2 and res == 100)
    res = {co(200)}      
    assert(res[1] == 10 and res[2] == 20 and res[3] == 30 and res[4] == nil)
    assert(token == 200)
  end

  do
    local f = T.makeCfunc[[
      toclose 1
      return .
    ]]

    local obj = func2close(function ()
      local temp
      local x <close> = func2close(function ()
        coroutine.yield(temp)
        return 1,2,3    
      end)
      temp = coroutine.yield("closing obj")
      return 1,2,3    
    end)

    local co = coroutine.wrap(f)
    local res = co(obj, 10, 30, 1)   
    assert(res == "closing obj")
    res = co("closing x")
    assert(res == "closing x")
    res = {co()}
    assert(res[1] == 30 and res[2] == nil)
  end

  do
    
    local f = T.makeCfunc[[
      toclose 1
      closeslot 1
    ]]
    local obj = func2close(coroutine.yield)
    local co = coroutine.create(f)
    local st, msg = coroutine.resume(co, obj)
    assert(not st and string.find(msg, "attempt to yield across"))

    
    local f = T.makeCfunc[[
      toclose 1
    ]]
    local st, msg = pcall(f, obj)
    assert(not st and string.find(msg, "attempt to yield from outside"))
  end
end




do
  local numopen = 0
  local function open (x)
    numopen = numopen + 1
    return
      function ()   
        x = x - 1
        if x > 0 then return x end
      end,
      nil,   
      nil,   
      func2close(function () numopen = numopen - 1 end)   
  end

  local s = 0
  for i in open(10) do
     s = s + i
  end
  assert(s == 45 and numopen == 0)

  local s = 0
  for i in open(10) do
     if i < 5 then break end
     s = s + i
  end
  assert(s == 35 and numopen == 0)

  local s = 0
  for i in open(10) do
    for j in open(10) do
       if i + j < 5 then goto endloop end
       s = s + i
    end
  end
  ::endloop::
  assert(s == 375 and numopen == 0)
end

print('OK')

return 5,f

end   

