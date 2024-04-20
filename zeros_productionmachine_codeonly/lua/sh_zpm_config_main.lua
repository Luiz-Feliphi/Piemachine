zpm = zpm or {}
zpm.config = zpm.config or {}

/////////////////////////////////////////////////////////////////////////////

// Bought by {{ user_id }}
// Version {{ script_version_name }}

/////////////////////////// Zeros Productionmachine ///////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242

/////////////////////////////////////////////////////////////////////////////

///////////////////////// zclib Config //////////////////////////////////////
/*
	This config can be used to overwrite the main config of zeros libary
*/
// The Currency
zclib.config.Currency = "$"

// Should the Currency symbol be in front or after the money value?
zclib.config.CurrencyInvert = true

// These Ranks are admins
// If xAdmin, sAdmin or SAM is installed then this table can be ignored
zclib.config.AdminRanks = {
	["superadmin"] = true
}
zclib.config.Debug = false

//zclib.config.CleanUp.SkipOnTeamChange[TEAM_STAFF] = true
/////////////////////////////////////////////////////////////////////////////

// The language , en
zpm.config.SelectedLanguage = "en"


zpm.config.Buildkit = {

	// Should we check if the bottom of the buildkit does touch the ground of the map?
	OnGroundCheck = true,

	// Machines need to be placed up right, No crazy rotations
	RotationCheck = true,
}

/*
	The configuration settings for the zpm.Machine module.
	The settings here determine various aspects of the machine's behavior,
	including productivity limits, fuel and waste management, QTE settings, FuseBox events, and repair events.
*/
zpm.config.Machine = {

	// If true, changes the order of the buttons to make them easier to find
	EasyMode = true,

	// Defines the minimum and maximum productivity limits of the machine (in %)
	// A productivity value of 200% means the machine produces twice as many products
	Productivity = {
		min = 100,
		max = 600,

		// If set to true then the productivity will be reset to min everytime the machine gets stopped.
		ResetOnProductionStop = true,
	},

	// If true, other players can use your machine
	SharedEquipment = true,

	// Defines the length of one machine cycle in seconds (Note: it's recommended to avoid changing this)
	CycleLength = 60,

	// Should the produced item be instantly added to the machines inventory (Otherwhise it will be dropped on the output belt)
	InstantPickup = false,

	QTE = {
		// Defines the time (in seconds) players have to solve a QTE
		Time = 10,

		// Defines the productivity gain (in %) after a successful QTE
		ProductivityGain = 25,

		// Defines the productivity penalty (in %) after a failed QTE
		ProductivityPenalty = 15,

		// Defines the productivity penalty (in %) if the wrong button is pressed
		// Set to -1 to disable
		WrongButtonPenalty = -1
	},

	Fuel = {

		enabled = true,

		// Defines the maximum fuel capacity of the machine
		Capacity = 500,

		// Defines the cost to refill fuel
		Refill_Cost = 10,

		// Defines the amount of fuel added during a refill
		Refill_Amount = 50,

		// Defines the time (in seconds) it takes to refill fuel
		Refill_Time = 3
	},

	// Creates waste overtime which needs to be cleared by the player to reduce the chance of the Repair minigame to trigger
	// NOTE Once the waste level reaches its max capacity, the machine is gonna shutdown and reset
	Waste = {

		enabled = true,

		// Defines the maximum waste capacity of the machine
		Capacity = 500,

		// Defines the amount of waste cleared at once
		Clear_Amount = 25,

		// How often should the waste increase
		Interval = 5,

		// How much should the waste increase
		Increase = 5,
	},

	// FuseBox events require players to hold E on a FuseBox to fix the fuse
	FuseBox = {

		enabled = true,

		// Defines the number of fuses in one FuseBox
		Health = 3,

		// Defines the time (in seconds) players have to hold E on the broken part
		Time = 2,

		// Defines the time (in seconds) until another fuse breaks
		Lifetime = {
			min = 150,
			max = 300,

			// Reduces the fuse lifetime by half if max productivity is reached
			ProductivityReduction = 0.5
		}
	},

	// Sometimes at the top of the machine a repair minigame will trigger
	Repair = {
		enabled = true,

		// Defines the time (in seconds) players have to solve the repair minigame
		Time = 30,

		// Defines the productivity gain (in %) after a successful repair
		ProductivityGain = 25,

		// Defines the productivity penalty (in %) after a failed repair
		ProductivityPenalty = 15,

		// Defines the time (in seconds) until the repair event is triggered in the machine cycle
		Interval = {
			min = 300,
			max = 600,

			// Reduces the repair interval by half if max productivity is reached
			ProductivityPenalty = 0.5,

			// Reduces the repair interval by 0.25 if max waste is reached
			WastePenalty = 0.25,

			// Reduces the repair interval by 0.25 if the temperatur over 65c
			TemperaturPenalty = 0.25,
		}
	},

	// The machines operating temperatur will need to be adjusted overtime in order to prevent a overheat
	Temperatur = {
		enabled = true,
	}
}

/*
	A simple way to transport products
*/
zpm.config.Palette = {
	// How many transport crates fit on the palette
	Limit = 60,
}
