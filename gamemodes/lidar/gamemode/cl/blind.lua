--[[
Deque implementation from
https://github.com/catwell/cw-lua/blob/master/deque/deque.lua
]]
local push_right = function(self, x)
  assert(x ~= nil)
  self.tail = self.tail + 1
  self[self.tail] = x
end

local push_left = function(self, x)
  assert(x ~= nil)
  self[self.head] = x
  self.head = self.head - 1
end

local pop_right = function(self)
  if self:is_empty() then return nil end
  local r = self[self.tail]
  self[self.tail] = nil
  self.tail = self.tail - 1
  return r
end

local pop_left = function(self)
  if self:is_empty() then return nil end
  local r = self[self.head+1]
  self.head = self.head + 1
  local r = self[self.head]
  self[self.head] = nil
  return r
end

local length = function(self)
  return self.tail - self.head
end

local is_empty = function(self)
  return self:length() == 0
end

local iter_left = function(self)
  local i = self.head
  return function()
    if i < self.tail then
      i = i+1
      return self[i]
    end
  end
end

local iter_right = function(self)
  local i = self.tail+1
  return function()
    if i > self.head+1 then
      i = i-1
      return self[i]
    end
  end
end

local contents = function(self)
  local r = {}
  for i=self.head+1,self.tail do
    r[i-self.head] = self[i]
  end
  return r
end

local methods = {
  push_right = push_right,
  push_left = push_left,
  peek_right = peek_right,
  peek_left = peek_left,
  pop_right = pop_right,
  pop_left = pop_left,
  rotate_right = rotate_right,
  rotate_left = rotate_left,
  remove_right = remove_right,
  remove_left = remove_left,
  iter_right = iter_right,
  iter_left = iter_left,
  length = length,
  is_empty = is_empty,
  contents = contents,
}

local new = function()
  local r = {head = 0, tail = 0}
  return setmetatable(r, {__index = methods})
end

local vecmeta = FindMetaTable("Vector")
function vecmeta:LerpTemp(t, start, endpos)
	local xs, ys, zs = start:Unpack()
	local xe, ye, ze = endpos:Unpack()
	
	self:SetUnpacked(
		LerpL(t, xs, xe),
		LerpL(t, ys, ye),
		LerpL(t, zs, ze)
	)
end

hitpoints = new()
hitcolor = new()
hitnormal = new()
soundpoints = new()
GlitchIntensity = 0

local hitpoints = hitpoints
local hitcolor = hitcolor
local hitnormal = hitnormal
local soundpoints = soundpoints

local tr = {}
local tr_result = {}
local randvector = Vector()
local awareness = CreateClientConVar("blindness_awareness", 10000, true, false, "Awareness in hu")

eyedot = 0.4

local red = Color(255,0,0)
local blue = Color(0,0,255)
local white = Color(210,159,110,255)
local green = Color(0,255,0)
local circle = Material("circle.png", "nocull")
local circlesize = 1

whiteg = white
customcolors = {
Color(210,159,110,255), --[["Gold (Default)"]]
Color(203,145,65,255), --[["Gold Intense"]]
Color(205,205,220,255), --[[White]]
Color(150, 50, 150, 255), --[["Missing"]]
Color(250, 20, 80, 255), --[[Pink]]
Color(250, 120, 40, 255), --[[Amber]]
Color(250, 20, 40, 255), --[[Crimson]]
Color(10, 255, 20, 255) --[[Predator]]
}

function BlindSetColor(newcol)
	white = newcol
end

concommand.Add("LIDAR_ScanRGB", function(ply, cmd, args)
	local r, g, b = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	if !isnumber(r) or !isnumber(g) or !isnumber(b) then
		return
	end
	local newcol = Color(r, g, b)
	if newcol then
		BlindSetColor(newcol)
	end
end)

function BlindGetColor()
	return white
end

local grass = Color(20,150,10)
local sand = Color(76,70,50)
local glass = Color(10,20,150)

local limit = 2500
local pinged = false
meshlimit = 375

local camvector, camang = Vector(), Angle()
local camlerp = 0
OOBGlitchIntensity = 0
local sound = nil

