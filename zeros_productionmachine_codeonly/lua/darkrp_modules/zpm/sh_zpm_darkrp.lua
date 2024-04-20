TEAM_ZMP_PIEMAKER = DarkRP.createJob("Pie Maker", {
	color = Color(0, 128, 255, 255),
	model = {"models/player/kleiner.mdl"},
	description = [[You make pies]],
	weapons = {},
	command = "zpm_piemaker",
	max = 4,
	salary = 0,
	admin = 0,
	vote = false,
	category = "Citizens",
	hasLicense = false
})

DarkRP.createCategory{
	name = "PieMaker",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 125, 255, 255),
	canSee = function(ply) return true end,
	sortOrder = 103
}

DarkRP.createEntity("BuildKit", {
	ent = "zpm_buildkit",
	model = "models/zerochain/props_animalfarm/zafa_buildkit.mdl",
	price = 1000,
	max = 1,
	cmd = "buyzpm_buildkit",
	allowTools = true,
	allowed = TEAM_ZMP_PIEMAKER,
	category = "PieMaker"
})

DarkRP.createEntity("Palette", {
	ent = "zpm_palette",
	model = "models/props_junk/wood_pallet001a.mdl",
	price = 1000,
	max = 1,
	cmd = "buyzpm_palette",
	allowTools = true,
	allowed = TEAM_ZMP_PIEMAKER,
	category = "PieMaker"
})

timer.Simple(1,function()
	for k, v in ipairs(zpm.config.Items) do
		if v.machine then continue end

		DarkRP.createEntity(v.name, {
			ent = "zpm_item_" .. string.lower(string.Replace(v.name, " ", "_")),
			model = v.ent.mdl,
			price = v.ent.price or 1000,
			max = 3,
			cmd = "buy_"..v.uniqueid,
			allowTools = true,
			allowed = TEAM_ZMP_PIEMAKER,
			category = "PieMaker",
			spawn = function(ply, tr, tblEnt) return zpm.Item.Spawn(k, v.ent.amount, tr.HitPos, ply) end
		})
	end
end)
