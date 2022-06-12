local rx, gx, bx, ry, gy, by = 0, 0, 0, 0, 0, 0
local black = Material("vgui/black")
local ca_r = CreateMaterial( "ca_r", "UnlitGeneric", {
["$basetexture"] = "vgui/black",
["$color2"] = "[1 0 0]",
["$additive"] = 1,
["$ignorez"] = 1
} )
local ca_g = CreateMaterial( "ca_g", "UnlitGeneric", {
["$basetexture"] = "vgui/black",
["$color2"] = "[0 1 0]",
["$additive"] = 1,
["$ignorez"] = 1
} )
local ca_b = CreateMaterial( "ca_b", "UnlitGeneric", {
["$basetexture"] = "vgui/black",
["$color2"] = "[0 0 1]",
["$additive"] = 1,
["$ignorez"] = 1
} )

local function CA( rx, gx, bx, ry, gy, by )
	render.UpdateScreenEffectTexture()
	local screentx = render.GetScreenEffectTexture()
	ca_r:SetTexture( "$basetexture", screentx)
	ca_g:SetTexture( "$basetexture", screentx)
	ca_b:SetTexture( "$basetexture", screentx)
	render.SetMaterial( black )
	render.DrawScreenQuad()
	render.SetMaterial( ca_r )
	render.DrawScreenQuadEx( -rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry )
	render.SetMaterial( ca_g )
	render.DrawScreenQuadEx( -gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy )
	render.SetMaterial( ca_b )
	render.DrawScreenQuadEx( -bx / 2, -by / 2, ScrW() + bx, ScrH() + by )
end


function RenderCA()
	rx = 10
	ry = 10
	gx = 10 * (GlitchIntensity*5 or 1)
	gy = 10 * (GlitchIntensity*5 or 1)
	bx = 2 * (GlitchIntensity*5 or 1)
	by = 2 * (GlitchIntensity*5 or 1)
	CA( rx, gx, bx, ry, gy, by )

	local gi = math.max(1, GlitchIntensity*4)
	DrawMotionBlur( 0.25, 0.75*GlitchIntensity, 0.005 )
	DrawBloom( 0, 0.5, 0.1*gi, 0.1*gi, 1, 1, 1, 1, 1 )
end