if !system.IsWindows() or !file.Exists("lua/bin/gmcl_steamfriends_win64.dll", "GAME") then return end

local richtext = ""
local nextupdate = 0

local function UpdateRichPresence()
	if CurTime() < nextupdate then return end
	local rp = SetRichPresence
	if !rp then return end
	
	local ply = LocalPlayer()
	local map = game.GetMap()
	local updatedtext = "LIDAR"
	if richtext != updatedtext then
		richtext = updatedtext
		rp("generic", richtext)
		print("Updating presence")
	end
	
	nextupdate = CurTime() + 60
end

local function LoadRichPresenceDLL()
	require("steamfriends")
end
hook.Add("OnGamemodeLoaded", "LoadDLL", function()

	local dllfound = pcall(LoadRichPresenceDLL)
	LoadRichPresenceDLL = nil
	if !dllfound then
		hook.Remove("Tick", "UpdateRichPresence")
	else
		hook.Add("Tick", "UpdateRichPresence", UpdateRichPresence)
	end
end)