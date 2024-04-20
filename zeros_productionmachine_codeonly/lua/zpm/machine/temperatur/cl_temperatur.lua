zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	While the machine is producing it will change its Temperatur goal
	The player needs to adjust the Temperatur pointer in order for the Temperatur to stay cool
	Failing to adjust the Temperatur pointer to the goal will cause the Temperatur to go up

*/

local Temperatur = zpm.Machine.Temperatur or {}

local temp_range_target = Color(194, 0, 0,50)
local temp_range_pointer = Color(86, 114, 194)

local function DrawButton(x,y,rot,hover)
	//hover = true
	draw.RoundedBox(0, x - 80, y - 80, 160, 160, zclib.colors[ "black_a100" ])
	zclib.util.DrawOutlinedBox(x - 80, y - 80, 160, 160, 10, hover and color_white or zclib.colors[ "black_a100" ])
	surface.SetDrawColor(hover and color_white or zclib.colors[ "black_a100" ])
	surface.SetMaterial(zclib.Materials.Get("back"))
	surface.DrawTexturedRectRotated(x, y, 100, 100, rot)
end

local indicator_pos = Vector(-82.8, -56.2, 42.7)
local indicator_ang = Angle(0,0,90)

local liquid_pos = Vector(-70, -70, 25.5)
local liquid_ang = Angle(0,0,52)
function Temperatur:Draw(Machine)

	if not zpm.config.Machine.Temperatur.enabled then return end

	if not Machine:GetIsRunning() then return end

	/*
		Temperatur Indicator
	*/
	cam.Start3D2D(Machine:LocalToWorld(indicator_pos) , Machine:LocalToWorldAngles(indicator_ang), 0.1)

		local curTemp = Machine:GetTemperatur()
		if curTemp > 75 then
			local pulse = math.abs(math.sin(CurTime() * 5)) * 60
			surface.SetDrawColor(Color(255,0,0,150))
			surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
			surface.DrawTexturedRectRotated(0, 0, 100 + pulse, 100 + pulse, 0)
		end

		draw.SimpleText(curTemp .. "°", zclib.GetFont("zclib_font_large"), 0, 0, zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	/*
		Temperatur Liquid Tank
	*/
	cam.Start3D2D(Machine:LocalToWorld(liquid_pos) , Machine:LocalToWorldAngles(liquid_ang), 0.05)
		draw.RoundedBox(0, -170, -80, 340, 160, zclib.colors[ "black_a100" ])

		local size = 340 / 10

		local tPos = (340 / 10) * Machine:GetTemperaturTarget()
		draw.RoundedBox(0, tPos - 170 - size, -70, size, 140, temp_range_target)

		local pPos = (340 / 10) * Machine:GetTemperaturPointer()
		draw.RoundedBox(0, pPos - 170 - size, -70, size, 140, temp_range_pointer)

		zclib.util.DrawOutlinedBox(-170, -80, 340, 160, 10, zclib.colors[ "black_a100" ])

		DrawButton(-260,0,0,Temperatur:OnLeft(Machine,LocalPlayer()))

		DrawButton(260,0,180,Temperatur:OnRight(Machine,LocalPlayer()))
	cam.End3D2D()
end

local explode_pos = Vector(-82.8, -56.2, 42.7)
net.Receive("zpm.Machine.Temperatur.Explode", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if not Machine:IsValid() then return end

	local Pos = Machine:LocalToWorld(explode_pos)

	local effectdata = EffectData()
	effectdata:SetStart(Pos)
	effectdata:SetOrigin(Pos)
	effectdata:SetScale(0.1)
	effectdata:SetMagnitude(1)
	effectdata:SetRadius(1)
	util.Effect("HelicopterMegaBomb", effectdata, true, true)

	sound.Play("ambient/explosions/explode_4.wav", Pos, 65, 100,1)
end)

zpm.Machine.Temperatur = Temperatur
