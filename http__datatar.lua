local function pad(s, l)
  return s .. string.rep("\0", l - #(s))
end

local function octal(n, l)
  local result = ""
  while l > 0 do
    result = string.char(bit.band(7, n) + 48) .. result
    l = l - 1
    n = bit.rshift(n, 3)
  end
  return result
end

local function dliter(a, k)
  return next(file.list(), k)
end

local function dirlist()
  return dliter, nil, nil
end

return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'tar', false, {
     "content-disposition: attachment; filename=\"balloon-data.tar\""
   })
   
   local asText = args['csv'] --
   
   local now = rtctime.get()

    for k, v in dirlist() do
      if string.match(k, "dat$") then
        local f = file.open(k, "r")
        -- Make the header record
        local filename = k
        local filesize = v
        if asText then
           filename = filename .. ".csv"
           -- 11,6,6,6,6,6,6,6,6\n
           -- 12 + 7 * 8
           filesize = v / 20 * 68
        end
        local hdr = pad(filename, 100) .. 
            "0000664\0" ..
            "0001000\0" ..
            "0001000\0" ..
            octal(filesize, 11) .. "\0" ..
            octal(now, 11) .. "\0" ..
            "        " ..
            "0"
            
        hdr = pad(hdr, 512)
        -- calc checksum
        local total = 0
        for i = 1, 512 do
          total = total + string.byte(hdr, i)
        end

        local chksum = octal(bit.band(total, 65535), 6) .. "\0 "

        hdr = hdr:sub(1, 148) .. chksum .. hdr:sub(156 + 1)
        
        connection:send(hdr)

        hdr = ""

        if asText then
            while v > 0 do
              local b = f:read(20)
              local row = string.format("%11d,%6d,%6d,%6d,%6d,%6d,%6d,%6d,%6d\n", struct.unpack(">ihhhhhhhH", b))
              connection:send(row)
              v = v - 20
            end
            local lastblock = bit.band(filesize, 511)
            if lastblock > 0 then
              connection:send(string.rep("\0", 512-lastblock))
            end
        else
            while v > 0 do
              local b = f:read(512)
              connection:send(b)
              if #(b) < 512 then
                connection:send(string.rep("\0", 512 - #(b)))
              end
              v = v - 512
            end
        end

        f:close()
      end
    end

    connection:send(string.rep("\0", 512))
    connection:send(string.rep("\0", 512))
end
