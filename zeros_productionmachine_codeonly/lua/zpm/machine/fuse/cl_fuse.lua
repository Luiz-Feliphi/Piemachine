zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

/*

	Sometimes a fuse will burnout in one of the fuseboxes
	Each fusebox has a bunch of fuses, if all fuses in one of the fuseboxes are burned out then the machine will shutdown
	The player needs to hold E in order to replace one of the fuses
	The Productivity of the machine will increase the burnout rate of the fuses

*/

local Fuse = zpm.Machine.Fuse or {}


net.Receive("zpm.Machine.Fuse.Update", function(len)
	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	local bone_name = net.ReadString()
	if bone_name and bone_name ~= "nil" and zclib.Convar.GetBool("zpm_cl_effects") then

		local WarnPos = Machine:GetBonePosition(Machine:LookupBone(bone_name))

		if zclib.Convar.GetBool("zpm_cl_effects") then
			local effectdata = EffectData()
			effectdata:SetStart(WarnPos)
			effectdata:SetOrigin(WarnPos)
			effectdata:SetScale(0.1)
			effectdata:SetMagnitude(1)
			effectdata:SetRadius(1)
			util.Effect("ManhackSparks", effectdata, true, true)

			zclib.Effect.ParticleEffect("zpm_electro",WarnPos, angle_zero, Machine)
		end
		zpm.Machine.PlaySoundAtBone(Machine,bone_name,"ambient/energy/zap" .. math.random(9) .. ".wav")
	end

	Machine.FuseBox = {}

	local length = net.ReadUInt(10)

	for i = 1,length do
		local bone = net.ReadString()
		local val = net.ReadUInt(10)

		Machine.FuseBox[bone] = val
	end
end)

local color_warn_blue = Color(36,113,255)

