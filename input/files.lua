


local debug = require "debug"

local maxint = math.maxinteger

assert(type(os.getenv"PATH") == "string")

assert(io.input(io.stdin) == io.stdin)
assert(not pcall(io.input, "non-existent-file"))
assert(io.output(io.stdout) == io.stdout)


local function testerr (msg, f, ...)
  local stat, err = pcall(f, ...)
  return (not stat and string.find(err, msg, 1, true))
end


local function checkerr (msg, f, ...)
  assert(testerr(msg, f, ...))
end



assert(not io.close(io.stdin) and
       not io.stdout:close() and
       not io.stderr:close())


checkerr("got no value", io.stdin.close)


assert(type(io.input()) == "userdata" and io.type(io.output()) == "file")
assert(type(io.stdin) == "userdata" and io.type(io.stderr) == "file")
assert(not io.type(8))
local a = {}; setmetatable(a, {})
assert(not io.type(a))

assert(getmetatable(io.input()).__name == "FILE*")

local a,b,c = io.open('xuxu_nao_existe')
assert(not a and type(b) == "string" and type(c) == "number")

a,b,c = io.open('/a/b/c/d', 'w')
assert(not a and type(b) == "string" and type(c) == "number")

local file = os.tmpname()
local f, msg = io.open(file, "w")
if not f then
  (Message or print)("'os.tmpname' file cannot be open; skipping file tests")

else  
f:close()

print('testing i/o')

local otherfile = os.tmpname()

checkerr("invalid mode", io.open, file, "rw")
checkerr("invalid mode", io.open, file, "rb+")
checkerr("invalid mode", io.open, file, "r+bk")
checkerr("invalid mode", io.open, file, "")
checkerr("invalid mode", io.open, file, "+")
checkerr("invalid mode", io.open, file, "b")
assert(io.open(file, "r+b")):close()
assert(io.open(file, "r+")):close()
assert(io.open(file, "rb")):close()

assert(os.setlocale('C', 'all'))

io.input(io.stdin); io.output(io.stdout);

os.remove(file)
assert(not loadfile(file))
checkerr("", dofile, file)
assert(not io.open(file))
io.output(file)
assert(io.output() ~= io.stdout)

if not _port then   
  local status, msg, code = io.stdin:seek("set", 1000)
  assert(not status and type(msg) == "string" and type(code) == "number")
end

assert(io.output():seek() == 0)
assert(io.write("alo alo"):seek() == string.len("alo alo"))
assert(io.output():seek("cur", -3) == string.len("alo alo")-3)
assert(io.write("joao"))
assert(io.output():seek("end") == string.len("alo joao"))

assert(io.output():seek("set") == 0)

assert(io.write('"alo"', "{a}\n", "second line\n", "third line \n"))
assert(io.write('Xfourth_line'))
io.output(io.stdout)
collectgarbage()  
assert(io.input() == io.stdin and rawequal(io.output(), io.stdout))
print('+')


collectgarbage()
for i=1,120 do
  for i=1,5 do
    io.input(file)
    assert(io.open(file, 'r'))
    io.lines(file)
  end
  collectgarbage()
end

io.input():close()
io.close()

assert(os.rename(file, otherfile))
assert(not os.rename(file, otherfile))

io.output(io.open(otherfile, "ab"))
assert(io.write("\n\n\t\t  ", 3450, "\n"));
io.close()


do
  
  local F = nil
  do
    local f <close> = assert(io.open(file, "w"))
    F = f
  end
  assert(tostring(F) == "file (closed)")
end
assert(os.remove(file))


do
  
  local f <close> = assert(io.open(file, "w"))
  f:write(maxint, '\n')
  f:write(string.format("0X%x\n", maxint))
  f:write("0xABCp-3", '\n')
  f:write(0, '\n')
  f:write(-maxint, '\n')
  f:write(string.format("0x%X\n", -maxint))
  f:write("-0xABCp-3", '\n')
  assert(f:close())
  local f <close> = assert(io.open(file, "r"))
  assert(f:read("n") == maxint)
  assert(f:read("n") == maxint)
  assert(f:read("n") == 0xABCp-3)
  assert(f:read("n") == 0)
  assert(f:read("*n") == -maxint)            
  assert(f:read("n") == -maxint)
  assert(f:read("*n") == -0xABCp-3)            
end
assert(os.remove(file))



