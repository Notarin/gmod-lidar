util.PrecacheModel("models/weapons/v_pistol.mdl")
util.PrecacheModel("models/stalker.mdl")
SWEP.PrintName        = "LIDAR"			
SWEP.Slot		= 0
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true


SWEP.Author			= ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.HoldType = "pistol"
 
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.Category = "LIDAR"
 
SWEP.UseHands = true 
 
SWEP.ViewModel			= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"

SWEP.ViewModelFOV = 1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"
 
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"


SWEP.BobScale = 0
SWEP.SwayScale = 0

SWEP.VMPos = Vector()
SWEP.VMAng = Angle()
SWEP.VMPosOffset = Vector()
SWEP.VMAngOffset = Angle()

SWEP.VMPosOffset_Lerp = Vector()
SWEP.VMAngOffset_Lerp = Angle()

SWEP.VMLookLerp = Angle()

SWEP.StepBob = 0
SWEP.StepBobLerp = 0
SWEP.StepRandomX = 1
SWEP.StepRandomY = 1
SWEP.LastEyeAng = Angle()
SWEP.SmoothEyeAng = Angle()

SWEP.LastVelocity = Vector()
SWEP.Velocity_Lerp = Vector()
SWEP.VelocityLastDiff = 0

SWEP.Breath_Intensity = 1
SWEP.Breath_Rate = 1
scancount = 0
local start = false

local coolswayCT = 0
local oldCT = 0
local function LerpC(t,a,b,powa)

return a + (b - a) * math.pow(t,powa)

end

function SWEP:Move_Process(EyePos, EyeAng, velocity)
    local VMPos, VMAng = self.VMPos, self.VMAng
    local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
    local VMPosOffset_Lerp, VMAngOffset_Lerp = self.VMPosOffset_Lerp, self.VMAngOffset_Lerp
    local FT = FrameTime()
    local sightedmult = 1

    VMPos:Set(EyePos)
    VMAng:Set(EyeAng)

    VMPosOffset.x = self:GetOwner():GetVelocity().z*0.0015 * sightedmult
    VMPosOffset.y = math.Clamp(velocity.y*-0.001, -0.25, 0.25) * sightedmult

    VMPosOffset_Lerp.x = Lerp(8*FT, VMPosOffset_Lerp.x, VMPosOffset.x)
    VMPosOffset_Lerp.y = Lerp(8*FT, VMPosOffset_Lerp.y, VMPosOffset.y)
    
    VMAngOffset.x = math.Clamp(VMPosOffset.x * 8, -4, 4)
    VMAngOffset.y = VMPosOffset.y * -1
    VMAngOffset.z = VMPosOffset.y * 0.5 + (VMPosOffset.x * -5)
    
    VMAngOffset_Lerp.x = LerpC(10*FT, VMAngOffset_Lerp.x, VMAngOffset.x, 0.75)
    VMAngOffset_Lerp.y = LerpC(5*FT, VMAngOffset_Lerp.y, VMAngOffset.y, 0.6)
    VMAngOffset_Lerp.z = Lerp(25*FT, VMAngOffset_Lerp.z, VMAngOffset.z)

    VMPos:Add(VMAng:Up() * VMPosOffset_Lerp.x)
    VMPos:Add(VMAng:Right() * VMPosOffset_Lerp.y)
    
    VMAng:Add(VMAngOffset_Lerp)
    
end

