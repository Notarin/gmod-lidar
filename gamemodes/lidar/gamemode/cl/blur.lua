local blur = Material("pp/blurscreen")
function draw_blur( a, d )

	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )
	for i = 1, d do
	
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		
	end
	
end
local draw_blur = draw_blur
local impactblurlerp = 0
local lastintensity = 0
hook.Add("HUDPaint", "DrawImpactBlur", function()
	if impactblurlerp > 0 then
		impactblurlerp = math.Approach(impactblurlerp, 0, 25*FrameTime())
		draw_blur(math.min(impactblurlerp, 10), 4)
	end
end)

function DoImpactBlur(intensity)
	impactblurlerp = intensity
	lastintensity = intensity
end