zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The repair event will occure randomly and forces the player to fix the broken machine in a certain amount of time
	The repair minigame will be randomized

*/

local Repair = zpm.Machine.Repair or {}

net.Receive("zpm.Machine.Repair.Update", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if not Machine:IsValid() then return end

	local start = net.ReadUInt(32)

	local order = {}
	for i = 1, 3 do order[i] = net.ReadUInt(2) end

	local state = {}
	for i = 1, 3 do state[i] = net.ReadBool() end

	Machine.Repair = {
		Start = start,
		Order = order,
		State = state
	}
end)

local repair_pos = Vector(-127, -39, 120)
net.Receive("zpm.Machine.Repair.Failed", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if not Machine:IsValid() then return end

	Machine:EmitSound("zpm_machine_action_failed")

	local Pos = Machine:LocalToWorld(repair_pos)
	sound.Play("ambient/energy/zap" .. math.random(9) .. ".wav", Pos, 65, 100,0.02)
	if zclib.Convar.GetBool("zpm_cl_effects") then zclib.Effect.ParticleEffect("zpm_electro",Pos, angle_zero, Machine) end
end)

net.Receive("zpm.Machine.Repair.Start", function(len)

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if not Machine:IsValid() then return end

	local Pos = Machine:LocalToWorld(repair_pos)

	local effectdata = EffectData()
	effectdata:SetStart(Pos)
	effectdata:SetOrigin(Pos)
	effectdata:SetScale(0.1)
	effectdata:SetMagnitude(1)
	effectdata:SetRadius(1)
	util.Effect("HelicopterMegaBomb", effectdata, true, true)

	sound.Play("ambient/explosions/explode_4.wav", Pos, 65, 100,1)

	if zclib.Convar.GetBool("zpm_cl_effects") then zclib.Effect.ParticleEffect("zpm_electro",Pos, angle_zero, Machine) end
end)


local repair_pos01 = Vector(-120, -39.4, 119.3)
local repair_ang01 = Angle(0,-90,0)

local repair_pos02 = Vector(-123.5, -39.4, 118.5)
local repair_ang02 = Angle(0,-90,30)

local repair_pos03 = Vector(-117.3, -39.4, 144.5)
local repair_ang03 = Angle(0,-90,90)

local function DrawColorCable(x,y,state)
	draw.RoundedBox(0, x - 5, y - 105, 10, 120, zclib.colors[ "black_a200" ])
	draw.RoundedBox(0, x - 3, y - 105, 6, 120, state and zclib.colors[ "green01" ] or zclib.colors[ "red01" ])
end

local function DrawButton(x,y,txt,hover)
	draw.SimpleText(txt, zclib.GetFont("zclib_font_bigger"), x, y,hover and color_white or zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	zclib.util.DrawOutlinedBox(x - 25, y - 25, 50, 50, 6, hover and color_white or zclib.colors[ "black_a200" ])
end

local function DrawHint(x,y,txt,pressed)
	draw.SimpleText(txt, zclib.GetFont("zclib_font_bigger"), x, y, pressed and zclib.colors[ "green01" ] or zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	zclib.util.DrawOutlinedBox(x - 25, y - 25, 50, 50, 4, pressed and zclib.colors[ "green01" ] or zclib.colors[ "black_a200" ])
end

function Repair:Draw(Machine)

	Machine:ManipulateBoneAngles(Machine:LookupBone("exit_top_door_jnt"),Angle(0,0,Machine.AccessPanelDoorSmooth or 0))

	Machine.AccessPanelDoorSmooth = math.Clamp(math.Round(Lerp(FrameTime() * 5,Machine.AccessPanelDoorSmooth or 0,Machine.AccessPanelDoorState or 120),2),0,120)

	if Machine.AccessPanelDoorSmooth < 3 then Machine.AccessPanelDoorSmooth = 0 end

	if not Machine:GetIsRunning() then
		Machine.AccessPanelDoorState = 120
		return
	end

	Machine.AccessPanelDoorState = Machine:GetNeedsRepair() and 0 or 120

	if not zpm.config.Machine.Repair.enabled then return end

	if not Machine:GetNeedsRepair() then return end
	if not Machine.Repair then return end

	if not Machine.NextRepairEffect or CurTime() > Machine.NextRepairEffect then
		local pos = Machine:LocalToWorld(repair_pos)
		if zclib.Convar.GetBool("zpm_cl_effects") then zclib.Effect.ParticleEffect("zpm_electro",pos, angle_zero, Machine) end
		sound.Play("ambient/energy/zap" .. math.random(9) .. ".wav", pos, 65, 100,0.02)
		Machine.NextRepairEffect = CurTime() + 1
	end

	if Machine.Repair.State then
		cam.Start3D2D(Machine:LocalToWorld(repair_pos01) , Machine:LocalToWorldAngles(repair_ang01), 0.1)

			for index,pos in ipairs(Machine.Repair.Order) do
				local place = 0
				if pos == 1 then
					place = -99
				elseif pos == 3 then
					place = 99
				end
				DrawColorCable(place,0,Machine.Repair.State[index])
			end
		cam.End3D2D()
	end

	cam.Start3D2D(Machine:LocalToWorld(repair_pos02) , Machine:LocalToWorldAngles(repair_ang02), 0.05)
		DrawButton(-198, 0,"1",zpm.Machine.Repair:OnButton(Machine, LocalPlayer(), 1))
		DrawButton(0, 0,"2",zpm.Machine.Repair:OnButton(Machine, LocalPlayer(), 2))
		DrawButton(198, 0,"3",zpm.Machine.Repair:OnButton(Machine, LocalPlayer(), 3))
	cam.End3D2D()

	if Machine.AccessPanelDoorSmooth > 0 then return end

	if Machine.Repair.Order then
		cam.Start3D2D(Machine:LocalToWorld(repair_pos03) , Machine:LocalToWorldAngles(repair_ang03), 0.1)

			if Machine.Repair.State[Machine.Repair.Order[1]] and Machine.Repair.State[Machine.Repair.Order[2]] and Machine.Repair.State[Machine.Repair.Order[3]] then
				draw.SimpleText(zpm.language["FIXED"], zclib.GetFont("zclib_font_large"), 0, 0,zclib.colors[ "green01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				zclib.util.DrawOutlinedBox(-100, -30, 200, 60, 4, zclib.colors[ "green01" ])
			else

				draw.SimpleText("-| " .. zpm.language[ "CODE" ] .. " |-", zclib.GetFont("zclib_font_large"), 0, -65, zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				DrawHint(-99, 0,Machine.Repair.Order[1],Machine.Repair.State[1])
				DrawHint(0, 0,Machine.Repair.Order[2],Machine.Repair.State[2])
				DrawHint(99, 0,Machine.Repair.Order[3],Machine.Repair.State[3])

				draw.SimpleText(">", zclib.GetFont("zclib_font_large"), -47, 0,zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(">", zclib.GetFont("zclib_font_large"), 47, 0,zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if Machine.Repair.Start then
					draw.RoundedBox(0,  -125,  60, 250, 20, zclib.colors[ "black_a200" ])
					local remain = math.Clamp((Machine.Repair.Start + zpm.config.Machine.Repair.Time) - CurTime(), 0, zpm.config.Machine.Repair.Time)
					local barW = (250 / zpm.config.Machine.Repair.Time) * remain
					draw.RoundedBox(0, -125, 60, barW, 20, color_white)
				end
			end
		cam.End3D2D()
	end
end

zpm.Machine.Repair = Repair