local stepend = math.pi*4
function SWEP:Step_Process(EyePos,EyeAng, velocity)
    local CT = CurTime()
    if CT > coolswayCT then
        coolswayCT = CT
    else
        return
    end
    
    local VMPos, VMAng = self.VMPos, self.VMAng
    local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
    local VMPosOffset_Lerp, VMAngOffset_Lerp = self.VMPosOffset_Lerp, self.VMAngOffset_Lerp
    velocity = math.min(velocity:Length(), 500)
	
    local delta = math.abs(self.StepBob*2/(stepend)-1)
    local FT = FrameTime()
    local FTMult = 300 * FT
    local sightedmult = 1
    local sprintmult = 1
	local onground = self:GetOwner():OnGround()
    self.StepBob = self.StepBob + (velocity * 0.00015 + (math.pow(delta, 0.01)*0.03)) * (FTMult)

    if self.StepBob >= stepend then
        self.StepBob = 0
        self.StepRandomX = math.Rand(1,1.5)
        self.StepRandomY = math.Rand(1,1.5)
    end
    
    if velocity == 0 then
        self.StepBob = 0
    end
    
    if onground then
        VMPosOffset.x = (math.sin(self.StepBob) * velocity * 0.000375 * sightedmult) * self.StepRandomX
        VMPosOffset.y = (math.sin(self.StepBob * 0.5) * velocity * 0.0005 * sightedmult) * self.StepRandomY
        VMPosOffset.z = math.sin(self.StepBob * 0.75) * velocity * 0.002 * sightedmult
    end
    
    VMPosOffset_Lerp.x = Lerp(16*FT, VMPosOffset_Lerp.x, VMPosOffset.x)
    VMPosOffset_Lerp.y = Lerp(4*FT, VMPosOffset_Lerp.y, VMPosOffset.y)
    VMPosOffset_Lerp.z = Lerp(2*FT, VMPosOffset_Lerp.z, VMPosOffset.z)
    
    VMAngOffset.x = VMPosOffset_Lerp.x * 2
    VMAngOffset.y = VMPosOffset_Lerp.y * -7.5
    VMAngOffset.z = VMPosOffset_Lerp.y * 5
    
    
    VMPos:Add(VMAng:Up() * VMPosOffset_Lerp.x)
    VMPos:Add(VMAng:Right() * VMPosOffset_Lerp.y)
    VMPos:Add(VMAng:Forward() * VMPosOffset_Lerp.z)
    
    VMAng:Add(VMAngOffset)
end

function SWEP:Breath_Health()
    local owner = self:GetOwner()
    if !IsValid(owner) then return end
    local health = owner:Health()
    local maxhealth = owner:GetMaxHealth()
    
    self.Breath_Intensity = math.Clamp( maxhealth / health, 0, 2 )
    self.Breath_Rate = math.Clamp( ((maxhealth*0.5) / health ), 1, 1.5 )
end

function SWEP:Breath_StateMult()
    local owner = self:GetOwner()
    if !IsValid(owner) then return end
    local sightedmult = 1
    
    self.Breath_Intensity = self.Breath_Intensity * sightedmult
end

function SWEP:Breath_Process(EyePos, EyeAng)
    local VMPos, VMAng = self.VMPos, self.VMAng
    local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
    
    self:Breath_Health()
    self:Breath_StateMult()
    VMPosOffset.x = (math.sin(CurTime() * 2 * self.Breath_Rate) * 0.1) * self.Breath_Intensity
    VMPosOffset.y = (math.sin(CurTime() * 2.5 * self.Breath_Rate) * 0.025) * self.Breath_Intensity
    
    VMAngOffset.x = VMPosOffset.x * 1.5
    VMAngOffset.y = VMPosOffset.y * 2
    
    VMPos:Add(VMAng:Up() * VMPosOffset.x)
    VMPos:Add(VMAng:Right() * VMPosOffset.y)
    
    VMAng:Add(VMAngOffset)
    
end

function SWEP:Look_Process(EyePos, EyeAng)
    local VMPos, VMAng = self.VMPos, self.VMAng
    local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
    local FT = FrameTime()
    local sightedmult = 1
    self.SmoothEyeAng = LerpAngle(FT*5, self.SmoothEyeAng, EyeAng-self.LastEyeAng)

    VMPosOffset.x = -self.SmoothEyeAng.x * -1 * sightedmult
    VMPosOffset.y = self.SmoothEyeAng.y * 0.5 * sightedmult

    VMAngOffset.x = VMPosOffset.x * 2.5
    VMAngOffset.y = VMPosOffset.y * 1.25
    VMAngOffset.z = VMPosOffset.y * 2
    
    self.VMLookLerp.y = Lerp(FT*10, self.VMLookLerp.y, VMAngOffset.y * 1.5 + self.SmoothEyeAng.y)
    
    VMAng.y = VMAng.y - self.VMLookLerp.y
    
    VMPos:Add(VMAng:Up() * VMPosOffset.x)
    VMPos:Add(VMAng:Right() * VMPosOffset.y)
    
    VMAng:Add(VMAngOffset)
    
end

function SWEP:GetVMPosition(EyePos, EyeAng)
	if CurTime() == oldCT then return self.VMPos, self.VMAng end
    local velocity = self:GetOwner():GetVelocity()
    velocity = WorldToLocal(velocity, angle_zero, vector_origin, EyeAng)
    self:Move_Process(EyePos, EyeAng, velocity)
    self:Step_Process(EyePos, EyeAng, velocity)
    self:Breath_Process(EyePos, EyeAng)
    self:Look_Process(EyePos, EyeAng)
    
    self.LastEyeAng = EyeAng
    self.LastEyePos = EyePos
    self.LastVelocity = velocity

	-- self.VMAng:Add(offsetang)
	oldCT = CurTime()
    return self.VMPos, self.VMAng
