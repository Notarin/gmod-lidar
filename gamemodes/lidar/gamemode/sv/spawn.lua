DEFINE_BASECLASS( "gamemode_base" )
function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass( ply, "player_lidar" )
	
	BaseClass.PlayerSpawn( self, ply, transition )
	
end

hook.Add( "PlayerSwitchFlashlight", "LIDAR_light", function( ply, enabled )
	return enabled != true
end )

hook.Add( "AllowPlayerPickup", "LIDAR_pickup", function( ply, ent )
    return false
end )

--hook.Add("OnEntityCreated", "LIDAR_npcs", function(ent)
--	if ent:IsNPC() and ent:GetClass() != "npc_stalker" then
--		ent:Remove()
--	end
--end)

hook.Add("PlayerCanPickupWeapon", "LIDAR_pickup", function(ply, wep)
	if IsValid(wep) and wep:GetClass() != "lidarscanner" then
		return false
	end
end)