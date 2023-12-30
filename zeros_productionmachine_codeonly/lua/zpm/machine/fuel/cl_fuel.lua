zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	The machine runs on fuel which need to be refilled after some time

*/

local Fuel = zpm.Machine.Fuel or {}

local fuel_ui_pos = Vector(-174,10,25)
local fuel_ui_ang = Angle(0,-90,90)
function Fuel:Draw(Machine)

	if not zpm.config.Machine.Fuel.enabled then return end

	cam.Start3D2D(Machine:LocalToWorld(fuel_ui_pos) , Machine:LocalToWorldAngles(fuel_ui_ang), 0.05)

		draw.RoundedBox(0, -300, -80, 600, 160, zclib.colors[ "black_a200" ])
		local barW = (600 / zpm.config.Machine.Fuel.Capacity) * Machine:GetFuel()
		draw.RoundedBox(0, -300, -80, barW, 160, zclib.colors[ "orange01" ])

		draw.SimpleText(zpm.language["Fuel"] .. ": "..Machine:GetFuel(), zclib.GetFont("zclib_font_giant"), 0, 0, zclib.colors["black_a200"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		zclib.util.DrawOutlinedBox(-300, -80, 600, 160, 10, zclib.colors[ "black_a200" ])

		if zpm.Machine.Fuel:OnButton(Machine, LocalPlayer()) then
			draw.SimpleText("> " .. zpm.language[ "Refill" ] .. " <", zclib.GetFont("zclib_font_giant"), 0, -150, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

local function CreateClientProp()
	local ent = ents.CreateClientProp()

	// Just to make sure we dont cause a crash
	if not IsValid(ent) then return end
	if not ent:IsValid() then return end
	if not ent.SetModel then return end

	// Lets cache the model now
	zclib.CacheModel("models/props_junk/gascan001a.mdl")

    ent:SetModel("models/props_junk/gascan001a.mdl")
	ent:SetNoDraw(true)
	ent:SetModelScale(0.75,0)
    ent:Spawn()
    ent:Activate()

	return ent
end
local RefillCan
net.Receive("zpm.Machine.Refill", function(len)
	//zclib.Debug_Net("zpm.Machine.Refill",len)

	local ply = net.ReadEntity()
	if not IsValid(ply) then return end

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	if LocalPlayer() ~= ply then return end

	ply:StopSound("zpm_machine_refill")
	ply:EmitSound("zpm_machine_refill")

	local RefillStart = CurTime()

	if IsValid(RefillCan) then RefillCan:Remove() end
	RefillCan = CreateClientProp()
	local timerid = "zpm.Machine.Refill"
	timer.Remove(timerid)
	timer.Create(timerid, 0.1, 0, function()
		local time = CurTime() - RefillStart
		if not Fuel:CanRefill(Machine, LocalPlayer()) or time >= 3 then
			if IsValid(RefillCan) then
				SafeRemoveEntity(RefillCan)
			end
			timer.Remove(timerid)
		end
	end)


	local w,h = 400,50
	local x,y = ScrW() / 2, ScrH() * 0.8

	local Refilled = false
	hook.Add("HUDPaint","zpm.Machine.Refill",function()

		if IsValid(RefillCan) then
			local fSwenk = 10 * math.sin(CurTime() * 5)
			local sSwenk = 5 * math.sin(CurTime() * 3)
			local PosJitter = 2 * math.sin(CurTime() * 3)

			RefillCan:SetPos(Machine:LocalToWorld(Vector(-160 + PosJitter,3.5,55 + PosJitter)))
			RefillCan:SetAngles(Machine:LocalToWorldAngles(Angle(0,90 - sSwenk,120 - fSwenk)))
			RefillCan:SetNoDraw(false)
		end

		draw.RoundedBox(0, x - (w / 2), y - (h / 2), w, h, zclib.colors[ "black_a200" ])

		local time = CurTime() - RefillStart
		local barW = (w / zpm.config.Machine.Fuel.Refill_Time) * time

		draw.RoundedBox(0, x - (w / 2), y - (h / 2), barW, h, zclib.colors[ "orange01" ])
		draw.SimpleText(zpm.language["Refill Cost"].." > " .. zclib.Money.Display(zpm.config.Machine.Fuel.Refill_Cost,true), zclib.GetFont("zclib_font_medium"), x, y, zclib.colors[ "black_a200" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		zclib.util.DrawOutlinedBox(x - (w / 2), y - (h / 2), w, h, 4, zclib.colors[ "black_a200" ])

		if time >= 2.99 and not Refilled then
			zclib.vgui.PlayEffect("Sell", x, y)
			Refilled = true
		end

		if not Fuel:CanRefill(Machine, LocalPlayer()) or time >= 3 then
			if IsValid(ply) then ply:StopSound("zpm_machine_refill") end
			hook.Remove("HUDPaint", "zpm.Machine.Refill")
		end
	end)
end)
zpm.Machine.Fuel = Fuel