end

function SWEP:GetViewModelPosition(eyepos, eyeang)
	return self:GetVMPosition(eyepos, eyeang)
end


function SWEP:SetupDataTables()
end

function SWEP:Deploy()
	self:CallOnClient("Deploy")
	self:SetHoldType( self.HoldType )
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.NextBurst = 0
	self.BurstStep = 0
	self.BurstSound = 1
	self.Burst = false
	if !self.BurstSounds then
		self.BurstSounds = {
			CreateSound(self, "lidar/burst1.wav"),
			CreateSound(self, "lidar/burst2.wav"),
			CreateSound(self, "lidar/burst3.wav"),
			CreateSound(self, "lidar/burst4.wav")
		}
		self.ScanSound = CreateSound(self, "lidar/scan.wav")
		self.ScanSound:ChangeVolume(0.25)
	end
end


function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.NextBurst = 0
	self.NextCooldownSound = 0
	self.BurstStep = 0
	self.BurstSound = 1
	self.Burst = false
	if !self.BurstSounds then
		self.BurstSounds = {
			CreateSound(self, "lidar/burst1.wav"),
			CreateSound(self, "lidar/burst2.wav"),
			CreateSound(self, "lidar/burst3.wav"),
			CreateSound(self, "lidar/burst4.wav")
		}
		self.ScanSound = CreateSound(self, "lidar/scan.wav")
		self.ScanSound:ChangeVolume(0.25)
	end
	Material("models/weapons/v_pistol/v_pistol_sheet"):SetVector("$envmaptint",vector_origin)
	if CLIENT then
		timer.Simple(1, function()
			if IsValid(scanner) then scanner:Remove() end
			scanner = ClientsideModel("models/weapons/v_pistol.mdl")
			local scanmatrix = Matrix()
			scanmatrix:SetRight(-scanmatrix:GetRight())
			scanner:SetNoDraw(true)
			scanner:EnableMatrix("RenderMultiply",scanmatrix)
		end)
		timer.Simple(1, function()
			local a = ClientsideModel("models/stalker.mdl")
			a:DrawModel()
			a:Remove()
		end)
	end
end


local didfleshstutter = false
function SWEP:AdvanceBurst()
	self.BurstStep = self.BurstStep + 0.001
	if self.BurstStep > 0.8 then
		self.Burst = false
		self.BurstStep = 0
		if self.BurstSound and !isnumber(self.BurstSound) then
			self.BurstSound:Stop()
		end
		didfleshstutter = false
	end
end


function SWEP:Holster()
	if self.ScanSound then
		self.ScanSound:Stop()
	end
	if self.BurstSound and !isnumber(self.BurstSound) then
		self.BurstSound:Stop()
	end
	return true
end

function SWEP:OnRemove()
	if self.ScanSound then
		self.ScanSound:Stop()
	end
	if self.BurstSound and !isnumber(self.BurstSound) then
		self.BurstSound:Stop()
	end
end

local red = Color(255,0,0)
local blue = Color(0,0,255)
local white = Color(210,159,110,255)
local green = Color(0,255,0)
local grass = Color(20,150,10)
local sand = Color(76,70,50)
local glass = Color(10,20,150)
local hitpoints = hitpoints
local hitnormal = hitnormal
local hitcolor = hitcolor
local DrawLine
if CLIENT then
	DrawLine = render.DrawLine
end

local colorsclass = {
["prop_door_rotating"] = green,
["func_door_rotating"] = green,
["func_door"] = green
}

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

local randvector = Vector()
local limit = 2500
local tr = {}
local tr_result = {}
local conesize = 0.95
local fleshcount = 0
local ignoreflesh = false
local nextflesh = 0
local nextfleshstutter = 0
dreamcatcher = false
local function populatetraceburst(eyepos, forward, right, up, burstnum, burstcap, self)
	local af = 100000
	randvector:Set(vector_origin)
	randvector:Add(forward)
	randvector:Add(right*Lerp(burstcap+math.Rand(-0.01,0.01), -1, 1))
	
	
	randvector:Mul(10000)
	randvector:Add(eyepos)
	
	tr.start = eyepos
	tr.endpos = randvector
	tr.output = tr_result
	if !IsValid(tr.filter) then tr.filter = LocalPlayer() end
	util.TraceLine(tr)
	return tr_result
