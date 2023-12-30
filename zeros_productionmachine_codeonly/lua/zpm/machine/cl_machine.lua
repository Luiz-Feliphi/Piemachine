zpm = zpm or {}
zpm.Machine = zpm.Machine or {}
zpm.Machine.List = zpm.Machine.List or {}

zclib.FontData["zpm_button_tag"] = {
	font = "Nexa Bold",
	extended = true,
	size = 10,
	weight = 0,
	antialias = false
}

zclib.Convar.Create("zpm_cl_effects", "1", {FCVAR_ARCHIVE})
zclib.Convar.Create("zpm_cl_dynlight", "1", {FCVAR_ARCHIVE})
zclib.Convar.Create("zpm_cl_animation", "1", {FCVAR_ARCHIVE})
zclib.Convar.Create("zpm_cl_vibration", "1", {FCVAR_ARCHIVE})
zclib.Convar.Create("zpm_cl_materials", "1", {FCVAR_ARCHIVE})


local col_light_orange = Color(255,50,0)
local col_light_blue = Color(50,50,255)
local col_light_red = Color(255,50,50)

local output_light_pos = Vector(74.549423, -65.595535, 56.405552)
local output_light_ang = Angle(0,180,90)
local insert_ang = Angle(0,180,0)
local insert_pos = Vector(131, 54.5, 36.5)
local product_ang = Angle(0,0,75)
local product_pos = Vector(49.4,-66.4,51.5)

local ang01 = Angle(0,90,90)
local tag_base01 = Color(185, 185, 185)
local tag_base02 = Color(90, 90, 90)
local tag_button01 = Color(127,39,39)
local tag_button02 = Color(39,127,39)

local tag_button_blend01 = Color(255,50,50)
local tag_button_blend02 = Color(50,255,50)

local screen02_pos = Vector(169.4,43,81.6)

local temp_effect_pos = Vector(-83, -58, 43)
local temp_effect_ang = Angle(0, 0, 90)

local light01_pos = Vector(190, 18, 79)
local light02_pos = Vector(188, -41, 52)
local light03_pos = Vector(-83, -58, 43)
local light04_pos = Vector(-91, 78, 49)



