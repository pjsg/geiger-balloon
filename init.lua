node.setcpufreq(node.CPU160MHZ)

-- Compile freshly uploaded nodemcu-httpserver lua files.
if file.exists("httpserver-compile.lc") then
   dofile("httpserver-compile.lc")
else
   dofile("httpserver-compile.lua")
end

-- Set up NodeMCU's WiFi
dofile("httpserver-wifi.lc")

-- Start nodemcu-httpsertver
local function startLogging()
  stopServing()
  wifi.setmode(wifi.NULLMODE)
  node.setcpufreq(node.CPU80MHZ)
  -- start the data logger
  dofile("balloon-startup.lc")
end

local timer = tmr:create()
--timer:register(30 * 1000, 0, function() print('would start now') end)
timer:register(30 * 1000, 0, function() startLogging() end)

timer:start()

dofile("httpserver-init.lc")(function()  timer:stop() timer:start() end)

dofile("sync-set.lc")

