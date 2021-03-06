 function pairsByKeys (t)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then 
          return nil
        else 
          return a[i], t[a[i] ] -- xx
        end
      end
      return iter
    end


return function (connection, req, args)
   local json = args['json'] --

   local filetype = 'html'
   if json then
     filetype = 'json'
   end
   dofile("httpserver-header.lc")(connection, 200, filetype)

   local remaining, used, total = file.fsinfo()
   local sec, usec = rtctime.get()

   if json then
     local encoder = sjson.encoder({now=sec, fsinfo={remaining=remaining, used=used, total=total},
        files=file.list()})
     while true do
        local data = encoder:read(512)
        if not data then
           break
        end
       connection:send(data)
     end
     return
   end

   connection:send([===[
      <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Server File Listing</title></head>
      <body>
   <h1>Server File Listing</h1>
   ]===])

   connection:send("<b>Total size: </b> " .. total .. " bytes<br/>\n" ..
                   "<b>In Use: </b> " .. used .. " bytes<br/>\n" ..
                   "<b>Free: </b> " .. remaining .. " bytes<br/>\n")

   connection:send("<b>Log time left (approx): </b> " .. (remaining - 100000) / (80 * 3600) .. " hours<br/>\n")

   local flashAddress, flashSize = file.fscfg ()
   connection:send("<b>Flash Address: </b> " .. flashAddress .. " bytes<br/>\n" ..
                   "<b>Flash Size: </b> " .. flashSize .. " bytes<br/>\n")
   
   connection:send("<b>Unused heap: </b> " .. node.heap() .. " bytes<br/>\n")

   connection:send("<b>System date: </b><span id=date>??</span><br/>\n")
   connection:send("<script type=text/javascript>document.getElementById('date').innerText = new Date(" .. sec .. "000).toString();</script>\n")

   connection:send("<p>\n<b>Data files:</b><br/>\n<ul>\n")
   for name, size in pairsByKeys(file.list()) do
      local isDataFile = string.match(name, "dat$") ~= nil
      if isDataFile then
         local url = "/dat.lc?f=" .. name
         connection:send('   <li><a href="' .. url .. '">' .. name .. "</a> (" .. size .. " bytes)</li>\n")
      end
   end
   connection:send("</ul>\n</p>\n")
   
   connection:send("<p>\n<b>Files:</b><br/>\n<ul>\n")
   for name, size in pairsByKeys(file.list()) do
      local isHttpFile = string.match(name, "(http__)") ~= nil
      if isHttpFile then
         local url = string.match(name, "http__(.*)")
         connection:send('   <li><a href="' .. url .. '">' .. url .. "</a> (" .. size .. " bytes)</li>\n")
      end
   end
   connection:send("</ul>\n</p>\n")
   
   connection:send("</body></html>")
end
