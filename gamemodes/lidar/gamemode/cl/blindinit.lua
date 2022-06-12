hook.Add("InitPostEntity", "LOC_C", function()
	ToggleBlindness(false)
	timer.Simple(1, function() hook.Remove("PostRender", "ModelsWarmup") ToggleBlindness(true) end)
	hook.Remove("InitPostEntity", "LOC_C")
end)

hook.Add("PostRender", "ModelsWarmup", function()
	if CurTime() > 10 then
		hook.Remove("PostRender", "ModelsWarmup")
		return
	end
	render.Clear(0,0,0,0)
end)