end

local function populatetrace(eyepos, forward, right, up)
	local af = 100000
	randvector:Set(vector_origin)
	local spread
	spread = Vector(math.Rand(-1,1), math.Rand(-1,1), 0):GetNormalized() * conesize
	spread:Rotate(up:Angle())
	spreadang = spread:Angle()
	spreadang.x = spreadang.x * math.Rand(-1,1)
	spreadang.y = spreadang.y * math.Rand(-1,1)
	spread:Rotate(spreadang)
	randvector:Add(spread)
	
	randvector:Add(forward)
	
	
	randvector:Mul(10000)
	randvector:Add(eyepos)
	
	tr.start = eyepos
	tr.endpos = randvector
	tr.output = tr_result
	if !IsValid(tr.filter) then tr.filter = LocalPlayer() end
	util.TraceLine(tr)
	return tr_result
end

function PopThatMotherfucker()
	hitpoints:pop_left()
	hitcolor:pop_left()
	hitnormal:pop_left()
end

local scanlines = {}
function SWEP:PrimaryAttack()
	if InTerminal then return false end
	table.Empty(scanlines)
	self:CallOnClient("PrimaryAttack")
	self:SetNextPrimaryFire( CurTime() )
	if SERVER or self.Burst then return end
	if !self.ScanSound:IsPlaying() then
		self.ScanSound:PlayEx(0.4, (conesize*-25)+125)
	end
	local ply = self.Owner
	local eyepos = glob_blindorigin
	local eyeang = glob_blindangles
	local forward = eyeang:Forward()
	local right = eyeang:Right()
	local up = eyeang:Up()
	local FT = FrameTime()
	for i=0, FT*5000 do
		local trace = populatetrace(eyepos, forward, right, up)
		if trace.Hit and !trace.HitSky and (!ignoreflesh or trace.MatType != MAT_FLESH) then
			if trace.MatType == MAT_FLESH and IsValid(trace.Entity) and trace.Entity:GetClass() == "npc_stalker" then
				fleshcount = fleshcount+3
			end
			hitpoints:push_right(trace.HitPos)
			hitnormal:push_right(trace.HitNormal)
			table.insert(scanlines, trace.HitPos)
			
			local hcol = colors[trace.MatType]
			local hcolclass = colorsclass[trace.Entity:GetClass()]
			hitcolor:push_right(hcol or hcolclass or BlindGetColor())
		elseif ignoreflesh and CurTime() > nextfleshstutter and trace.Hit and !trace.HitSky then
			nextfleshstutter = CurTime()+2
			self:EmitSound("lidar/stutter"..math.random(1,14)..".wav")
			GlitchIntensity = 0.75
		end
	end

	if hitpoints:length()+1 > limit then
		cool()
		for i=1, hitpoints:length() do
			PopThatMotherfucker()
		end
	end
end

if CLIENT then
local linec = Color(150,10,10,25)
scanner = scanner or ClientsideModel("models/weapons/v_pistol.mdl")
local burstshake = Vector()
local firepull = 0
local scanmatrix = Matrix()
scanmatrix:SetRight(-scanmatrix:GetRight())
scanner:SetNoDraw(true)
scanner:EnableMatrix("RenderMultiply",scanmatrix)
local inattack = false
hook.Add("Blind3DPost", "Scanner", function(origin,angles)
	if !IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() != "lidarscanner" then return end
	local wep = LocalPlayer():GetActiveWeapon()
	cam.Start3D()
	cam.IgnoreZ(true)
	scanner.RenderOverride = nil
	render.SuppressEngineLighting(true)
	render.ResetModelLighting(0,0,0)
	render.CullMode(1)
	local spos, sang = wep:GetVMPosition(origin,angles)
	local scannerpos = spos-sang:Up()*2-sang:Forward()*(10+firepull)
	if wep.Burst then
		burstshake:SetUnpacked(math.Rand(-0.025,0.025), math.Rand(-0.025,0.025), math.Rand(-0.025,0.025))
		scannerpos:Add(burstshake)
		render.SetModelLighting(BOX_TOP,0.5,0,0)
	end
	if LocalPlayer():KeyDown(IN_ATTACK) and !wep.Burst then
		burstshake:SetUnpacked(math.Rand(-0.03,0.03), math.Rand(-0.03,0.03), math.Rand(-0.03,0.03))
		scannerpos:Add(burstshake)
		render.SetModelLighting(BOX_TOP,0.5,0,0)
		firepull = math.Approach(firepull, 0.25, FrameTime())
		inattack = true
	else
		firepull = math.Approach(firepull, 0, FrameTime()*6)
		if wep.ScanSound and LocalPlayer():GetActiveWeapon().ScanSound:IsPlaying() then
			wep.ScanSound:Stop()
			wep:EmitSound("lidar/scanstop.wav")
		end
		inattack = false
	end
	
	if !start and (inattack or wep.Burst) then
		start = true
		LocalPlayer():EmitSound("start.mp3")
	end
	
	if blindflush then
	scanner:SetPos(scannerpos)
	scanner:SetAngles(sang)
	scanner:DrawModel()


	render.SetStencilWriteMask( 0xFF ) 
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )

	scanner:DrawModel()
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )

	cam.Start2D()
	draw_blur(2,2)
	cam.End2D()
	render.SetStencilEnable( false )

	render.CullMode(0)
	local muzzle = scanner:GetAttachment(1).Pos
	for k,v in ipairs(scanlines) do
		DrawLine(muzzle, v, linec, true)
	end
	if !inattack then
		table.Empty(scanlines)
	end
	render.SuppressEngineLighting(false)
	else
		render.CullMode(0)
	end
	cam.End3D()
	cam.IgnoreZ(false)
