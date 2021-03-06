--------------------------------------------------------------------------------
-- DS3231 I2C module for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Tobie Booth <tbooth@hindbra.in>
--------------------------------------------------------------------------------

require("bit")
require("i2c")

local M = {}

-- We don't save the module in the global array as we want it
-- to get GC'ed when not needed (which is most of the time)

-- Constants:
M.EVERYSECOND = 6
M.EVERYMINUTE = 7
M.SECOND = 1
M.MINUTE = 2
M.HOUR = 3
M.DAY = 4
M.DATE = 5
M.DISABLE = 0

-- Default value for i2c communication
local id = 0

--device address
local dev_addr = 0x68

local function decToBcd(val)
  if val == nil then return 0 end
  return((((val/10) - ((val/10)%1)) *16) + (val%10))
end

local function bcdToDec(val)
  return((((val/16) - ((val/16)%1)) *10) + (val%16))
end

local function addAlarmBit(val,day)
  if day == 1 then return bit.bor(val,64) end
  return bit.bor(val,128)
end

--get time from DS3231
function M.getTime()
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c=i2c.read(id, 7)
  i2c.stop(id)
  return bcdToDec(tonumber(string.byte(c, 1))),
  bcdToDec(tonumber(string.byte(c, 2))),
  bcdToDec(tonumber(string.byte(c, 3))),
  bcdToDec(tonumber(string.byte(c, 4))),
  bcdToDec(tonumber(string.byte(c, 5))),
  bcdToDec(tonumber(string.byte(c, 6))),
  bcdToDec(tonumber(string.byte(c, 7)))
end

--set time for DS3231
-- enosc setted to 1 disables oscilation on battery, stopping time
function M.setTime(second, minute, hour, day, date, month, year, disOsc)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.write(id, decToBcd(second))
  i2c.write(id, decToBcd(minute))
  i2c.write(id, decToBcd(hour))
  i2c.write(id, decToBcd(day))
  i2c.write(id, decToBcd(date))
  i2c.write(id, decToBcd(month))
  i2c.write(id, decToBcd(year))
  i2c.stop(id)

  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = string.byte(i2c.read(id, 1), 1)
  i2c.stop(id)
  if disOsc == 1 then c = bit.bor(c,128)
  else c = bit.band(c,127) end
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.write(id, c)
  i2c.stop(id)
end

function M.getTemp() 
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x11)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c=i2c.read(id, 2)
  i2c.stop(id)

  local temp16 = struct.unpack(">h", c)

  return bit.rshift(temp16 * 10, 8) 
end


-- Get Control and Status bytes
function M.getBytes ()
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, 0x0E)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.RECEIVER)
  local c = i2c.read(id, 2)
  i2c.stop(id)
  return tonumber(string.byte(c, 1)), tonumber(string.byte(c, 2))
end



return M