do
  local f <close> = assert(io.open(file, "w"))
  f:write[[
a line
another line
1234
3.45
one
two
three
]]
  local l1, l2, l3, l4, n1, n2, c, dummy
  assert(f:close())
  local f <close> = assert(io.open(file, "r"))
  l1, l2, n1, n2, dummy = f:read("l", "L", "n", "n")
  assert(l1 == "a line" and l2 == "another line\n" and
         n1 == 1234 and n2 == 3.45 and dummy == nil)
  assert(f:close())
  local f <close> = assert(io.open(file, "r"))
  l1, l2, n1, n2, c, l3, l4, dummy = f:read(7, "l", "n", "n", 1, "l", "l")
  assert(l1 == "a line\n" and l2 == "another line" and c == '\n' and
         n1 == 1234 and n2 == 3.45 and l3 == "one" and l4 == "two"
         and dummy == nil)
  assert(f:close())
  local f <close> = assert(io.open(file, "r"))
  
  l1, n1, n2, dummy = f:read("l", "n", "n", "l")
  assert(l1 == "a line" and not n1)
end
assert(os.remove(file))




f = assert(io.open(file, "w"))
f:write[[
local x, z = coroutine.yield(10)
local y = coroutine.yield(20)
return x + y * z
]]
assert(f:close())
f = coroutine.wrap(dofile)
assert(f(file) == 10)
assert(f(100, 101) == 20)
assert(f(200) == 100 + 200 * 101)
assert(os.remove(file))


f = assert(io.open(file, "w"))

f:write[[
-12.3-	-0xffff+  .3|5.E-3X  +234e+13E 0xDEADBEEFDEADBEEFx
0x1.13Ap+3e
]]

f:write("1234"); for i = 1, 1000 do f:write("0") end;  f:write("\n")

f:write[[
.e+	0.e;	
]]
assert(f:close())
f = assert(io.open(file, "r"))
assert(f:read("n") == -12.3); assert(f:read(1) == "-")
assert(f:read("n") == -0xffff); assert(f:read(2) == "+ ")
assert(f:read("n") == 0.3); assert(f:read(1) == "|")
assert(f:read("n") == 5e-3); assert(f:read(1) == "X")
assert(f:read("n") == 234e13); assert(f:read(1) == "E")
assert(f:read("n") == 0Xdeadbeefdeadbeef); assert(f:read(2) == "x\n")
assert(f:read("n") == 0x1.13aP3); assert(f:read(1) == "e")

do   
  assert(not f:read("n"))  
  local s = f:read("L")   
  assert(string.find(s, "^00*\n$"))  
end

assert(not f:read("n")); assert(f:read(2) == "e+")
assert(not f:read("n")); assert(f:read(1) == ";")
assert(not f:read("n")); assert(f:read(2) == "-;")
assert(not f:read("n")); assert(f:read(1) == "X")
assert(not f:read("n")); assert(f:read(1) == ";")
assert(not f:read("n")); assert(not f:read(0))   
assert(f:close())
assert(os.remove(file))



assert(not pcall(io.lines, "non-existent-file"))
assert(os.rename(otherfile, file))
io.output(otherfile)
local n = 0
local f = io.lines(file)
while f() do n = n + 1 end;
assert(n == 6)   
checkerr("file is already closed", f)
checkerr("file is already closed", f)

n = 0
for l in io.lines(file) do io.write(l, "\n"); n = n + 1 end
io.close()
assert(n == 6)

local f = assert(io.open(otherfile))
assert(io.type(f) == "file")
io.output(file)
assert(not io.output():read())
n = 0
for l in f:lines() do io.write(l, "\n"); n = n + 1 end
assert(tostring(f):sub(1, 5) == "file ")
assert(f:close()); io.close()
assert(n == 6)
checkerr("closed file", io.close, f)
assert(tostring(f) == "file (closed)")
assert(io.type(f) == "closed file")
io.input(file)
f = io.open(otherfile):lines()
n = 0
for l in io.lines() do assert(l == f()); n = n + 1 end
f = nil; collectgarbage()
assert(n == 6)
assert(os.remove(otherfile))

