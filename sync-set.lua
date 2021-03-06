-- set DS3231 from ntp

local dsrtc = dofile('ds-rtc.lc')


local ts2gmt=function(ts)
    local tm = rtctime.epoch2cal(ts)
    return {tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]}
end

local format=function()
    local ts=rtctime.get()
    local dt=ts2gmt(ts)
    return string.format("%04u/%01u/%01u %02u:%02u:%02u", unpack(dt))
end

local i2csetup = function(clock)
  if clock then
    i2c.setup(0, 2, 3, i2c.SLOW)
  else
    i2c.setup(0, 1, 3, i2c.SLOW)
  end
end

i2csetup(1)

local function startSync()
    sntp.sync(nil,
      function(sec, usec, server, info)
        local tm = rtctime.epoch2cal(sec)
        dsrtc.setTime(tm["sec"], tm["min"], tm["hour"], 1, tm["day"], tm["mon"], tm["year"] - 2000)
        print ("Clock set")
      end,
      nil
    )
end

tmr.create():alarm(10000, 0, function()
    local status, err = pcall(startSync)
    if not status then
      print ("Failed to start sntp")
    end
end)

local days = {
    {   0,  31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335},
    { 366, 397, 425, 456, 486, 517, 547, 578, 609, 639, 670, 700},
    { 731, 762, 790, 821, 851, 882, 912, 943, 974,1004,1035,1065},
    {1096,1127,1155,1186,1216,1247,1277,1308,1339,1369,1400,1430}
}

local dt2epoch = function(second, minute, hour, day, month, year)
    day = day - 1
    return (((year/4*(365*4+1)+days[year%4+1][month]+day)*24+hour)*60+minute)*60+second;
end

local second, minute, hour, day, date, month, year = dsrtc.getTime()

local epoch = dt2epoch(second, minute, hour, date, month, year + 30    )

rtctime.set(epoch, 0)

local temp = dsrtc.getTemp()

print ("temp is " .. temp)

local f = file.open("http__bootlog.txt", "a")
f:write(string.format("Booted at %04d/%02d/%02d %02d:%02d:%02d -- rtc temp %dF\n",
    year + 2000, month, date, hour, minute, second, temp * 9 / 50 + 32))
f:close()
