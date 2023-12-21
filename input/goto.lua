


collectgarbage()

local function errmsg (code, m)
  local st, msg = load(code)
  assert(not st and string.find(msg, m))
end


errmsg([[ goto l1; do ::l1:: end ]], "label 'l1'")
errmsg([[ do ::l1:: end goto l1; ]], "label 'l1'")


errmsg([[ ::l1:: ::l1:: ]], "label 'l1'")
errmsg([[ ::l1:: do ::l1:: end]], "label 'l1'")



errmsg([[ goto l1; local aa ::l1:: ::l2:: print(3) ]], "local 'aa'")


errmsg([[
do local bb, cc; goto l1; end
local aa
::l1:: print(3)
]], "local 'aa'")


errmsg([[ do ::l1:: end goto l1 ]], "label 'l1'")
errmsg([[ goto l1 do ::l1:: end ]], "label 'l1'")


errmsg([[
  repeat
    if x then goto cont end
    local xuxu = 10
    ::cont::
  until xuxu < x
]], "local 'xuxu'")


local x
do
  local y = 12
  goto l1
  ::l2:: x = x + 1; goto l3
  ::l1:: x = y; goto l2
end
::l3:: ::l3_1:: assert(x == 13)



do
  local prog = [[
  do
    local a = 1
    goto l%sa; a = a + 1
   ::l%sa:: a = a + 10
    goto l%sb; a = a + 2
   ::l%sb:: a = a + 20
    return a
  end
  ]]
  local label = string.rep("0123456789", 40)
  prog = string.format(prog, label, label, label, label)
  assert(assert(load(prog))() == 31)
end



do
  goto l1
  local a = 23
  x = a
  ::l1::;
end

while true do
  goto l4
  goto l1  
  goto l1  
  local x = 45
  ::l1:: ;;;
end
::l4:: assert(x == 13)

if print then
  goto l1   
  error("should not be here")
  goto l2   
  local x
  ::l1:: ; ::l2:: ;;
else end


local function foo ()
  local a = {}
  goto l3
  ::l1:: a[#a + 1] = 1; goto l2;
  ::l2:: a[#a + 1] = 2; goto l5;
  ::l3::
  ::l3a:: a[#a + 1] = 3; goto l1;
  ::l4:: a[#a + 1] = 4; goto l6;
  ::l5:: a[#a + 1] = 5; goto l4;
  ::l6:: assert(a[1] == 3 and a[2] == 1 and a[3] == 2 and
              a[4] == 5 and a[5] == 4)
  if not a[6] then a[6] = true; goto l3a end   
end

::l6:: foo()


do   
  local x
  ::L1::
  local y             
  assert(y == nil)
  y = true
  if x == nil then
    x = 1
    goto L1
  else
    x = x + 1
  end
  assert(x == 2 and y == true)
end


do
  local first = true
  local a = false
  if true then
    goto LBL
    ::loop::
    a = true
    ::LBL::
    if first then
      first = false
      goto loop
    end
  end
  assert(a)
end

do   
  goto escape   
  ::a:: goto a
  ::b:: goto c
  ::c:: goto b
end
::escape::



local debug = require 'debug'

local function foo ()
  local t = {}
  do
  local i = 1
  local a, b, c, d
  t[1] = function () return a, b, c, d end
  ::l1::
  local b
  do
    local c
    t[#t + 1] = function () return a, b, c, d end    
    if i > 2 then goto l2 end
    do
      local d
      t[#t + 1] = function () return a, b, c, d end   
      i = i + 1
      local a
      goto l1
    end
  end
  end
  ::l2:: return t
end

local a = foo()
assert(#a == 6)


for i = 2, 6 do
  assert(debug.upvalueid(a[1], 1) == debug.upvalueid(a[i], 1))
end


for i = 2, 6 do
  
  assert(debug.upvalueid(a[1], 2) ~= debug.upvalueid(a[i], 2))
  assert(debug.upvalueid(a[1], 3) ~= debug.upvalueid(a[i], 3))
end

for i = 3, 5, 2 do
  
  assert(debug.upvalueid(a[i], 2) == debug.upvalueid(a[i - 1], 2))
  assert(debug.upvalueid(a[i], 3) == debug.upvalueid(a[i - 1], 3))
  
  assert(debug.upvalueid(a[i], 2) ~= debug.upvalueid(a[i + 1], 2))
  assert(debug.upvalueid(a[i], 3) ~= debug.upvalueid(a[i + 1], 3))
end


for i = 2, 6, 2 do
  assert(debug.upvalueid(a[1], 4) == debug.upvalueid(a[i], 4))
end


for i = 3, 5, 2 do
  for j = 1, 6 do
    assert((debug.upvalueid(a[i], 4) == debug.upvalueid(a[j], 4))
      == (i == j))
  end
end




local function testG (a)
  if a == 1 then
    goto l1
    error("should never be here!")
  elseif a == 2 then goto l2
  elseif a == 3 then goto l3
  elseif a == 4 then
    goto l1  
    error("should never be here!")
    ::l1:: a = a + 1   
  else
    goto l4
    ::l4a:: a = a * 2; goto l4b
    error("should never be here!")
    ::l4:: goto l4a
    error("should never be here!")
    ::l4b::
  end
  do return a end
  ::l2:: do return "2" end
  ::l3:: do return "3" end
  ::l1:: return "1"
end

assert(testG(1) == "1")
assert(testG(2) == "2")
assert(testG(3) == "3")
assert(testG(4) == 5)
assert(testG(5) == 10)

do
  
  local X
  goto L1

  ::L2:: goto L3

  ::L1:: do
    local a <close> = setmetatable({}, {__close = function () X = true end})
    assert(X == nil)
    if a then goto L2 end   
  end

  ::L3:: assert(X == true)   
end



print'OK'
