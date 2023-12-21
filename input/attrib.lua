


print "testing require"

assert(require"string" == string)
assert(require"math" == math)
assert(require"table" == table)
assert(require"io" == io)
assert(require"os" == os)
assert(require"coroutine" == coroutine)

assert(type(package.path) == "string")
assert(type(package.cpath) == "string")
assert(type(package.loaded) == "table")
assert(type(package.preload) == "table")

assert(type(package.config) == "string")
print("package config: "..string.gsub(package.config, "\n", "|"))

do
  
  
  local max = _soft and 100 or 2000
  local t = {}
  for i = 1,max do t[i] = string.rep("?", i%10 + 1) end
  t[#t + 1] = ";"    
  local path = table.concat(t, ";")
  
  local s, err = package.searchpath("xuxu", path)
  
  
  assert(not s and
         string.find(err, string.rep("xuxu", 10)) and
         #string.gsub(err, "[^\n]", "") >= max)
  
  local path = string.rep("?", max)
  local s, err = package.searchpath("xuxu", path)
  assert(not s and string.find(err, string.rep('xuxu', max)))
end

do
  local oldpath = package.path
  package.path = {}
  local s, err = pcall(require, "no-such-file")
  assert(not s and string.find(err, "package.path"))
  package.path = oldpath
end


do  print"testing 'require' message"
  local oldpath = package.path
  local oldcpath = package.cpath

  package.path = "?.lua;?/?"
  package.cpath = "?.so;?/init"

  local st, msg = pcall(require, 'XXX')

  local expected = [[module 'XXX' not found:
	no field package.preload['XXX']
	no file 'XXX.lua'
	no file 'XXX/XXX'
	no file 'XXX.so'
	no file 'XXX/init']]

  assert(msg == expected)

  package.path = oldpath
  package.cpath = oldcpath
end

print('+')





if not _port then 

local dirsep = string.match(package.config, "^([^\n]+)\n")


local DIR = "libs" .. dirsep


local function D (x)
  local x = string.gsub(x, "/", dirsep)
  return DIR .. x
end


local function DC (x)
  local ext = (dirsep == '\\') and ".dll" or ".so"
  return D(x .. ext)
end


local function createfiles (files, preextras, posextras)
  for n,c in pairs(files) do
    io.output(D(n))
    io.write(stri