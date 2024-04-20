zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

zpm.Machine.BoneDefinition = {}
zpm.Machine.SequencedBoneDefinition = {}
local TagID = 0
local function AddBoneDef(bone_name,data)

	if data.anim and not data.AnimateOnRun then
		if not data.tag then data.tag = {} end
		data.tag.id = TagID
		TagID = TagID + 1
	end

	zpm.Machine.BoneDefinition[bone_name] = data

	data.bone_name = bone_name

	table.insert(zpm.Machine.SequencedBoneDefinition,data)
end

AddBoneDef("inserter_controll_main_jnt|inserter_lever01_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(165.08,73.22,29.8)},	anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_controll_main_jnt|inserter_lever02_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(162.24,73.22,29.8)},	anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_controll_main_jnt|inserter_lever03_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(159.38,73.22,29.8)},	anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever04_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(156.6,73.22,29.8)},	anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})

AddBoneDef("inserter_lever05_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(136.5,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever06_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(132.62,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever07_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(128.6,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})

AddBoneDef("inserter_btn01_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(122.16,70.7,34.8)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn02_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(118.83,70.7,34.8)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn03_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(115.6,70.7,34.8)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn04_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(112.25,70.7,34.8)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})

AddBoneDef("inserter_btn05_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(122.25,73.5,32.7)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn06_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(118.83,73.5,32.7)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn07_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(115.6,73.5,32.7)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn08_jnt",		{QTE = true, tag = {ang = Angle(0,180,40),	scale = 0.1, pos = Vector(112.25,73.5,32.7)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})

AddBoneDef("inserter_lever08_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(105.6,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever09_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(102.95,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever10_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(100.56,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever11_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(97.98,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("inserter_lever12_jnt",		{QTE = true, tag = {ang = Angle(0,180,55),	scale = 0.15,	pos = Vector(95.38,73.22,29.93)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})

AddBoneDef("inserter_steerwheel02_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.2, pos = Vector(100.49,77.1,21.3)},anim = { Steer = 0 }	})
AddBoneDef("inserter_steerwheel01_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.2, pos = Vector(66,77.4,20)},anim = { Steer = 0 }	})

AddBoneDef("inserter_insert_switch_jnt",{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.2, pos = Vector(56,59.7,30.5)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})

AddBoneDef("oven_switch01_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.15, pos = Vector(-40.28,78.6,49.6)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("oven_switch02_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.15, pos = Vector(-49.49,78.6,49.6)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})
AddBoneDef("oven_switch03_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.15, pos = Vector(-58.58,78.6,49.6)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 75, }	})

AddBoneDef("oven_wheel_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.2, pos = Vector(-96,88.83,28)},anim = { Steer = 0 , ang = Angle(0,1,0)}	})

AddBoneDef("gen_switch02_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.15, pos = Vector(-122.717278, 88.828651, 20.328316)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = -75, },	fallback = Vector(-122, 82, 29)})
AddBoneDef("gen_switch01_jnt",		{QTE = true, tag = {ang = Angle(0,180,90),	scale = 0.15, pos = Vector(-125.5, 88.828651, 20.328316)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = -75, },	fallback = Vector(-126, 81, 29)})

AddBoneDef("gen_btn01_jnt",		{QTE = true, tag = {ang = Angle(0,-90,90),	scale = 0.15, pos = Vector(-181.89,50.13,54.4)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("gen_btn02_jnt",		{QTE = true, tag = {ang = Angle(0,-90,90),	scale = 0.15, pos = Vector(-181.89,46.69,54.4)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("gen_btn03_jnt",		{QTE = true, tag = {ang = Angle(0,-90,90),	scale = 0.15, pos = Vector(-181.89,43.01,54.4)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("gen_btn04_jnt",		{QTE = true, tag = {ang = Angle(0,-90,90),	scale = 0.15, pos = Vector(-181.89,39.65,54.4)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})

AddBoneDef("gen_crank_jnt",		{QTE = true, tag = {ang = Angle(0,-90,90),	scale = 0.2, pos = Vector(-181.89,16.95,60.43)},anim = { State = false , switch_ang = Angle(0,1,0), switch_dist = 90, }	})

AddBoneDef("controll_btn01_jnt",	{QTE = true, tag = {ang = Angle(0,0,50),	scale = 0.1,	pos = Vector(14.25,-77,38)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("controll_btn02_jnt",	{QTE = true, tag = {ang = Angle(0,0,50),	scale = 0.1,	pos = Vector(17.6,-77,38)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("controll_btn03_jnt",	{QTE = true, tag = {ang = Angle(0,0,50),	scale = 0.1,	pos = Vector(20.91,-77,38)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("controll_btn04_jnt",	{QTE = true, tag = {ang = Angle(0,0,50),	scale = 0.1,	pos = Vector(24.24,-77,38)},anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})

AddBoneDef("steerwheel01_jnt",		{QTE = true, tag = {ang = Angle(0,0,90),	scale = 0.2,	pos = Vector(21,-76.55,28.7)},anim = { Steer = 0, ang = Angle(0,1,0) }	})

AddBoneDef("output_lever01_jnt",	{QTE = true, tag = {ang = Angle(0,0,70),	scale = 0.15,	pos = Vector(38.4,-73.8,31.3)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }, fallback = Vector(38.382133, -69.001541, 34.234062)	})
AddBoneDef("output_lever02_jnt",	{QTE = true, tag = {ang = Angle(0,0,70),	scale = 0.15,	pos = Vector(41.25,-73.8,31.3)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }, fallback = Vector(41.533859, -69.085609, 34.146614)	})
AddBoneDef("output_lever03_jnt",	{QTE = true, tag = {ang = Angle(0,0,70),	scale = 0.15,	pos = Vector(44.07,-73.8,31.3)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }, fallback = Vector(44.339363, -69.003693, 34.231808)	})
AddBoneDef("output_lever04_jnt",	{QTE = true, tag = {ang = Angle(0,0,70),	scale = 0.15,	pos = Vector(46.67,-73.8,31.3)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }, fallback = Vector(47.718735, -69.001625, 34.233967)	})

AddBoneDef("output_small_lever01_jnt",	{QTE = true, tag = {ang = Angle(0,0,45),	scale = 0.15,	pos = Vector(53.15,-67.27,36.4)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }	})
AddBoneDef("output_small_lever02_jnt",	{QTE = true, tag = {ang = Angle(0,0,45),	scale = 0.15,	pos = Vector(57.9,-67.27,36.4)},anim = { State = false , switch_ang = Angle(1,0,0), switch_dist = 55, }	})

AddBoneDef("heater_spin_jnt",		{QTE = true, tag = {scale = 0.4, pos = Vector(198.13,-25.88,20.32)},	anim = { Steer = 0 , ang = Angle(0,1,0)}	})

AddBoneDef("heater_lever01_jnt",		{QTE = true, tag = {scale = 0.15,	pos = Vector(198.13,-25.07,31)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -55, }	})
AddBoneDef("heater_lever02_jnt",		{QTE = true, tag = {scale = 0.15,	pos = Vector(198.13,-22.27,31)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -55, }	})
AddBoneDef("heater_lever03_jnt",		{QTE = true, tag = {scale = 0.15,	pos = Vector(198.13,-19.54,31)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -55, }	})
AddBoneDef("heater_lever04_jnt",		{QTE = true, tag = {scale = 0.15,	pos = Vector(198.13,-16.57,31)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -55, }	})

AddBoneDef("root|inserter_lever01_jnt",		{QTE = true, tag = {pos = Vector(178,18,40)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -75, }	})
AddBoneDef("root|inserter_lever02_jnt",		{QTE = true, tag = {pos = Vector(178,27.5,40)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -75, }	})
AddBoneDef("root|inserter_lever03_jnt",		{QTE = true, tag = {pos = Vector(178,36.5,40)},	anim = { State = false , switch_ang = Angle(0,0,1), switch_dist = -75, }	})

AddBoneDef("inserter_pipelever",	{QTE = true, tag = {ang = Angle(0,90,90),	scale = 0.3,	pos = Vector(180,27,24.84)},anim = { State = false , switch_ang = Angle(0,1,0), switch_dist = 75, },	fallback = Vector(180, 22, 24)})

AddBoneDef("inserter_btn011_jnt",		{QTE = true, tag = {ang = Angle(0,90,50),	scale = 0.15,	pos = Vector(180.42,45.41,32.77)},	anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn012_jnt",		{QTE = true, tag = {ang = Angle(0,90,50),	scale = 0.15,	pos = Vector(180.42,49,32.77)},		anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn013_jnt",		{QTE = true, tag = {ang = Angle(0,90,50),	scale = 0.15,	pos = Vector(180.42,52.18,32.77)},	anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})
AddBoneDef("inserter_btn014_jnt",		{QTE = true, tag = {ang = Angle(0,90,50),	scale = 0.15,	pos = Vector(180.42,55.28,32.77)},	anim = { State = false , push_dir = Vector(0,1,0), push_dist = 0.5, }	})

AddBoneDef("inserter_switch_jnt", {
	QTE = true,
	tag = {
		ang = Angle(0, 90, 50),
		scale = 0.2,
		pos = Vector(182.25, 60.72, 30.49)
	},
	anim = {
		State = false,
		push_dir = Vector(1, 0, 0),
		push_dist = 5,
		// Its retarted but i use that to mark this bone as a lever since the code would detect it as a button and i need it to sound like a lever instead (Levers usally have a switch_ang but this one has not)
		IsLever = true,
	}
})

////////////////////////

AddBoneDef("vent_rotor_jnt",         {AnimateOnRun = true})
AddBoneDef("wheels01_w01_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels01_w02_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels02_w01_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels02_w02_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels03_w01_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels03_w02_jnt",       {AnimateOnRun = true})
AddBoneDef("wheels04_w01_jnt",       {AnimateOnRun = true, Invert = true})
AddBoneDef("wheels04_w02_jnt",       {AnimateOnRun = true, Invert = true})
AddBoneDef("mixer_rotor01_jnt",      {AnimateOnRun = true})
AddBoneDef("insert_wheel01_jnt",     {AnimateOnRun = true})
AddBoneDef("insert_wheel02_jnt",     {AnimateOnRun = true})
AddBoneDef("oven_fan_jnt",           {AnimateOnRun = true, ang = Angle(0, 0, 1), Speed = 10})
AddBoneDef("vent_rotor_jnt",         {AnimateOnRun = true})

AddBoneDef("warnlight01_jnt",        {FuseBox = true})
AddBoneDef("warnlight02_jnt",        {FuseBox = true})
AddBoneDef("warnlight03_jnt",        {FuseBox = true})
AddBoneDef("warnlight04_jnt",        {FuseBox = true})
AddBoneDef("warnlight05_jnt",        {FuseBox = true})
AddBoneDef("warnlight06_jnt",        {FuseBox = true})

/*
AddBoneDef("exit_top_bt01_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, tag = {pos = Vector(178, 18, 40)}, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})
AddBoneDef("exit_top_bt02_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, tag = {pos = Vector(178, 18, 40)}, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})
AddBoneDef("exit_top_bt03_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, tag = {pos = Vector(178, 18, 40)}, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})
*/

AddBoneDef("exit_top_bt01_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})
AddBoneDef("exit_top_bt02_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})
AddBoneDef("exit_top_bt03_jnt", {canpress = function(machine) return machine:GetNeedsRepair() end, anim = {State = false, switch_ang = Angle(0, 0, 1), switch_dist = 75}})


local ColorInc = 360 / TagID
local ColorTag = 0
for k,v in pairs(zpm.Machine.BoneDefinition) do
	if not v or not v.anim then continue end
	if v.tag.pos then
		v.tag.color = HSVToColor(v.tag.pos.x,0.5,0.5)
	else
		v.tag.color = HSVToColor(ColorTag,0.5,0.5)
	end
	ColorTag = ColorTag + ColorInc
end

if not zpm.config.Machine.EasyMode then

	local templist = {}
	for k,v in pairs(zpm.Machine.BoneDefinition) do
		if not v.tag or not v.tag.id then continue end
		table.insert(templist,v.tag.id)
	end

	templist = zclib.table.randomize( templist )

	for k,v in pairs(zpm.Machine.BoneDefinition) do
		if not v.tag or not v.tag.id then continue end
		local val,key = table.Random(templist)

		v.tag.id = val

		table.remove(templist,key)
	end
end