local function DrawTag(Machine,pos,txt,ang,scale,color,hover,bone_name)
	if zclib.util.InDistance(Machine:GetPos(), LocalPlayer():GetPos(), 500) == false then return end

	cam.Start3D2D(Machine:LocalToWorld(pos) , Machine:LocalToWorldAngles(ang or ang01), scale or 0.3)

		if Machine:GetIsRunning() then

			surface.SetMaterial(zpm.Materials["btn_base"])
			surface.SetDrawColor(tag_base01)
			surface.DrawTexturedRect(-8, -8, 16, 16)

			local IsQTE = bone_name and Machine.QTE_Buttons and Machine.QTE_Buttons[bone_name]

			local IsOnTime = IsQTE and isstring(bone_name) and Machine.QTE_Buttons[bone_name] and Machine:GetCycleProgress() >= Machine.QTE_Buttons[bone_name]

			surface.SetDrawColor(IsOnTime and tag_button02 or tag_button01)
			surface.SetMaterial(zpm.Materials["btn_hover"])
			surface.DrawTexturedRect(-8, -8, 16, 16)

			draw.SimpleText(txt, zclib.GetFont("zpm_button_tag"), 0, 0, hover and color_white or zclib.colors["white_a100"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if hover then
				zclib.Blendmodes.Blend("Additive",false,function()
					surface.SetDrawColor(IsOnTime and tag_button_blend02 or tag_button_blend01)
					surface.SetMaterial(zpm.Materials["btn_hover"])
					surface.DrawTexturedRect(-8, -8, 16, 16)
				end)

				zclib.util.DrawOutlinedBox(-8, -8, 16, 16, 2, color_white)
			end

			// If its a QTE and it needs to be pressed then make flash
			if IsQTE and isstring(bone_name) and Machine.QTE_Buttons[bone_name] and Machine:GetCycleProgress() >= Machine.QTE_Buttons[bone_name] then
				local pulse = math.abs(math.sin(CurTime() * 5))
				local size = 40 * pulse
				surface.SetMaterial(zclib.Materials.Get("glow01"))
				surface.SetDrawColor(color_green)
				surface.DrawTexturedRect(-size / 2, -size / 2, size, size, 0)
			end
		else

			surface.SetMaterial(zpm.Materials["btn_base"])
			surface.SetDrawColor(tag_base02)
			surface.DrawTexturedRect(-8, -8, 16, 16)

			surface.SetDrawColor(Color(55,0,0))
			surface.SetMaterial(zpm.Materials["btn_hover"])
			surface.DrawTexturedRect(-8, -8, 16, 16)

			draw.SimpleText(txt, zclib.GetFont("zpm_button_tag"), 0, 0,  zclib.colors["white_a15"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

local function DrawQTE(x,y,w,h,barW,barY,time,btnid,font)

	local pos = (barW / zpm.config.Machine.CycleLength) * time

	local bWidth = (barW / zpm.config.Machine.CycleLength) * zpm.config.Machine.QTE.Time

	local size = h * 0.4

	local point_X = x + pos - (size/2) + (bWidth / 2) + (w * 0.02)
	local point_Y = y + (h / 2) - (size/3)

	surface.SetMaterial(zpm.Materials["btn_base"])
	surface.SetDrawColor(tag_base01)
	surface.DrawTexturedRect(point_X,point_Y , size, size)

	surface.SetMaterial(zpm.Materials["btn_hover"])
	surface.SetDrawColor(tag_button02)
	surface.DrawTexturedRect(point_X,point_Y, size, size)

	draw.SimpleText(btnid, font, x + pos + (bWidth / 2) + (w * 0.02), y + (h / 1.8), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.RoundedBox(0, x + pos - 1 + (w * 0.02),barY,bWidth, h * 0.2, zclib.colors[ "green01" ])
end

local function DrawBar(Machine,x,y,w,h,title,val,max,font)
	draw.RoundedBox(5, x,y, w, h, zclib.colors[ "ui02" ])

	draw.SimpleText(title, font,x + 10,y, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)



	if Machine:GetMissingIngredients() then
		draw.SimpleText("[Missing Ingredients]", font,0,y + 70, zclib.colors[ "red01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local barW,barH = w * 0.94,h * 0.2
	local barX, barY = x + (w * 0.02), y + h - barH - 5

	local bar = (barW / max) * val
	draw.RoundedBox(5, barX, barY, barW, barH, zclib.colors[ "black_a100" ])

	if Machine.QTE and table.Count(Machine.QTE) > 0 then

		for k, v in pairs(Machine.QTE) do
			if not v.btnid and v.btn and zpm.Machine.BoneDefinition[v.btn] then
				v.btnid = zpm.Machine.BoneDefinition[v.btn].tag.id
				continue
			end

			if not v.btnid then continue end

			DrawQTE(x,y,w,h,barW,barY,v.time,v.btnid,font)
		end
	end

	draw.RoundedBox(5, x + bar + (w * 0.02), barY, 2, h * 0.2, color_black)
end

local function RandomJiggle(Machine,boneID,intensity,Fade)
    local amount = 0.1 * intensity * Fade
    local vibrate = math.Rand(-amount, amount)
    Machine:ManipulateBonePosition(boneID, Vector(vibrate, vibrate, vibrate))
end

local function VibrationSystem(Machine,enabled,intensity,bone_name)
    if zclib.util.InDistance(Machine:GetPos(), LocalPlayer():GetPos(), 2000) == false then return end

    // Here we calculate the fade in multiplier
    local Fade = 1
    if Machine.LastState ~= enabled then
        Machine.LastState = enabled
        Machine.VibrationChange = CurTime()
    end
    Fade = math.Clamp((1 / 3) * (CurTime() - Machine.VibrationChange), 0, 1)

	local boneID = Machine:LookupBone(bone_name)

    if enabled then
        RandomJiggle(Machine,boneID,intensity,Fade)
    else
        if Fade >= 1 then
            Machine:ManipulateBonePosition(boneID, vector_origin)
        else
            RandomJiggle(Machine,boneID,intensity,1-Fade)
        end
    end
end

local function DrawLight(Machine,id,pos,color)

	local dlight = DynamicLight(id)
	if dlight then
		//debugoverlay.Sphere(pos,5,0.1,Color( 0, 255, 255 ,10 ),false)
		dlight.Pos = pos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.Brightness = 2
		dlight.Size = 256
		dlight.Decay = 1000
		dlight.Style = 1
		dlight.DieTime = CurTime() + 1
	end
end

local function DrawInterface(Machine,w,h)

	local fieldW = w * 0.95
	local font = zclib.GetFont("zclib_font_big")

	// Display the current cycle progress, (Each cycle will spawn new QTE which the player has to deal with in order to improve the Machines productivty)
	DrawBar(Machine,-fieldW/2, -h * 0.1, fieldW, h * 0.55, zpm.language["Cycle"], Machine:GetCycleProgress(),zpm.config.Machine.CycleLength,font)

	draw.RoundedBox(5,-fieldW/2, -h * 0.45, fieldW, h * 0.3, zclib.colors[ "ui02" ])

	local ProductData = zpm.config.Items[Machine:GetItemID()]
	if ProductData then
		local prog = Machine:GetProductProgress()
		local barW = w * 0.91
		local bar = (barW / ProductData.machine.time) * prog

		draw.SimpleText(ProductData.name .. ":", font,-w / 2.2,-h / 2.7, zclib.colors[ "text01" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local am = (1 / 100) * Machine:GetProductivity()
		local text = am < 1 and "-" .. math.Round(am,1) or "+" .. math.Round(am,1)
		draw.SimpleText(text, font,w / 2.2,-h / 2.7, am < 1 and zclib.colors[ "red01" ] or zclib.colors[ "green01" ], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		draw.RoundedBox(5, -barW/2,-h * 0.28, barW, h * 0.1, zclib.colors[ "black_a100" ])
		draw.RoundedBox(5, -barW/2,-h * 0.28, bar, h * 0.1, zclib.colors[ "green01" ])
	else
		draw.SimpleText("No Product Selected", zclib.GetFont("zclib_font_big"),0,-h * 0.3, zclib.colors[ "text01" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function DrawScreen(Machine,pos,ang,w,h)
	cam.Start3D2D(Machine:LocalToWorld(pos) , Machine:LocalToWorldAngles(ang), 0.05)

		draw.RoundedBox(0, -w / 2, -h / 2, w, h, zclib.colors[ "black_a200" ])

		DrawInterface(Machine,w,h)

		if zpm.Machine.OnInterface(Machine, LocalPlayer(),pos) then
			draw.RoundedBox(5, -w / 2, -h / 2, w, h, zclib.colors[ "white_a15" ])
			surface.SetMaterial(zclib.Materials.Get("edit"))
			surface.SetDrawColor(zclib.colors[ "white_a15" ])
			surface.DrawTexturedRectRotated(0,0, h * 0.6, h * 0.6, CurTime() * 15)
		end
	cam.End3D2D()
end

local LadderPos = Vector(-93,-88,57)
local LadderAng = Angle(0,90,90)
local function DrawLadderButton(Machine, w, h)
	cam.Start3D2D(Machine:LocalToWorld(LadderPos), Machine:LocalToWorldAngles(LadderAng), 0.1)
	surface.SetMaterial(zclib.Materials.Get("back"))
	surface.SetDrawColor(zpm.Machine.OnLadderButton(Machine, LocalPlayer()) and color_white or zclib.colors[ "white_a15" ])
	surface.DrawTexturedRectRotated(0, 0, h * 0.6, h * 0.6, -90)
	cam.End3D2D()
end


function zpm.Machine.Initialize(Machine)

	// Here we setup everything requiered for bone animation
	zpm.Machine.Bone:Setup(Machine)

	zpm.Machine.QTE:Setup(Machine)

	zpm.Machine.Fuse:Setup(Machine)

	timer.Simple(1,function()
		if not IsValid(Machine) then return end
		Machine.m_Initialized = true
	end)
end


function zpm.Machine.OnDraw(Machine)
	if zclib.util.InDistance(Machine:GetPos(), LocalPlayer():GetPos(), 1500) == false then return end

	if not IsValid(Machine) or not util.IsValidModel(Machine:GetModel()) then return end

	/*
	for k,v in pairs(zpm.ItemMove.Paths) do
		debugoverlay.Sphere(Machine:LocalToWorld(v.StartPos),2,0.1,Color( 0, 255, 0 ,5),true)
		debugoverlay.Sphere(Machine:LocalToWorld(v.EndPos),2,0.1,Color( 0, 255, 0,5 ),true)
	end
	*/

	/*
		Draw the ladder button
	*/
	DrawLadderButton(Machine,420,350)

	/*
		Draws the coolant info
	*/
	zpm.Machine.Temperatur:Draw(Machine)

	/*
		Draw the fuel
	*/
	zpm.Machine.Fuel:Draw(Machine)

	/*
		Draw waste info
	*/
	zpm.Machine.Waste:Draw(Machine)

	/*
		Draw repair event
	*/
	zpm.Machine.Repair:Draw(Machine)

	/*
		Draw the info
	*/
	DrawScreen(Machine,screen02_pos,output_light_ang,420,350)
	DrawScreen(Machine,product_pos,product_ang,380,230)

	/*
		Draw the ingredient insert info
	*/
	if Machine:GetIsRunning() then
		cam.Start3D2D(Machine:LocalToWorld(insert_pos) , Machine:LocalToWorldAngles(insert_ang), 0.05)
			draw.RoundedBox(0, -600, -185, 1200, 350, zclib.colors["black_a200"])
			zclib.util.DrawOutlinedBox(-600, -185, 1200, 350, 20, zclib.colors["green01"])
			draw.SimpleText("> Insert Ingredients here <", zclib.GetFont("zclib_world_font_giant"),0,0, zclib.colors["green01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end

	/*
		Draw button tags
	*/
	local tPos = LocalPlayer():GetEyeTrace().HitPos
	local nearest = zpm.Machine.Button:GetNearest(Machine,tPos)
	for _,v in pairs(zpm.Machine.SequencedBoneDefinition) do
		if not v or not v.tag then continue end
		if not v.tag.pos then continue end
		local bone_name = v.bone_name
		DrawTag(Machine,v.tag.pos,v.tag.id,v.tag.ang,v.tag.scale,v.tag.color,nearest and nearest == bone_name,bone_name)
	end

	/*
		Draw the cursor
	*/
	if nearest or zclib.Entity.GetLookTarget() == Machine then
		cam.Start2D()
			draw.SimpleText("+", zclib.GetFont("zclib_font_medium"), ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End2D()
	end

	/*
		Draws all the warn lights
	*/
	zpm.Machine.Fuse:DrawWarnlights(Machine)

	/*
		Draw output light
	*/
	if Machine:GetIsRunning() then
		cam.Start3D2D(Machine:LocalToWorld(output_light_pos) , Machine:LocalToWorldAngles(output_light_ang), 1)
			surface.SetMaterial(zclib.Materials.Get("glow01"))
			surface.SetDrawColor(color_green)
			surface.DrawTexturedRect(-5,-5,10,10,0)
		cam.End3D2D()
	end

	/*
		Draw vibration
	*/
	if zclib.Convar.GetBool("zpm_cl_vibration") then VibrationSystem(Machine,Machine:GetIsRunning(),1.5,"generator_pipe_jnt") end

	/*
		Create exaust effect
	*/
	if zclib.Convar.GetBool("zpm_cl_effects") and Machine:GetIsRunning() and (not Machine.NextExaust or CurTime() > Machine.NextExaust) then

		zclib.Effect.ParticleEffect("zafa_exaust",Machine:GetBonePosition(Machine:LookupBone("generator_pipe_jnt")), angle_zero, Machine)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 1)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 2)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 3)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 4)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 5)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 6)
		zclib.Effect.ParticleEffectAttach("zafa_exaust01", PATTACH_POINT_FOLLOW, Machine, 8)

		if zpm.config.Machine.Temperatur.enabled and Machine:GetTemperatur() > 75 then
			zclib.Effect.ParticleEffect("zafa_exaust01", Machine:LocalToWorld(temp_effect_pos), Machine:LocalToWorldAngles(temp_effect_ang), Machine)
		end

		Machine.NextExaust = CurTime() + 3
	end

	/*
		Draw DynamicLight
	*/
	if zclib.Convar.GetBool("zpm_cl_dynlight") and Machine:GetIsRunning() then

		//DrawLight(Machine,0,Machine:LocalToWorld(light01_pos),col_light_orange)

		//DrawLight(Machine,1,Machine:LocalToWorld(light02_pos),col_light_orange)

		if zpm.config.Machine.Temperatur.enabled then
			DrawLight(Machine, 2, Machine:LocalToWorld(light03_pos), Machine:GetTemperatur() > 75 and col_light_red or col_light_blue)
		end

		//DrawLight(Machine,3,Machine:LocalToWorld(light04_pos),col_light_orange)
	end
end

function zpm.Machine.OnThink(Machine)
	zclib.util.LoopedSound(Machine, "zpm_machine_loop", Machine:GetIsRunning(), 3000)

	zclib.util.LoopedSound(Machine, "zpm_machine_fuse_loop", Machine.FixingFuse == true, 3000)

	//zclib.util.LoopedSound(Machine, "zpm_machine_rail_loop", Machine.RailInsertion and Machine.RailInsertion > CurTime(), 3000)

	zclib.util.LoopedSound(Machine, "zpm_machine_arms_loop",Machine:GetIsRunning(), 3000)

	//zclib.util.LoopedSound(Machine, "zpm_machine_music01",Machine:GetIsRunning(), 3000)

	zpm.Machine.Animate(Machine)

	zpm.Machine.List[Machine] = true

	if zpm.Machine.UpdateMaterials and zpm.Machine.UpdateMaterials[ Machine ] == nil then
		zpm.Machine.UpdateMaterials[ Machine ] = true
	end
end

function zpm.Machine.OnRemove(Machine)
	Machine:StopSound("zpm_machine_loop")
	Machine:StopSound("zpm_machine_fuse_loop")
	Machine:StopSound("zpm_machine_rail_loop")
	Machine:StopSound("zpm_machine_arms_loop")
	Machine:StopSound("zpm_machine_music01")
end

function zpm.Machine.Animate(Machine)
	if not zclib.Convar.GetBool("zpm_cl_animation") then
		Machine:SetSequence(Machine:LookupSequence("idle"))
		return
	end

	Machine:SetSequence(Machine:LookupSequence("run"))
	local add = Machine:GetIsRunning() and (0.5 * FrameTime()) or 0
	Machine.Cycle = (Machine.Cycle or 0) + add
	Machine:SetCycle(Machine.Cycle)
end

function zpm.Machine.PlaySoundAtBone(Machine,BoneName,SoundPath)
	local pos = zpm.Machine.Bone:GetPos(Machine, Machine:LookupBone(BoneName))
	//debugoverlay.Sphere(pos,1,0.1,Color( 0, 255, 0 ),true)
	//EmitSound(SoundPath,pos, 0, CHAN_AUTO, 1, 75)
	sound.Play(SoundPath, pos, 65, 100,1)
end
