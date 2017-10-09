-- data sample support

local M = {}

local geiger = require('geiger')
local mpu6050 = require('mpu6050')

local function getGeigerCount() 
  return geiger.getReading()
end

local worst = 0

local function getAccelerometerData() 
  local start = tmr.now()
  local result = mpu6050.getReading()
  local diff = tmr.now() - start
  if diff > worst then
    print ("Reading accel took " .. diff .. " usecs")
    worst = diff
  end
  return result
end

M.getReading = function()
  local sec, usec = rtctime.get()
  local ms = sec * 1000 + usec

  return struct.pack(">ic14h", ms, getAccelerometerData(), getGeigerCount())
end

M.init = function()
  mpu6050.init()
  tmr.create():alarm(1000, 0, function() geiger.start() end)
end

return M