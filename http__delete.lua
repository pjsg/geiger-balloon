-- http__delete.lua
-- must pass ?delete=yes

return function (connection, req, args)
   local del
   
   if req.method == "POST" then
      local rd = req.getRequestData()
      del = rd['delete'] --
   end

   args = {ext = 'html', isGzipped = false, file='http__delete.html'}

   if del == 'yes' then
       for k, v in pairs(file.list()) do
          if string.match(k, "dat$") then
            file.remove(k)
          end
       end
       args['file'] = 'http__deleted.html'
   end
   local fileServeFunction = dofile("httpserver-static.lc")
   fileServeFunction(connection, req, args)   
end