do  
  io.output(otherfile)
  io.write(string.rep("a", 300), "\n")
  io.close()
  local t ={}; for i = 1, 250 do t[i] = 1 end
  t = {io.lines(otherfile, table.unpack(t))()}
  
  assert(#t == 250 and t[1] == 'a' and t[#t] == 'a')
  t[#t + 1] = 1    
  checkerr("too many arguments", io.lines, otherfile, table.unpack(t))
  collectgarbage()   
  assert(os.remove(otherfile))
end

io.input(file)
do  
  local a,b,c = io.input():write("xuxu")
  assert(not a and type(b) == "string" and type(c) == "number")
end
checkerr("invalid format", io.read, "x")
assert(io.read(0) == "")   
assert(io.read(5, 'l') == '"alo"')
assert(io.read(0) == "")
assert(io.read() == "second line")
local x = io.input():seek()
assert(io.read() == "third line ")
assert(io.input():seek("set", x))
assert(io.read('L') == "third line \n")
assert(io.read(1) == "X")
assert(io.read(string.len"fourth_line") == "fourth_line")
assert(io.input():seek("cur", -string.len"fourth_line"))
assert(io.read() == "fourth_line")
assert(io.read() == "")  
assert(io.read('n') == 3450)
assert(io.read(1) == '\n')
assert(not io.read(0))  
assert(not io.read(1))  
assert(not io.read(30000))  
assert(({io.read(1)})[2] == undef)
assert(not io.read())  
assert(({io.read()})[2] == undef)
assert(not io.read('n'))  
assert(({io.read('n')})[2] == undef)
assert(io.read('a') == '')  
assert(io.read('a') == '')  
collectgarbage()
print('+')
io.close(io.input())
checkerr(" input file is closed", io.read)

assert(os.remove(file))

local t = '0123456789'
for i=1,10 do t = t..t; end
assert(string.len(t) == 10*2^10)

io.output(file)
io.write("alo"):write("\n")
io.close()
checkerr(" output file is closed", io.write)
local f = io.open(file, "a+b")
io.output(f)
collectgarbage()

assert(io.write(' ' .. t .. ' '))
assert(io.write(';', 'end of file\n'))
f:flush(); io.flush()
f:close()
print('+')

io.input(file)
assert(io.read() == "alo")
assert(io.read(1) == ' ')
assert(io.read(string.len(t)) == t)
assert(io.read(1) == ' ')
assert(io.read(0))
assert(io.read('a') == ';end of file\n')
assert(not io.read(0))
assert(io.close(io.input()))



do
  local function ismsg (m)
    
    return (type(m) == "string" and not tonumber(m))
  end

  
  local f = io.open(file, "w")
  local r, m, c = f:read()
  assert(not r and ismsg(m) and type(c) == "number")
  assert(f:close())
  
  f = io.open(file, "r")
  r, m, c = f:write("whatever")
  assert(not r and ismsg(m) and type(c) == "number")
  assert(f:close())
  
  f = io.open(file, "w")
  r, m = pcall(f:lines())
  assert(r == false and ismsg(m))
  assert(f:close())
end

assert(os.remove(file))


io.output(file); io.write"\n\nline\nother":close()
io.input(file)
assert(io.read"L" == "\n")
assert(io.read"L" == "\n")
assert(io.read"L" == "line\n")
assert(io.read"L" == "other")
assert(not io.read"L")
io.input():close()

local f = assert(io.open(file))
local s = ""
for l in f:lines("L") do s = s .. l end
assert(s == "\n\nline\nother")
f:close()

io.input(file)
s = ""
for l in io.lines(nil, "L") do s = s .. l end
assert(s == "\n\nline\nother")
io.input():close()

s = ""
for l in io.lines(file, "L") do s = s .. l end
assert(s == "\n\nline\nother")

s = ""
for l in io.lines(file, "l") do s = s .. l end
assert(s == "lineother")

io.output(file); io.write"a = 10 + 34\na = 2*a\na = -a\n":close()
local t = {}
assert(load(io.lines(file, "L"), nil, nil, t))()
assert(t.a == -((10 + 34) * 2))


do   

  
  local function gettoclose (lv)
    lv = lv + 1
    local stvar = 0   
    for i = 1, 1000 do
      local n, v = debug.getlocal(lv, i)
      if n == "(for state)" then
        stvar = stvar + 1
        if stvar == 4 then return v end
      end
    end
  end

  local f
  for l in io.lines(file) do
    f = gettoclose(1)
    assert(io.type(f) == "file")
    break
  end
  assert(io.type(f) == "closed file")

  f = nil
  local function foo (name)
    for l in io.lines(name) do
      f = gettoclose(1)
     