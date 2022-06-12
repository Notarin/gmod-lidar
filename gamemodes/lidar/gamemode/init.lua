AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

for k,v in ipairs(file.Find("lidar/gamemode/cl/*.lua", "LUA")) do
	AddCSLuaFile("cl/"..v)   
end 

for k,v in ipairs(file.Find("lidar/gamemode/sh/*.lua", "LUA")) do
print(v)                    
	include("sh/"..v)       
	AddCSLuaFile("sh/"..v)  
end 

for k,v in ipairs(file.Find("lidar/gamemode/sv/*.lua", "LUA")) do
	include("sv/"..v)
end