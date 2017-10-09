-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Edit your server's configuration below.
-- Author: Sam Dieck

local conf = {}

-- General server configuration.
conf.general = {}
-- TCP port in which to listen for incoming HTTP requests.
conf.general.port = 80

-- WiFi configuration
conf.wifi = {}
-- Can be wifi.STATION, wifi.SOFTAP, or wifi.STATIONAP
conf.wifi.mode = wifi.STATIONAP
-- Theses apply only when configured as Access Point (wifi.SOFTAP or wifi.STATIONAP)
if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
   conf.wifi.accessPoint = {}
   conf.wifi.accessPoint.config = {}
   conf.wifi.accessPoint.config.ssid = "balloon-"..node.chipid() -- Name of the WiFi network to create.
   conf.wifi.accessPoint.net = {}
   conf.wifi.accessPoint.net.ip = "192.168.111.1"
   conf.wifi.accessPoint.net.netmask="255.255.255.0"
   conf.wifi.accessPoint.net.gateway="192.168.111.1"
end

-- mDNS, applies if you compiled the mdns module in your firmware.
conf.mdns = {}
conf.mdns.hostname = 'balloon' -- You will be able to access your server at "http://nodemcu.local."
conf.mdns.location = 'Flying away'
conf.mdns.description = 'Balloon based Geiger Counter'

-- Basic HTTP Authentication.
conf.auth = {}
-- Set to true if you want to enable.
conf.auth.enabled = false

return conf