end)

hook.Add("CreateMove", "BurstSlow", function(cmd)
	local wep = LocalPlayer():GetActiveWeapon()
	if wep and wep.Burst then
		cmd:SetForwardMove(cmd:GetForwardMove()*0.005)
		cmd:SetSideMove(cmd:GetSideMove()*0.005)
	end
end)

end

local nextres = 0
function SWEP:SecondaryAttack(forced)
	self:CallOnClient("SecondaryAttack")
	if InTerminal and !forced then
		return false
	elseif !Interminal then
		forced = nil
	end
	local ply = self.Owner
	if !self.Burst and (CurTime() > self.NextBurst or GetConVar("sv_cheats"):GetBool()) then
		self.Burst = true
		self.NextBurst = CurTime()+1 --[[Used to be 6, but renonced the cooldown mechanic]]
		if !InTerminal then
			self.BurstSound = self.BurstSounds[math.random(1,4)]
			self.BurstSound:ChangeVolume(0)
			self.BurstSound:Play()
		end
		if CLIENT and !dreamcatcher and math.random() > 0.75 and meshtbl:length() > meshlimit*0.75 then
			net.Start("BurstScanning")
			net.SendToServer()
		end
	elseif !self.Burst and CurTime() <= self.NextBurst and CurTime() > self.NextCooldownSound then
		self:EmitSound("lidar/cooldown.wav", 30)
		self.NextCooldownSound = CurTime()+4
	end
end


function SWEP:Reload(forced)
	self:CallOnClient("Reload")
	if SERVER then return end
	if (!forced or type(forced)=="string") and !GetConVar("sv_cheats"):GetBool() then return end
	for i=1, hitpoints:length() do
		PopThatMotherfucker()
	end
	
	for v in meshtbl:iter_left() do
		v:Destroy()
		meshtbl:pop_left()
	end
end



