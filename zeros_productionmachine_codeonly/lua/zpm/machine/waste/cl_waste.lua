zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	While the machine is producing something it will also create waste as a By-Product
	This waste needs to be cleaned away or it could start a dumpster fire which damages the machine and reduces the machines health

*/

local Waste = zpm.Machine.Waste or {}

local waste_ui_pos = Vector(-179,-39,37)
local waste_ui_ang = Angle(0,-90,90)

local waste_effect_pos = Vector(-155, -39, 75)
function Waste:Draw(Machine)

	if not zpm.config.Machine.Waste.enabled then return end


	local waste = Machine:GetWaste()
	Machine:ManipulateBonePosition(Machine:LookupBone("waste_jnt"), Vector(-13 + (15.5 / zpm.config.Machine.Waste.Capacity) * waste, 0, 0))

	if not Machine:GetIsRunning() then return end

	if Machine.LastWaste ~= waste then
		if Machine.LastWaste and waste > Machine.LastWaste then
			local pos = Machine:LocalToWorld(waste_effect_pos)
			if zclib.Convar.GetBool("zpm_cl_effects") then
				zclib.Effect.ParticleEffect("zpm_trashfall",pos, angle_zero, Machine)
			end
			zclib.Sound.EmitFromPosition(pos,"zpm_trashfall")
		end
		Machine.LastWaste = waste
	end


	cam.Start3D2D(Machine:LocalToWorld(waste_ui_pos) , Machine:LocalToWorldAngles(waste_ui_ang), 0.05)

		draw.RoundedBox(0, -300, -80, 600, 160, zclib.colors[ "black_a200" ])
		local barW = math.Clamp((600 / zpm.config.Machine.Waste.Capacity) * waste,0,600)
		draw.RoundedBox(0, -300, -80, barW, 160, zclib.colors[ "red01" ])

		zclib.util.DrawOutlinedBox(-300, -80, 600, 160, 10,  zclib.colors[ "black_a200" ])
		draw.SimpleText(zpm.language["Waste"] .. ": " .. waste, zclib.GetFont("zclib_font_giant"), 0, 0,  zclib.colors["black_a200"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if Waste:OnButton(Machine,LocalPlayer()) then
			draw.SimpleText("> " .. zpm.language["Clear"] .. " <", zclib.GetFont("zclib_font_giant"), 0, -135, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end


	cam.End3D2D()
end

local waste_effect02_pos = Vector(-170, -39, 39)
net.Receive("zpm.Machine.ClearWaste", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	local pos = Machine:LocalToWorld(waste_effect02_pos)

	zclib.Sound.EmitFromPosition(pos,"zpm_trash_break")

	if zclib.Convar.GetBool("zpm_cl_effects") then
		zclib.Effect.ParticleEffect("zpm_trash_break",pos, angle_zero, Machine)
	end
end)

net.Receive("zpm.Machine.Waste.Explode", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if not Machine:IsValid() then return end

	local Pos = Machine:LocalToWorld(waste_effect02_pos)

	sound.Play("ambient/explosions/explode_4.wav", Pos, 65, 100,1)

	if zclib.Convar.GetBool("zpm_cl_effects") then
		local effectdata = EffectData()
		effectdata:SetStart(Pos)
		effectdata:SetOrigin(Pos)
		effectdata:SetScale(0.1)
		effectdata:SetMagnitude(1)
		effectdata:SetRadius(1)
		util.Effect("HelicopterMegaBomb", effectdata, true, true)

		zclib.Effect.ParticleEffect("zpm_trash_break",Pos, angle_zero, Machine)
	end
end)



zpm.Machine.Waste = Waste