blindcolor = {0,0,0}
local colors = {
[MAT_DEFAULT] = blue,
[MAT_GLASS] = glass,
[MAT_SAND] = sand,
[MAT_DIRT] = sand,
[MAT_GRASS] = grass,
[MAT_FLESH] = red
}
local colorslist = {
green, grass, sand, glass
}

blindrandrendermin = 0.9
blindpopulate = false
blindpopulatespeed = 1000
blindfakepopulate = false
customglitch = true

blindflush = true
blindflip = true


function TogglePopulate()
	blindfakepopulate = !blindfakepopulate
end

local colorsclass = {
["prop_door_rotating"] = green,
["func_door_rotating"] = green,
["func_door"] = green
}

--[[Don't mute these sounds]]
local blindedsounds = {
["ping.wav"] = true,
["music/locloop.wav"] = true,
["music/locloop_unk.wav"] = true,
["reset.wav"] = true,
["reset2.wav"] = true,
["glitch_freq.wav"] = true,
["bad.wav"] = true,
["good.wav"] = true,
["A_TT_CD_01.wav"] = true,
["A_TT_CD_02.wav"] = true,
["lidar/burst1.wav"] = true,
["lidar/burst2.wav"] = true,
["lidar/burst3.wav"] = true,
["lidar/burst4.wav"] = true,
["lidar/scan.wav"] = true,
["lidar/scanstop.wav"] = true,
["lidar/cooldown.wav"] = true,
["shutoff.wav"] = true,
["start.mp3"] = true,
}

local trw = { collisiongroup = COLLISION_GROUP_WORLD }
local trwr = {}
local function IsInWorld( pos )
	trw.start = pos
	trw.endpos = pos
	trw.output = trwr
	util.TraceLine( trw )
	return trwr.HitWorld
end

local function RandomizeCam(eyepos, eyeang)
	local ctsin = 0
	if IsInWorld(eyepos) then
		ctsin = 25
	end
	OOBGlitchIntensity = Lerp(25*FrameTime(), camlerp, ctsin)
	-- lerp = 0
	
	camvector.x = eyepos.x + OOBGlitchIntensity
	camvector.y = eyepos.y + OOBGlitchIntensity
	camvector.z = eyepos.z + OOBGlitchIntensity
	
	camang.p = eyeang.p
	camang.y = eyeang.y
	camang.r = eyeang.r
end

local mathrandom = math.random
local function populatetrace(eyepos)
	local af = awareness:GetFloat() or 1000
	randvector.x = eyepos.x+mathrandom(-af,af)
	randvector.y = eyepos.y+mathrandom(-af,af)
	randvector.z = eyepos.z+mathrandom(-af*0.5,af)
	tr.start = eyepos
	tr.endpos = randvector
	tr.output = tr_result
	if !IsValid(tr.filter) then tr.filter = LocalPlayer() end
	util.TraceLine(tr)
	return tr_result
end

local function Echo(t)
	table.insert(soundpoints, t.Pos)
	if !blindedsounds[t.SoundName] and t.SoundName:Left(5)!="lidar" then
		return false
	end
end

local function PopThatMotherfucker()
	hitpoints:pop_left()
	hitcolor:pop_left()
	hitnormal:pop_left()
end

local blindcolor = blindcolor
local fakepopulatevec = Vector(1,2,3)

LOCEntities = LOCEntities or {}
meshtbl = meshtbl or new()
local meshtbl = meshtbl
pausescan = false

glob_blindorigin, glob_blindangles = Vector(), Angle()
curmesh = Mesh()
local lastpointcount = 0
local nextcachecheck = 0

local fliprt = GetRenderTarget( "fb_flipped", ScrW(), ScrH(), false )
local fliprtmat = CreateMaterial(
    "fliprtmat",
    "UnlitGeneric",
    {
        [ '$basetexture' ] = fliprt,
        [ '$basetexturetransform' ] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
    }
)

local function Blindness(origin, angles)

	local stop = hook.Run("PreBlind", origin, angles)
	if stop then return true end
	if blindflip then
		local oldrt = render.GetRenderTarget()
		render.SetRenderTarget( fliprt )
	end
	
	local ply = LocalPlayer()
	origin = origin or ply:EyePos()
	angles = angles or ply:EyeAngles()
	local eyepos = (ply:GetActiveWeapon() and ply:GetActiveWeapon().VMPos) or origin
	local eyeang = angles
	local FT = FrameTime()
	glob_blindorigin:Set(origin)
	glob_blindangles:Set(angles)
	
	local hitpointscount
	local vel_l = ply:GetVelocity():Length()
	local vel = 2.5
	
	if blindflush then
		local randrender = math.Rand(blindrandrendermin,1)
		render.Clear(blindcolor[1]*randrender,blindcolor[2]*randrender,blindcolor[3]*randrender,0)
		render.ClearDepth()
		render.ClearStencil()
	end
	
	if blindpopulate then
		for i=0, FT*blindpopulatespeed do
			if !blindfakepopulate then
				local trace = populatetrace(blindorigin or eyepos)
				if trace.Hit then
					hitpoints:push_right(trace.HitPos)
					hitnormal:push_right(trace.HitNormal)
					
					local hcol = colors[trace.MatType]
					local hcolclass = colorsclass[trace.Entity:GetClass()]
					hitcolor:push_right(hcol or hcolclass or white)
					if hitpoints:length() > limit then
						PopThatMotherfucker()
					end
				end
			else
				hitpoints:push_right(fakepopulatevec)
				hitnormal:push_right(fakepopulatevec)
				hitcolor:push_right(white)
				if hitpoints:length() > limit then
					PopThatMotherfucker()
				end
			end
		end
	end
	
	--[[Pop just incase because if we miss one, we're fucked]]
	hitpointscount = soundpoints:length()
	while hitpointscount > limit do
		soundpoints:pop_left()
		hitpointscount = soundpoints:length()
	end

	RandomizeCam(eyepos,eyeang)
	
	--[[Mul by 0.25 GI later]]
	if sound then sound:ChangeVolume((GlitchIntensity-0.1)) end
	cam.Start3D(camvector,camang)
	
	for k,v in pairs(LOCEntities) do
		if !IsValid(k) then
			LOCEntities[k] = nil
			continue
		end
		k:DrawLOC()
	end
	
	local lastpos = hitpoints[hitpoints.tail]
	local f = eyeang:Forward()
	local eyediff = Vector()
	local k = limit
	local k2 = 0
	
	render.SetMaterial(circle)
	
	if !customglitch then
		GlitchIntensity = OOBGlitchIntensity
	end
	local ed = eyedot
	local anggg = ply:EyeAngles()
	anggg.x = 0
	local eyep = ply:EyePos()+anggg:Forward()*200
	
	if !pausescan then
	local meshQuadEasy = mesh.QuadEasy
	local meshBegin = mesh.Begin
	
	if !curmesh:IsValid() or nextcachecheck > CurTime() then
		local dynmesh
		if nextcachecheck > CurTime() then
			if curmesh:IsValid() then
				curmesh:Destroy()
			end
			dynmesh = meshBegin(MATERIAL_QUADS, limit)
		else
			curmesh = Mesh()
			dynmesh = meshBegin(curmesh, MATERIAL_QUADS, limit)
		end
		for v in hitpoints:iter_right() do
			local col = hitcolor[hitcolor.tail-k2] or BlindGetColor()
			eyediff:Set(v)
			eyediff:Sub(eyepos)
			if f:Dot(eyediff) / eyediff:Length() > ed then
				eyediff:Set(v)
				meshQuadEasy(eyediff,hitnormal[hitnormal.tail-k2],(circlesize),(circlesize),col)
				
				lastpos = v
			end
			k = k-1
			k2 = k2+1
		end
		mesh.End()
		if curmesh:IsValid() then curmesh:Draw() end
	else
		curmesh:Draw()
	end
	
	if lastpointcount != hitpoints:length() then
		nextcachecheck = CurTime()+0.1
	end
	lastpointcount = hitpoints:length()
	
	end
	
	for v in meshtbl:iter_left() do
		v:Draw()
	end
	
	hook.Run("Blind3D", origin, angles)
	cam.End3D()
	hook.Run("Blind3DPost", origin, angles)
	
	local ctsin = math.sin(CurTime())
	local col = white
	col.a = alpha
	
	if blindflip then
		render.SetRenderTarget( oldrt )
		fliprtmat:SetTexture( "$basetexture", fliprt )
		render.SetMaterial( fliprtmat )
		render.DrawScreenQuad()
	end
	
	hook.Run("BlindPostFlip", origin, angles)
	hook.Run("RenderScreenspaceEffects")
	
	if blindflush then
		return true
	end
end

blinded = false
local function BlindnessPreUI()
	if blinded and blindflush then
		cam.Start3D()
		render.Clear(10,10,10,0)
		cam.End3D()
		draw.NoTexture()
	end
end


function ToggleBlindness(toggle)
	blinded = toggle
	if blinded then
		local renderhook = (blindflush and "RenderScene") or "PostRender"
		local ply = LocalPlayer()
		gui.HideGameUI()

		hook.Add("EntityEmitSound","Echo",Echo)
		hook.Add(renderhook,"Blindness",Blindness)
		hook.Add("PreDrawHUD","Blindness",BlindnessPreUI)
		hook.Add("RenderScreenspaceEffects", "CA", RenderCA)
		BlindSetColor(customcolors[1])
		if !sound then sound = CreateSound(LocalPlayer(), "glitch_freq.wav") end
		sound:PlayEx(0, 100)
		hook.Run("Blind", true)
	else
		hook.Remove("EntityEmitSound","Echo")
		hook.Remove("RenderScene","Blindness")
		hook.Remove("PostRender","Blindness")
		hook.Remove("PreDrawHUD","Blindness")
		hook.Remove("RenderScreenspaceEffects", "CA")
		surface.SetAlphaMultiplier( 1 )
		if sound then sound:Stop() end
		
		hook.Run("Blind", false)
	end
end

function cool()
	local k = limit 
	local k2 = 0
	a=Mesh(circle) mesh.Begin(a, MATERIAL_QUADS, limit) local ed=Vector()
	local meshlen = meshtbl:length()
	for v in hitpoints:iter_right() do
		mesh.QuadEasy(v,hitnormal[hitnormal.tail-k2],circlesize,circlesize,hitcolor[hitcolor.tail-k2] or white)
		k = k-1
		k2 = k2+1
	end
	mesh.End()
	meshtbl:push_right(a)
	if meshtbl:length() > meshlimit then
		meshtbl:pop_left():Destroy()
	end
end

net.Receive("BlindPlayers", function()
	ToggleBlindness(net.ReadBool())
end)

net.Receive("BlindNPCKilled", function()
	LocalPlayer():EmitSound("bad.wav", 50, 100+math.random(-5,2))
end)

hook.Add("OnEntityCreated", "BlindnessEntities", function(ent)
	timer.Simple(0.5, function()
		if IsValid(ent) and ent.DrawLOC then
			LOCEntities[ent] = true
		end
	end)
end)


hook.Add( "InputMouseApply", "flipmouse", function( cmd, x, y, angle )
	if !blindflip then return end
    local pitchchange = y * GetConVar( "m_pitch" ):GetFloat()
    local yawchange = x * -GetConVar( "m_yaw" ):GetFloat()
     
    angle.p = angle.p + pitchchange
    angle.y = angle.y + yawchange * -1

    cmd:SetViewAngles( angle )
     
    return true
end)

hook.Add( "CreateMove", "flipmove", function( cmd )
	if !blindflip then return end
	cmd:SetSideMove( -cmd:GetSideMove() )
end)

hook.Add("InitPostEntity", "Beatrun_LOC", function()
	if GetGlobalBool("LOC") then
		ToggleBlindness(true)
	end
	
	--[[Hooks aren't ordered alphabetically, nice try though]]
	hook.Remove("EntityEmitSound", "zzz_TFA_EntityEmitSound")
	hook.Remove("InitPostEntity", "Beatrun_LOC")
end)