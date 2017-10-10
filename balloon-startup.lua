--balloon-startup.lua

local startTimer = tmr.create()

stop = function()
  startTimer:unregister()
  startTimer = nil
  stop = nil
end

startTimer:alarm(10 * 1000, 0, function() 
    stop()
    collectgarbage()
    
    print ("Logging initiated with free heap " .. node.heap())
    local a = require('accel-geiger')
    a.init()
    local d = require('datalogger')
    d.start(a.getReading)
   end)

print ("Starting to log in 10 seconds. Type stop() to prevent this")
