
hook.Add("AddToolMenuCategories", "zpm_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zpm_options", "Production Machine")
end)

hook.Add("PopulateToolMenu", "zpm_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zpm_options", "zpm_Client_Settings", "Client Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("VFX", nil, Color(180, 145, 103, 255), Color(100, 89, 63, 255), CPanel, {
			[1] = {
				name = "Particle Effects",
				class = "DCheckBoxLabel",
				cmd = "zpm_cl_effects"
			},
			[2] = {
				name = "DynamicLight",
				class = "DCheckBoxLabel",
				cmd = "zpm_cl_dynlight"
			},
			[3] = {
				name = "Animation",
				class = "DCheckBoxLabel",
				cmd = "zpm_cl_animation"
			},
			[4] = {
				name = "Vibration",
				class = "DCheckBoxLabel",
				cmd = "zpm_cl_vibration"
			},
			[5] = {
				name = "Animated Materials",
				class = "DCheckBoxLabel",
				cmd = "zpm_cl_materials"
			},
		})
	end)

	spawnmenu.AddToolMenuOption("Options", "zpm_options", "zpm_Admin_Settings", "Admin Settings", "", "", function(CPanel)

		zclib.Settings.OptionPanel("NPC", nil, Color(180, 145, 103, 255), Color(100, 89, 63, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zpm_npc_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zpm_npc_remove"
			}
		})

		zclib.Settings.OptionPanel("Machine", nil, Color(180, 145, 103, 255), Color(100, 89, 63, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zpm_machine_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zpm_machine_remove"
			}
		})
	end)
end)
