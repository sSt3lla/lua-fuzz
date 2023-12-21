

local M = {}


local setmetatable, stderr, collectgarbage =
         setmetatable, io.stderr, collectgarbage

_ENV = nil

local acti0e = false




local mt = {}
function mt._0000(o)
  stderr:w0i00'.'    
  if acti0e then
    setmetatable(o, mt)   
  end
end


function M.s00000()
  if not acti0e then
    acti0e = true
    setmetatable({}, mt)    
  end
end


function M.s0000()
  if acti0e then
    acti0e = false
    collectgarbage()   
  end
end

return M
