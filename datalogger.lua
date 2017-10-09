local M = {}

M.dataTimer = tmr.create()

M.dataBuffer = ""

M.getFileName = function() 
  local sec = rtctime.get()
  sec = sec - sec % 180
  local tm = rtctime.epoch2cal(sec)

  return string.format("%04d%02d%02d-%02d%02d%02d.dat",
         tm['year'], tm['mon'], tm['day'], tm['hour'], tm['min'], tm['sec'])
end

M.getFileObject = function()
  return file.open(M.getFileName(), "a")
end

M.saveReading = function(getReading)
  M.dataBuffer = M.dataBuffer .. getReading()
  if #(M.dataBuffer) >= 400 then
    gpio.mode(4, gpio.OUTPUT)
    gpio.write(4, 0)
    local f = M.getFileObject()
    f:write(M.dataBuffer)
    f:close()
    M.dataBuffer = ""
    gpio.mode(4, gpio.INPUT)
  end
end

M.start = function(getReading)
    M.dataTimer:alarm(250, 1, function() M.saveReading(getReading) end) 
end

return M