function SWEP:Think()
	if SERVER then return end
	if self.Owner:KeyDown(IN_DUCK) then
		conesize = math.Approach(conesize, 0.05, FrameTime()*0.5)
		if LocalPlayer():GetActiveWeapon().ScanSound:IsPlaying() then
			LocalPlayer():GetActiveWeapon().ScanSound:ChangePitch((conesize*-25)+125,0)
		end
	elseif self.Owner:KeyDown(IN_SPEED) then
		conesize = math.Approach(conesize, 0.95, FrameTime()*0.5)
		if LocalPlayer():GetActiveWeapon().ScanSound:IsPlaying() then
			LocalPlayer():GetActiveWeapon().ScanSound:ChangePitch((conesize*-25)+125,0)
		end
	end
	if self.Burst then
		local ply = self.Owner
		local eyepos = glob_blindorigin
		local eyeang = Angle(glob_blindangles)
		eyeang.x = Lerp(self.BurstStep, eyeang.x-65, eyeang.x+75)
		local forward = eyeang:Forward()
		local right = eyeang:Right()
		local up = eyeang:Up()
		local FT = FrameTime()
		local burstcap = 100
		
		local vol = math.min(math.abs(self.BurstStep-0.8)*10, 1)
		if !isnumber(self.BurstSound) then
			self.BurstSound:ChangeVolume(vol)
		end
		for burstnum=0, burstcap do
			local trace = populatetraceburst(eyepos, forward, right, up, burstnum, (burstnum/burstcap), self)
			if trace.Hit and !trace.HitSky and (!ignoreflesh or trace.MatType != MAT_FLESH) then
				if trace.MatType == MAT_FLESH and IsValid(trace.Entity) and trace.Entity:GetClass() == "npc_stalker" then
					fleshcount = fleshcount+1
				end
				hitpoints:push_right(trace.HitPos)
				hitnormal:push_right(trace.HitNormal)
				table.insert(scanlines, trace.HitPos)
				
				local hcol = colors[trace.MatType]
				local hcolclass = colorsclass[trace.Entity:GetClass()]
				hitcolor:push_right(hcol or hcolclass or BlindGetColor())
			elseif ignoreflesh and !InTerminal and !didfleshstutter and trace.Hit and !trace.HitSky then
				didfleshstutter = true
				self:EmitSound("lidar/stutter"..math.random(1,14)..".wav")
				GlitchIntensity = 0.75
			end
		end
		
		if hitpoints:length()+1 > limit then
			cool()
			for i=1, hitpoints:length() do
				PopThatMotherfucker()
			end
		end
		self:AdvanceBurst()
	end
	
	GlitchIntensity = (ignoreflesh and GlitchIntensity+OOBGlitchIntensity) or (fleshcount*0.005+OOBGlitchIntensity)
	if GlitchIntensity > 0 and CurTime() > nextflesh and OOBGlitchIntensity == 0 then
		fleshcount = fleshcount+5
		nextflesh = CurTime()+0.3
	end
	
	if ignoreflesh then
		GlitchIntensity = math.min(math.Approach(GlitchIntensity, 0, FrameTime()*0.25), 2)
	end
	
	if GlitchIntensity > 0.3 and !ignoreflesh and fleshcount > 0 then
		timer.Simple(0.25, function()
			BlindSetColor(customcolors[3])
			for i=1, hitpoints:length() do
				PopThatMotherfucker()
			end
			
			for v in meshtbl:iter_left() do
				v:Destroy()
				meshtbl:pop_left()
			end
			ignoreflesh = true
			fleshcount = 0
			self.BurstStep = 1
			self:AdvanceBurst()
			self.NextBurst = 0
			Event_TerminalStart()
			self:SecondaryAttack(true)
			GlitchIntensity = 0
		end)
	end
end

if SERVER then
	util.AddNetworkString("BurstScanning")
	util.AddNetworkString("LIDAR_RSCReset")
	util.AddNetworkString("LIDAR_SndReset")
	function Researcher_GetSpawnPoint()
		local navarea = navmesh.GetNearestNavArea(Entity(1):GetPos(), false, 5000, true)
		if navarea and navarea:IsValid() then
			local eyepos = Entity(1):EyePos()
			local plyf = Entity(1):EyeAngles()
			plyf = plyf:Forward()
			local point
			local running = Entity(1):GetVelocity():Length() > 100
			for i=0, 100 do
				point = navarea:GetRandomPoint()
				local eyediff = point-eyepos
				local los = plyf:Dot(eyediff) / eyediff:Length() > 0.8
				local dist = eyepos:Distance(point)
				if dist > 200 and (dist < 1000 or running) and los then
					nextres = CurTime()+45
					return point
				end
			end
		end
	end
	
	net.Receive("LIDAR_RSCReset", function(len, ply)
		for k,v in ipairs(ents.GetAll()) do
			if IsValid(v) and v:GetClass() == "npc_stalker" then
				v:Remove()
			end
		end
	end)
	
	net.Receive("LIDAR_SndReset", function(len, ply)
		hook.Remove("EntityEmitSound", "Echo")
	end)
	
	function Researcher_Spawn()
		local pos = Researcher_GetSpawnPoint()
		if pos then
			local r = ents.Create("npc_stalker")
			r:SetPos(pos)
			local plypos = Entity(1):GetPos()
			plypos.z = pos.z
			r:SetAngles((plypos-pos):Angle())
			r:Spawn()
			r:NextThink(CurTime()+99999)
			r:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			timer.Simple(10, function() if IsValid(r) then r:Remove() end end)
			return r
		end
	end
	
	net.Receive("BurstScanning", function(len, ply)
		if CurTime() > nextres then
			Researcher_Spawn()
		end
	end)
end