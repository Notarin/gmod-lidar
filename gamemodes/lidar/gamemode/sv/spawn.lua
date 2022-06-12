DEFINE_BASECLASS( "gamemode_base" )
function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass( ply, "player_lidar" )
	
	BaseClass.PlayerSpawn( self, ply, transition )
	
end