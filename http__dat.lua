return function (connection, req, args)
   local f = args['f'] --
   local args
   if not f or not file.exists(f) or not string.match(f, "dat$") then
      args = {code = 404, errorString = "Not Found"}
      fileServeFunction = dofile("httpserver-error.lc")
   else
      args = {ext = 'dat', isGzipped = false, file=f, 
        extraHeaders={"content-disposition: attachment; filename=\"" .. f .. "\""}}
      fileServeFunction = dofile("httpserver-static.lc")
   end
   fileServeFunction(connection, req, args)   
end
