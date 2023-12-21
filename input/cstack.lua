



local tracegc = require"tracegc"

print"testing stack overflow detection"







local function checkerror (msg, f, ...)
  local s, err = pcall(f, ...)
  assert(not s and string.find(err, msg))
end

do  print("testing stack overflow in message handling")
  local count = 0
  local function loop (x, y, z)
    count = count + 1
    return 1 + loop(x, y, z)
  end
  tracegc.stop()    
  local res, msg = xpcall(loop, loop)
  tracegc.start()
  assert(msg == "error in error handling")
  print("final count: ", count)
end



do  print("testing recursion inside pattern matching")
  local function f (size)
    local s = string.rep("a", size)
    local p = string.rep(".?", size)
    return string.match(s, p)
  end
  local m = f(80)
  assert(#m == 80)
  checkerror("too complex", f, 2000)
end


do  print("testing stack-overflow in recursive 'gsub'")
  local count = 0
  local function foo ()
    count = count + 1
    string.gsub("a", ".", foo)
  end
  checkerror("stack overflow", foo)
  print("final count: ", count)

  print("testing stack-overflow in recursive 'gsub' with metatables")
  local count = 0
  local t = setmetatable({}, {__index = foo})
  foo = function ()
    count = count + 1
    string.gsub("a", ".", t)
  end
  checkerror("stack overflow", foo)
  print("final count: ", count)
end


do   
  print("testing limits in coroutines inside deep calls")
  local count = 0
  local lim = 1000
  local function stack (n)
    if n > 0 then return stack(n - 1) + 1
    else coroutine.wrap(function ()
           count = count + 1
           stack(lim)
         end)()
    end
  end

  local st, msg = xpcall(stack, function () return "ok" end, lim)
  assert(not st and msg == "ok")
  print("final count: ", count)
end


do    
  local count = 0
  print("chain of 'coroutine.close'")
  
  
  
  local coro = false
  for i = 1, 1000 do
    local previous = coro
    coro = coroutine.create(function()
      local cc <close> = setmetatable({}, {__close=function()
        count = count + 1
        if previous then
          assert(coroutine.close(previous))
        end
      end})
      coroutine.yield()   
    end)
    assert(coroutine.resume(coro))  
  end
  local st, msg = coroutine.close(coro)
  assert(not st and string.find(msg, "C stack overflow"))
  print("final count: ", count)
end


do
  print("nesting of resuming yielded coroutines")
  local count = 0

  local function body ()
    coroutine.yield()
    local f = coroutine.wrap(body)
    f();  
    count = count + 1
    f()   
  end

  local f = coroutine.wrap(body)
  f()
  assert(not pcall(f))
  print("final count: ", count)
end


do    
  print("nesting coroutines running after recoverable errors")
  local count = 0
  local function foo()
    count = count + 1
    pcall(1)   
    
    coroutine.wrap(foo)()   
  end
  checkerror("C stack overflow", foo)
  print("final count: ", count)
end


if T then
  print("testing stack recovery")
  local N = 0      
  local LIM = -1   

  
  
  local stack1
  local dummy

  local function err(msg)
    assert(string.find(msg, "stack overflow"))
    local _, stacknow = T.stacklevel()
    assert(stacknow == stack1 + 200)
  end

  
  
  
  
  
  local function f()
    dummy, stack1 = T.stacklevel()
    if N == LIM then
      xpcall(f, err)
      local _, stacknow = T.stacklevel()
      assert(stacknow == stack1)
      return
    end
    N = N + 1
    f()
  end

  local topB, sizeB   
  local topA, sizeA   
  topB, sizeB = T.stacklevel()
  tracegc.stop()    
  xpcall(f, err)
  tracegc.start()
  topA, sizeA = T.stacklevel()
  
  assert(topA == topB and sizeA < sizeB * 2)
  print(string.format("maximum stack size: %d", stack1))
  LIM = N      
  N = 0        
  tracegc.stop()    
  f()
  tracegc.start()
  print"+"
end

print'OK'
