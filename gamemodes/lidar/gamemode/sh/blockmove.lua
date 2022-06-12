hook.Add("StartCommand","LIDAR_cmd",function(ply, cmd)
	if cmd:KeyDown(IN_ATTACK) then
		cmd:RemoveKey(IN_DUCK)
	end
	cmd:RemoveKey(IN_SPEED)
end)

