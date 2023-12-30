zpm = zpm or {}
zpm.config = zpm.config or {}

zpm.config.Items = {}
local function AddItem(data)
	data.uniqueid = string.Replace(string.lower(data.name)," ","_")
	return table.insert(zpm.config.Items,data)
end

/*

	Ingredients

*/
ZPM_ITEM_EGG = AddItem({
	name = "Egg",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_egg.mdl",
		mover_sound = "zpm_machine_item_drop_egg",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_eggcart.mdl",
		amount = 20,
		price = 200,
	},
})

ZPM_ITEM_CHICKEN = AddItem({
	name = "Chicken",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_chicken_raw.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(90,90,0),
		mover_offset_scale = 1.5,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_chicken_raw.mdl",
		amount = 20,
		price = 200,
	},
})

ZPM_ITEM_BUTTER = AddItem({
	name = "Butter",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_butter.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(0,0,0),
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_butter_box.mdl",
		amount = 20,
		price = 800,
	},
})

ZPM_ITEM_MILK = AddItem({
	name = "Milk",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_powder.mdl",
		mat = "zerochain/zpm/zpm_milk",
		mover_sound = "zpm_machine_item_drop_liquid",
		mover_effect = "liquid",

		// Should the item have a random rotation when moving on the rail / belt
		mover_init_rot_rnd = true,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_milk.mdl",
		amount = 20,
		price = 400,
	},
})

ZPM_ITEM_APPLE = AddItem({
	name = "Apple",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_apple.mdl",
		mover_sound = "zpm_machine_item_drop_flesh",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_apple_box.mdl",
		amount = 20,
		price = 200,
	},
})

ZPM_ITEM_FLOUR = AddItem({
	name = "Flour",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_powder.mdl",
		color = Color(239,211,150),
		mover_effect = "powder",
		mover_sound = "zpm_machine_item_drop_powder",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_bag_flour.mdl",
		amount = 20,
		price = 300,
	},
})

ZPM_ITEM_SPICE = AddItem({
	name = "Spice",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_powder.mdl",
		color = Color(165,87,66),
		mover_effect = "powder",
		mover_sound = "zpm_machine_item_drop_powder",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_bag_spice.mdl",
		amount = 20,
		price = 300,
	},
})

ZPM_ITEM_SUGAR = AddItem({
	name = "Sugar",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_powder.mdl",
		color = Color(231,168,231),
		mover_effect = "powder",
		mover_sound = "zpm_machine_item_drop_sand",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_bag_sugar.mdl",
		amount = 20,
		price = 300,
	},
})

ZPM_ITEM_BLUEBERRIES = AddItem({
	name = "BlueBerries",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_blueberries_piece.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(0,90,0),
		mover_offset_scale = 1.5,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_blueberries.mdl",
		amount = 20,
		price = 200,
	},
})

ZPM_ITEM_CHERRYS = AddItem({
	name = "Cherries",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_cherry_piece.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(0,90,0),
		mover_offset_scale = 1.5,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_cherries.mdl",
		amount = 20,
		price = 200,
	},
})

ZPM_ITEM_CHEESE = AddItem({
	name = "Cheese",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_cheese_piece.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(90,90,0),
		mover_offset_scale = 1.5,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_cheese_wheel.mdl",
		amount = 6,
		price = 200,
	},
})

ZPM_ITEM_PUMPKIN = AddItem({
	name = "Pumpkin",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pumpkin.mdl",
		mover_sound = "zpm_machine_item_drop_butter",
		mover_offset_rot = Angle(0,90,0),
		mover_offset_scale = 1.5,
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pumpkin.mdl",
		amount = 20,
		price = 200,
	},
})




/*

	Products

*/
ZPM_ITEM_APPLEPIE = AddItem({
	name = "Apple Pie",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 0,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_APPLE] = 3,
		},
		time = 30,
	}
})

ZPM_ITEM_BLUEBERRIEPIE = AddItem({
	name = "BlueBerries Pie",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 1,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_BLUEBERRIES] = 3,
		},
		time = 30,
	}
})

ZPM_ITEM_CHEESECAKE = AddItem({
	name = "Cheese Cake",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 2,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_CHEESE] = 2,
		},
		time = 30,
	}
})

ZPM_ITEM_CHERRYPIE = AddItem({
	name = "Cherry Pie",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 3,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_CHERRYS] = 5,
		},
		time = 30,
	}
})

ZPM_ITEM_CHICKENPIE = AddItem({
	name = "Chicken Pie",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 4,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_CHICKEN] = 3,
		},
		time = 30,
	}
})

ZPM_ITEM_PUMPKINPIE = AddItem({
	name = "Pumpkin Pie",

	visual = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
	},

	ent = {
		mdl = "models/zerochain/props_animalfarm/zafa_pie.mdl",
		skin = 5,
		amount = 1,
	},

	money = 1000,

	jobs = {
		[TEAM_ZMP_PIEMAKER] = true,
	},

	machine = {
		ingredients = {
			[ZPM_ITEM_MILK] = 1,
			[ZPM_ITEM_SUGAR] = 1,
			[ZPM_ITEM_BUTTER] = 1,
			[ZPM_ITEM_EGG] = 2,
			[ZPM_ITEM_FLOUR] = 3,
			[ZPM_ITEM_PUMPKIN] = 5,
		},
		time = 30,
	}
})