local function DrawWarnLight(Machine,bone_id,bone_name)

	if not zpm.config.Machine.FuseBox.enabled then return end


	local FuseHealth = Machine.FuseBox[bone_name] or zpm.config.Machine.FuseBox.Health

	local NeedsReplacement = FuseHealth < zpm.config.Machine.FuseBox.Health

	local WarnPos,WarnAng = Machine:GetBonePosition(bone_id)
	local sizepulse = NeedsReplacement and math.Clamp(math.sin(CurTime() * 5),0.5,1) or 0.5
	cam.Start3D2D(WarnPos,WarnAng, 1.5 * sizepulse)
		surface.SetMaterial(zclib.Materials.Get("glow01"))
		surface.SetDrawColor(NeedsReplacement and color_red or color_warn_blue)
		surface.DrawTexturedRect(-4,-4, 8, 8,0)
	cam.End3D2D()

	if zclib.util.InDistance(Machine:GetPos(), LocalPlayer():GetPos(), 300) and zclib.util.InDistance(LocalPlayer():GetEyeTrace().HitPos, WarnPos, 5) then
		local ScreenPos = WarnPos:ToScreen()
		local HOffset = 135
		local x,y = ScreenPos.x, ScreenPos.y - HOffset
		cam.Start2D()

			local bW,bH = 200 , NeedsReplacement and 190 or 145

			draw.RoundedBox(8, x + 5, y + HOffset, 10, 10, zclib.colors[ "black_a200" ])
			draw.RoundedBox(8, x + 20, y + HOffset, 10, 10, zclib.colors[ "black_a200" ])
			draw.RoundedBox(8, x + 35, y + HOffset, 10, 10, zclib.colors[ "black_a200" ])

			draw.RoundedBox(0, x + 50, y, bW, bH, zclib.colors[ "black_a200" ])

			draw.SimpleText(zpm.language["FuseBox"], zclib.GetFont("zclib_font_big"), x + 150, y + 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.RoundedBox(0, x + 54, y + 44, bW - 8, 2, color_white)

			zclib.util.DrawOutlinedBox( x + 50, y, bW, bH,4, zclib.colors[ "black_a200" ])

			if NeedsReplacement then
				draw.RoundedBox(0, x + 60,y + 145 , 180, 35, zclib.colors[ "red01" ])
				draw.SimpleText(zpm.language["Replace > E"], zclib.GetFont("zclib_font_medium"), x + 150,y + 150, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				zclib.util.DrawOutlinedBox(  x + 60,y + 145 , 180, 35,4, zclib.colors[ "black_a200" ])
			end

			local marginLeft = 10
			// {{ user_id | 76561197999833630 }}
			local fW, fH = (bW - marginLeft) / zpm.config.Machine.FuseBox.Health, 80
			for i = 1, zpm.config.Machine.FuseBox.Health do
				local xpos = (x + 50) + ((i - 1) * fW) + marginLeft
				draw.RoundedBox(8, xpos + (marginLeft * 0.2), y + 55, fW - (marginLeft * 1.4), fH, i <= FuseHealth and color_warn_blue or zclib.colors[ "red01" ])
				draw.RoundedBox(4, xpos, y + 55, fW - marginLeft, fH * 0.2, zclib.colors[ "ui02" ])
				draw.RoundedBox(4, xpos, y + 120, fW - marginLeft, fH * 0.2, zclib.colors[ "ui02" ])
			end
		cam.End2D()
	end
end

function Fuse:DrawWarnlights(Machine)

	if not Machine:GetIsRunning() then return end
	for bone_name,v in pairs(Machine.FuseBox) do
		local bone_id = Machine:LookupBone(bone_name)
		DrawWarnLight(Machine, bone_id,bone_name)
	end
end

net.Receive("zpm.Machine.Fuse.Interact", function(len)
	//zclib.Debug_Net("zpm.Machine.Fuse.Interact",len)
	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	local bone_name = net.ReadString()
	if not bone_name then return end

	local FixStart = CurTime()
	local w,h = 400,50
	local x,y = ScrW() / 2, ScrH() * 0.8

	Machine:StopSound("zpm_machine_fuse_loop")
	Machine.FixingFuse = true

	hook.Remove("HUDPaint","zpm.Machine.Fuse.Interact")
	hook.Add("HUDPaint","zpm.Machine.Fuse.Interact",function()
		draw.RoundedBox(0, x - (w / 2), y - (h / 2), w, h, zclib.colors[ "black_a200" ])

		local time = CurTime() - FixStart
		local barW = (w / zpm.config.Machine.FuseBox.Time) * time

		draw.RoundedBox(0, x - (w / 2), y - (h / 2), barW, h, zclib.colors[ "green01" ])
		draw.SimpleText(zpm.language["Replacing Fuse..."], zclib.GetFont("zclib_font_medium"), x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		zclib.util.DrawOutlinedBox(x - (w / 2), y - (h / 2), w, h,4, zclib.colors[ "black_a200" ])

		if not zpm.Machine.Fuse:CanFix(Machine, LocalPlayer(),bone_name) then

			Machine.FixingFuse = false
			Machine:StopSound("zpm_machine_fuse_loop")
			hook.Remove("HUDPaint", "zpm.Machine.Fuse.Interact")
		else
			if time >= zpm.config.Machine.FuseBox.Time then

				local WarnPos = Machine:GetBonePosition(Machine:LookupBone(bone_name))
				if WarnPos then
					local effectdata = EffectData()
					effectdata:SetStart(WarnPos)
					effectdata:SetOrigin(WarnPos)
					effectdata:SetScale(0.1)
					effectdata:SetMagnitude(1)
					effectdata:SetRadius(1)
					util.Effect("ManhackSparks", effectdata, true, true)
				end

				Machine.FixingFuse = false
				Machine:StopSound("zpm_machine_fuse_loop")
				Machine:EmitSound("zpm_machine_fuse_done")
				hook.Remove("HUDPaint", "zpm.Machine.Fuse.Interact")
			end
		end
	end)
end)

zpm.Machine.Fuse = Fuse
