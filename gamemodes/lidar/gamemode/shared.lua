VERSIONGLOBAL = "v1"
DeriveGamemode( "sandbox" )
GM.Name 	= "LIDAR"
GM.Author 	= "datae"
GM.Email 	= "datae@dontemailme.com"
GM.Website 	= "datae.org"
include( 'player_class/player_lidar.lua' )

for k,v in ipairs(file.Find("lidar/gamemode/sh/*.lua", "LUA")) do
	AddCSLuaFile("sh/"..v)
	include("sh/"..v)
end