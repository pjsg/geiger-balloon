--balloon-startup.lua

startTimer = tmr.create()
startTimer:alarm(10 * 1000, 0, function() 
    print ("Logging initiated")
    local a = require('accel-geiger')
    a.init()
    local d = require('datalogger')
    d.start(a.getReading)
   end)

function stop()
  startTimer:unregister()
  startTimer = nil
end

print ("Starting to log in 10 seconds. Type stop() to prevent this")