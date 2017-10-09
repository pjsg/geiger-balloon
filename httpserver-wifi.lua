-- httpserver-wifi.lua
-- Part of nodemcu-httpserver, configures NodeMCU's WiFI in boot.
-- Author: Marcos Kirsch

local conf = nil
if file.exists("httpserver-conf.lc") then
   conf = dofile("httpserver-conf.lc")
else
   conf = dofile("httpserver-conf.lua")
end

wifi.setmode(conf.wifi.mode)

if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
    print('AP MAC: ',wifi.ap.getmac())
    wifi.ap.config(conf.wifi.accessPoint.config)
    wifi.ap.setip(conf.wifi.accessPoint.net)
end

if (conf.wifi.mode == wifi.STATION) or (conf.wifi.mode == wifi.STATIONAP) then
    print('Client MAC: ',wifi.sta.getmac())
    if not conf.wifi.station then
        local apinfo = wifi.sta.getapinfo()
        if apinfo[1] then
          conf.wifi.station = apinfo[1] --
        end
    end
    if conf.wifi.station then
        wifi.sta.config(conf.wifi.station)
    end
end

print('chip: ',node.chipid())
print('heap: ',node.heap())

conf = nil
collectgarbage()

-- End WiFi configuration
