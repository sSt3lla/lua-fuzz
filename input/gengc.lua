


print('testing generational garbage collection')

local debug = require"debug"

assert(collectgarbage("isrunning"))

collectgarbage()

local oldmode = collectgarbage("generational")



do
  local U = {}
  
  collectgarbage()
  assert(not T or T.gcage(U) == "old")

  
  U[1] = {x = {234}}
  assert(not T or (T.gcage(U) == "touched1" and T.gcage(U[1]) == "new"))

  
  collectgarbage("step", 0)
  assert(not T or (T.gcage(U) == "touched2" and T.gcage(U[1]) == "survival"))

  
  
  collectgarbage("step", 0)
  assert(not T or (T.gcage(U) == "old" and T.gcage(U[1]) == "old1"))

  
  assert(U[1].x[1] == 234)
end


do
  
  
  local function foo () end
  local old = {10}
  collectgarbage()    
  assert(not T or T.gcage(old) == "old")
  setmetatable(old, {})    
  assert(not T or T.gcage(getmetatable(old)) == "old0")
  collectgarbage("step", 0)   
  assert(not T or T.gcage(getmetatable(old)) == "old1")
  setmetatable(getmetatable(old), {__gc = foo})  
  collectgarbage("step", 0)   
end


do   



  local A = {}
  A[1] = false     

  
  local function gcf (obj)
    A[1] = obj     
    assert(not T or T.gcage(obj) == "old1")
    obj = nil      
    collectgarbage("step", 0)   
    print(getmetatable(A[1]).x)   
  end

  collectgarbage()   
  local obj = {}     
  collectgarbage("step", 0)   
  assert(not T or T.gcage(obj) == "survival")
  setmetatable(obj, {__gc = gcf, x = "+"})   
  assert(not T or T.gcage(getmetatable(obj)) == "new")
  obj = nil   
  collectgarbage("step", 0)   
end


do   
  local old = {10}
  collectgarbage()   
  local co = coroutine.create(
    function ()
      local x = nil
      local f = function ()
                  return x[1]
                end
      x = coroutine.yield(f)
      coroutine.yield()
    end
  )
  local _, f = coroutine.resume(co)   
  collectgarbage("step", 0)   
  old[1] = {"hello"}    
  coroutine.resume(co, {123})     
  co = nil
  collectgarbage("step", 0)   
  assert(f() == 123 and old[1][1] == "hello")
  collectgarbage("step", 0)   
  
  assert(f() == 123 and old[1][1] == "hello")
end


do   
  local t = setmetatable({}, {__mode = "kv"})   
  collectgarbage()   
  assert(not T or T.gcage(t) == "old")
  t[1] = {10}
  assert(not T or (T.gcage(t) == "touched1" and T.gccolor(t) == "gray"))
  collectgarbage("step", 0)   
  assert(not T or (T.gcage(t) == "touched2" and T.gccolor(t) == "black"))
  collectgarbage("step", 0)   
  assert(not T or T.gcage(t) == "old")   
  t[1] = {10}      
  collectgarbage("step", 0)   
  
  assert(t[1] == nil)   
end


if T == nil then
  (Message or print)('\n >>> testC not active: \z
                             skipping some generational tests <<<\n')
  print 'OK'
  return
end



do
  local U = T.newuserdata(0, 1)
  
  collectgarbage()
  assert(T.gcage(U) == "old")

  
  debug.setuservalue(U, {x = {234}})
  assert(T.gcage(U) == "touched1" and
         T.gcage(debug.getuservalue(U)) == "new")

  
  collectgarbage("step", 0)
  assert(T.gcage(U) == "touched2" and
         T.gcage(debug.getuservalue(U)) == "survival")

  
  
  collectgarbage("step", 0)
  assert(T.gcage(U) == "old" and
         T.gcage(debug.getuservalue(U)) == "old1")

  
  assert(debug.getuservalue(U).x[1] == 234)
end


assert(collectgarbage'isrunning')




assert(collectgarbage'isrunning')

collectgarbage(oldmode)

print('OK')

