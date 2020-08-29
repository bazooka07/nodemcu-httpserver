-- Compile freshly uploaded nodemcu-httpserver lua files.
if node.getpartitiontable().lfs_size > 0 then
   if file.exists("lfs.img") then
      if file.exists("lfs_lock") then
         file.remove("lfs_lock")
         file.remove("lfs.img")
      else
         local f = file.open("lfs_lock", "w")
     	 f:flush()
	     f:close()
       	 file.remove("httpserver-compile.lua")
	     node.flashreload("lfs.img")
      end
   end

   pcall(node.flashindex("_init"))
end

local filename = "httpserver-compile.lua"

if file.exists(filename) then
   dofile(filename)
   file.remove(filename)
end

-- Set up NodeMCU's WiFi
filename = "httpserver-wifi.lc"
if file.exists(filename) then
   dofile(filename)
end

filename = nil

-- Start nodemcu-httpsertver
-- dofile("httpserver-init.lc")

print('chip: ',node.chipid())
print('heap: ',node.heap())

if file.exists('application.lua') then
	dofile('application.lua')
end
