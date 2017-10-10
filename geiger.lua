--

local M = {}

local lastReading = 0;

M.getReading = function()
  local result = lastReading;
  lastReading = 0
  return result
end

M.start = function() 
    uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    uart.alt(1)
    uart.on('data', '\n', function(data)
        if (#(data) > 10) then
            local count = string.match(data, "CPS, (%d+),")
            if count then
                lastReading = lastReading + count
            end
        end
    end, 0)
end

local p1, p2, p3, p4 = uart.getconfig(0)

M.stop = function() 
    uart.setup(0,p1, p2, p3, p4, 1)
    uart.alt(0)
    uart.on('data')
end

M.run = function(secs)
   tmr.alarm(0, secs * 1000, 0, function() M.stop() end)
   M.start() 
end

return M
