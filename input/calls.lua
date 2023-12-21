


print("testing functions and calls")

local debug = require "debug"



assert(type(1<2) == 'boolean')
assert(type(true) == 'boolean' and type(false) == 'boolean')
assert(type(nil) == 'nil'
   and type(-3) == 'number'
   and type'x' == 'string'
   and type{} == 'table'
   and type(type) == 'function')

assert(type(assert) == type(print))
local function f (x) return a:x (x) end
assert(type(f) == 'function')
assert(not pcall(type))



fact = false
do
  local res = 1
  local function fact (n)
    if n==0 then return res
    else return n*fact(n-1)
    end
  end
  assert(fact(5) == 120)
end
assert(fact == false)
fact = nil


local a = {i = 10}
local self = 20
function a:x (x) return x+self.i end
function a.y (x) return x+self end

assert(a:x(1)+10 == a.y(1))

a.t = {i=-100}
a["t"].x = function (self, a,b) return self.i+a+b end

assert(a.t:x(2,3) == -95)

do
  local a = {x=0}
  function a:add (x) self.x, a.y = self.x+x, 20; return self end
  assert(a:add(10):add(20):add(30).x == 60 and a.y == 20)
end

local a = {b={c={}}}

function a.b.c.f1 (x) return x+1 end
function a.b.c:f2 (x,y) self[x] = y end
assert(a.b.c.f1(4) == 5)
a.b.c:f2('k', 12); assert(a.b.c.k == 12)

print('+')

t = nil   
function f(a,b,c) local d = 'a'; t={a,b,c,d} end

f(      
  1,2)
assert(t[1] == 1 and t[2] == 2 and t[3] == nil and t[4] == 'a')
f(1,2,   
      3,4)
assert(t[1] == 1 and t[2] == 2 and t[3] == 3 and t[4] == 'a')

t = nil   

function fat(x)
  if x <= 1 then return 1
  else return x*load("return fat(" .. x-1 .. ")", "")()
  end
end

assert(load "load 'assert(fat(6)==720)' () ")()
a = load('return fat(5), 3')
local a,b = a()
assert(a == 120 and b == 3)
fat = nil
print('+')

local function err_on_n (n)
  if n==0 then error(); exit(1);
  else err_on_n (n-1); exit(1);
  end
end

do
  local function dummy (n)
    if n > 0 then
      assert(not pcall(err_on_n, n))
      dummy(n-1)
    end
  end

  dummy(10)
end

_G.deep = nil   

function deep (n)
  if n>0 then deep(n-1) end
end
deep(10)
deep(180)


print"testing tail calls"

function deep (n) if n>0 then return deep(n-1) else return 101 end end
assert(deep(30000) == 101)
a = {}
function a:deep (n) if n>0 then return self:deep(n-1) else return 101 end end
assert(a:deep(30000) == 101)

do   
  local function foo (x, ...) local a = {...}; return x, a[1], a[2] end

  local function foo1 (x) return foo(10, x, x + 1) end

  local a, b, c = foo1(-2)
  assert(a == 10 and b == -2 and c == -1)

  
  local t = setmetatable({}, {__call = foo})
  local function foo2 (x) return t(10, x) end
  a, b, c = foo2(100)
  assert(a == t and b == 10 and c == 100)

  a, b = (function () return foo() end)()
  assert(a == nil and b == nil)

  local X, Y, A
  local function foo (x, y, ...) X = x; Y = y; A = {...} end
  local function foo1 (...) return foo(...) end

  local a, b, c = foo1()
  assert(X == nil and Y == nil and #A == 0)

  a, b, c = foo1(10)
  assert(X == 10 and Y == nil and #A == 0)

  a, b, c = foo1(10, 20)
  assert(X == 10 and Y == 20 and #A == 0)

  a, b, c = foo1(10, 20, 30)
  assert(X == 10 and Y == 20 and #A == 1 and A[1] == 30)
end


do   
  local function loop ()
    assert(pcall(loop))
  end

  local err, msg = xpcall(loop, loop)
  assert(not err and string.find(msg, "error"))
end



do   
  local n = 10000   

  local function foo ()
    if n == 0 then return 1023
    else n = n - 1; return foo()
    end
  end

  
  for i = 1, 100 do
    foo = setmetatable({}, {__call = foo})
  end

  
  
  assert(coroutine.wrap(function() return foo() end)() == 1023)
end

print('+')


do  
  local N = 20
  local u = table.pack
  for i = 1, N do
    u = setmetatable({i}, {__call = u})
  end

  local Res = u("a", "b", "c")

  assert(Res.n == N + 3)
  for i = 1, N do
    assert(Res[i][1] == i)
  end
  assert(Res[N + 1] == "a" and Res[N + 2] == "b" and Res[N + 3] == "c")
end


a = nil
(function (x) a=x end)(23)
assert(a == 23 and (function (x) return x*2 end)(20) == 40)





local Z = function (le)
      local function a (f)
        return le(function (x) return f(f)(x) end)
      end
      return a(a)
    end




local F = function (f)
      return function (n)
               if n == 0 then return 1
               else return n*f(n-1) end
             end
    end

local fat = Z(F)

assert(fat(0) == 1 and fat(4) == 24 and Z(F)(5)==5*Z(F)(4))

local function g (z)
  local function f (a,b,c,d)
    return function (x,y) return a+b+c+d+a+x+y+z end
  end
  return f(z,z+1,z+2,z+3)
end

local f = g(10)
assert(f(9, 16) == 10+11+12+13+10+9+16+10)

print('+')



local function unlpack (t, i)
  i = i or 1
  if (i <= #t) then
    return t[i], unlpack(t, i+1)
  end
end

local function equaltab (t1, t2)
  assert(#t1 == #t2)
  for i = 1, #t1 do
    assert(t1[i] == t2[i])
  end
end

local pack = function (...) return (table.pack(...)) end

local function f() return 1,2,30,4 end
local function ret2 (a,b) return a,b end

local a,b,c,d = unlpack{1,2,3}
assert(a==1 and b==2 and c==3 and d==nil)
a = {1,2,3,4,false,10,'alo',false,assert}
equaltab(pack(unlpack(a)), a)
equaltab(pack(unlpack(a), -1), {1,-1})
a,b,c,d = ret2(f()), ret2(f())
assert(a==1 and b==1 and c==2 and d==nil)