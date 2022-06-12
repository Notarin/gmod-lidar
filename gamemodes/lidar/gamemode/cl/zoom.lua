local zooming = false
local zoomfov = 0
local lightkey = input.GetKeyCode(input.LookupBinding( "impulse 100" ) or 0)

local view = {}
hook.Add( "CalcView", "MyCalcView", function( ply, pos, angles, fov )
	local mult = (zoomfov+1)*7.5
	zoomfov = math.Approach(zoomfov, ((input.IsButtonDown(lightkey) and -50) or 0), FrameTime()*(100-mult))
	view.origin = pos
	view.angles = angles
	view.fov = fov+zoomfov

	return view
end )