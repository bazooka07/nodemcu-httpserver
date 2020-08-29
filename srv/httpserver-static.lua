-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Gregor Hartmann

return function (connection, req, args)

   local cacheControl = not args.isGzipped and "Cache-Control: private, max-age=14400" -- 4 hours
   local buffer = dofile("httpserver-buffer.lc"):new()
   dofile("httpserver-header.lc")(buffer, req.code or 200, args.ext, args.isGzipped, cacheControl)
   -- Send header and return fileInfo
   connection:send(buffer:getBuffer())

   return { file = args.file, sent = 0}
end
