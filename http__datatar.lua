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
   
 
   local now = rtctime.get()

    for k, v in dirlist() do
      if string.match(k, "dat$") then
        local f = file.open(k, "r")
        -- Make the header record
        local hdr = pad(k, 100) .. 
            "0000664\0" ..
            "0001000\0" ..
            "0001000\0" ..
            octal(v, 11) .. "\0" ..
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

        while v > 0 do
          local b = f:read(512)

          connection:send(b)
          if #(b) < 512 then
            connection:send(string.rep("\0", 512 - #(b)))
          end
          v = v - 512
        end

        f:close()
      end
    end

    connection:send(string.rep("\0", 512))
    connection:send(string.rep("\0", 512))
end
