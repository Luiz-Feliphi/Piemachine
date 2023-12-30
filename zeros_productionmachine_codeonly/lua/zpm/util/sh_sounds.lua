sound.Add({
	name = "zpm_machine_loop",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "ambient/levels/labs/machine_moving_loop4.wav" }
})

sound.Add({
	name = "zpm_machine_music01",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/music.wav"}
})


sound.Add({
	name = "zpm_machine_shutdown",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/machine_shutdown.wav" }
})
sound.Add({
	name = "zpm_machine_wrongbutton",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "common/wpn_select.wav" }
})

sound.Add({
	name = "zpm_machine_rightbutton",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/success.wav" }
})

sound.Add({
	name = "zpm_machine_action_completed",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/action_complete01.wav","zpm/action_complete02.wav"}
})

sound.Add({
	name = "zpm_machine_action_failed",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/action_fail01.wav"}
})

zclib.Sound.List["buildkit_construction_complete"] = {
	paths = {"zpm/construction_complete.wav"},
	lvl = 75,
	pitchMin = 100,
	pitchMax = 100
}

sound.Add( {
	name = "zpm_buildkit_construction_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "zpm/construction_loop.wav"
} )

sound.Add( {
	name = "zpm_machine_refill",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 35,
	pitch = {100, 100},
	sound = "zpm/fuel_refill.wav"
} )

sound.Add({
	name = "zpm_machine_fuse_loop",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/fuse_loop.wav" }
})

sound.Add({
	name = "zpm_machine_fuse_done",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/fuse_done.wav" }
})


sound.Add({
	name = "zpm_machine_rail_loop",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/rail_loop.wav" }
})

sound.Add({
	name = "zpm_machine_arms_loop",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = { 100, 100 },
	sound = { "zpm/arms_loop.wav" }
})

zclib.Sound.List[ "zpm_trashfall" ] = {
	paths = {
		"zpm/trashfall.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_trash_break" ] = {
	paths = {
		"zpm/trash_clear01.wav",
		"zpm/trash_clear02.wav",
		"zpm/trash_clear03.wav",
		"zpm/trash_clear04.wav",
		"zpm/trash_clear05.wav",
		"zpm/trash_clear06.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}


zclib.Sound.List[ "zpm_machine_rail_clamp_open" ] = {
	paths = { "physics/body/body_medium_impact_soft1.wav","physics/body/body_medium_impact_soft2.wav","physics/body/body_medium_impact_soft3.wav","physics/body/body_medium_impact_soft4.wav","physics/body/body_medium_impact_soft5.wav"},
	lvl = 35,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_machine_item_drop_metal" ] = {
	paths = { "physics/metal/metal_barrel_impact_soft1.wav","physics/metal/metal_barrel_impact_soft2.wav","physics/metal/metal_barrel_impact_soft3.wav" },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_temperatur_match" ] = {
	paths = {
		"zpm/air_release01.wav",
		"zpm/air_release02.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_temperatur_change" ] = {
	paths = {
		"buttons/blip1.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}




zclib.Sound.List[ "zpm_machine_item_drop_flesh" ] = {
	paths = { "physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav", },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_machine_item_drop_powder" ] = {
	paths = { "zpm/impact_powder01.wav","zpm/impact_powder02.wav" },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_machine_item_drop_liquid" ] = {
	paths = { "ambient/water/water_splash1.wav","ambient/water/water_splash2.wav","ambient/water/water_splash3.wav" },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_machine_item_drop_egg" ] = {
	paths = { "zpm/impact_egg01.wav","zpm/impact_egg02.wav","zpm/impact_egg03.wav" },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List[ "zpm_machine_item_drop_sand" ] = {
	paths = { "physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav" },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}


zclib.Sound.List[ "zpm_machine_item_drop_butter" ] = {
	paths = { "player/footsteps/mud1.wav","player/footsteps/mud2.wav","player/footsteps/mud3.wav","player/footsteps/mud4.wav", },
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}
