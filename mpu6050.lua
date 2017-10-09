--------------------------------------------------------------------------------
-- MPU6050 GY-521 module 
-- I2C  Driver
-- NODEMCU
-- ESP8266-Projects.com 
-- 
-- Copyright (C) 2015  TJ <tech@esp8266-projects.com>
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--------------------------------------------------------------------------------

local M = {}

local dev_addr = 0x68 --104
local sda, scl = 1, 3
   
local function init_I2C()
  i2c.setup(0, sda, scl, i2c.SLOW)    
end

local function init_MPU(reg,val)  --(107) 0x6B / 0
   write_reg_MPU(reg,val)
end

local function write_reg_MPU(reg,val)
  i2c.start(0)
  i2c.address(0, dev_addr, i2c.TRANSMITTER)
  i2c.write(0, reg)
  i2c.write(0, val)
  i2c.stop(0)
end

local function read_bytes_MPU(reg, n)
  i2c.start(0) 
  i2c.address(0, dev_addr, i2c.TRANSMITTER)
  i2c.write(0, reg)
  i2c.stop(0)
  i2c.start(0)
  i2c.address(0, dev_addr, i2c.RECEIVER)
  local c=i2c.read(0, n)
  i2c.stop(0)
  return c
end

local function read_reg_MPU(reg)
  return read_bytes_MPU(reg, 1)
end

local function read8_reg_MPU(reg)
  local c = read_bytes_MPU(reg, 1)
  return string.byte(c, 1)
end

local function read16_reg_MPU(reg)
  local c = read_bytes_MPU(reg, 2)
  return struct.unpack(">h", c)
end

local function read6x16_reg_MPU(reg)
  local c = read_bytes_MPU(reg, 12)
  return struct.unpack(">hhhhhh", c)
end

local function read_MPU_raw()
  local c = read_bytes_MPU(59, 14)
  return struct.unpack(">hhhhhhh", c)
  
 --Ax=bit.lshift(string.byte(c, 1), 8) + string.byte(c, 2)
 -- Ay=bit.lshift(string.byte(c, 3), 8) + string.byte(c, 4)
  --Az=bit.lshift(string.byte(c, 5), 8) + string.byte(c, 6)

  --print("Ax:"..Ax.."     Ay:"..Ay.."      Az:"..Az)
  --print("TempH: "..string.byte(c, 7).." TempL: "..string.byte(c, 8).."\n")

  --return Ax, Ay, Az
end

local function status_MPU(dev_addr)
     i2c.start(0)
     local c=i2c.address(0, dev_addr ,i2c.TRANSMITTER)
     i2c.stop(0)
     if c==true then
        print(" Device found at address : "..string.format("0x%X",dev_addr))
     else print("Device not found !!")
     end
end

local function check_MPU(dev_addr)
   status_MPU(0x68)
   local c = read_reg_MPU(117) --Register 117 – Who Am I - 0x75
   if string.byte(c, 1)==104 then print(" MPU6050 Device answered OK!")
   else print("  Check Device - MPU6050 NOT available!")
        print(string.byte(c, 1))
        return
   end
   c = read_reg_MPU(107) --Register 107 – Power Management 1-0x6b
   if string.byte(c, 1)==64 then print(" MPU6050 in SLEEP Mode !")
   else print(" MPU6050 in ACTIVE Mode !")
   end
end

M.write_reg_MPU = write_reg_MPU
M.read16_reg_MPU = read16_reg_MPU
M.read_bytes_MPU = read_bytes_MPU

M.init = function() 
    init_I2C()
    check_MPU(0x68)
    write_reg_MPU(0x6B,0)    -- master reset, gyro as clock source
    read_MPU_raw()

    M.init = nil
end

--local lastReading = string.rep("\0", 14)

M.initfifo = function()
    M.init()
    write_reg_MPU(27, 0x08)
    write_reg_MPU(28, 0x08)
    write_reg_MPU(107, 1)
    write_reg_MPU(25, 248) -- 4 samples per second
    write_reg_MPU(26, 6)
    write_reg_MPU(35, 0xf8)
    write_reg_MPU(106, 0x04)
    write_reg_MPU(106, 0x40)

    --tmr.create():alarm(150, 1, function() 
    --  local count = read16_reg_MPU(114)
    --  if count >= 14 then
    --    lastReading = read_bytes_MPU(116, 14)
    --  end
    --end)

    M.initfifo = nil
end

M.getReading = function()
  local count = read16_reg_MPU(114)

  while count >= 56 do
    read_bytes_MPU(116, 14)
    count = count - 14
  end
  if count >= 14 then
    return read_bytes_MPU(116, 14)
  end
  return string.rep("\0", 14)
end

--write_reg_MPU(0x1a, 3)
--write_reg_MPU(0x19, 4)

--write_reg_MPU(0x1b, 0x08)
--write_reg_MPU(0x1c, 0x08)

--write_reg_MPU(0x38, 0)

--write_reg_MPU(28, 8)   -- accel to +/- 4g
--write_reg_MPU(27, 8)   -- gyro to +/- 500 deg/sec

--write_reg_MPU(26, 6)   -- DLPF down to 5Hz


--tmr.alarm(0, 250/max_count, 1, function() log_and_reset() end)
--tmr.stop(0)
-------------

return M

