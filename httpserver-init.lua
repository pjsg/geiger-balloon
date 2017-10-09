-- httpserver-init.lua
-- Part of nodemcu-httpserver, launches the server.
-- Author: Marcos Kirsch

-- Function for starting the server.
-- If you compiled the mdns module, then it will also register with mDNS.
local startServer = function(ip, onconnect)
   local conf = dofile('httpserver-conf.lc')
   local s
   
   s = dofile("httpserver.lc")(conf['general']['port'], onconnect) 
   if s then
      print("nodemcu-httpserver running at:")
      print("   http://" .. ip .. ":" ..  conf['general']['port'])
      --if (mdns) then
      --   mdns.register(conf['mdns']['hostname'], { description=conf['mdns']['description'], service="http", port=conf['general']['port'], location=conf['mdns']['location'] })
      --   print ('   http://' .. conf['mdns']['hostname'] .. '.local.:' .. conf['general']['port'])
      --end
   end
   conf = nil
   return s
end

theServer = nil

function stopServing() 
  if theServer then
    theServer:close()
  end
  theServer = nil
  mdns.close()
end

return function (onconnect)
    --if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
    if (wifi.getmode() == wifi.STATION) then
    
       -- Connect to the WiFi access point and start server once connected.
       wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
          print("Connected to WiFi Access Point. Got IP: " .. args["IP"])
          theServer = startServer(args["IP"], onconnect)
    
          wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
       end)
    
    else
       wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
          print("Connected to WiFi Access Point. Got IP: " .. args["IP"])
          wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
       end)

       tmr.create():alarm(2000, 0, function() 
        theServer = startServer(wifi.ap.getip(), onconnect)
       end)
   
    end
end

