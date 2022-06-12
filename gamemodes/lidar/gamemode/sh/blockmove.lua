hook.Add("StartCommand","LIDAR_cmd",function(ply, cmd)
	cmd:RemoveKey(IN_LEFT)
	cmd:RemoveKey(IN_RIGHT)
end)

