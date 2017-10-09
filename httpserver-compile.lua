-- httpserver-compile.lua
-- Part of nodemcu-httpserver, compiles server code after upload.
-- Author: Marcos Kirsch

local compileAndRemoveIfNeeded = function(f)
   if file.exists(f) then
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

for k,v in pairs(file.list()) do
  if string.match(k, "lua$") and k ~= "init.lua" then
    compileAndRemoveIfNeeded(k)
  end
end
