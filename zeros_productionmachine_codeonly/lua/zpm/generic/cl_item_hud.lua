zpm = zpm or {}
zpm.HUD = zpm.HUD or {}

function zpm.HUD.Draw(ent, height, ondraw)
	if not zclib.Convar.GetBool("zclib_cl_drawui") then return end
	if zclib.util.InDistance(ent:GetPos(), LocalPlayer():GetPos(), 500) == false then return end
	cam.Start3D2D(ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, height + (1 * math.sin(CurTime() * 2))), zclib.HUD.GetLookAngles(), 0.1)
	pcall(ondraw)
	cam.End3D2D()
end
