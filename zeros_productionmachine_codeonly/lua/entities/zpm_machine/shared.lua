ENT.Type 					= "anim"
ENT.Base 					= "base_anim"
ENT.AutomaticFrameAdvance 	= true
ENT.Model 					= "models/zerochain/props_animalfarm/zafa_piemachine01.mdl"
ENT.Spawnable 				= true
ENT.AdminSpawnable 			= false
ENT.PrintName 				= "Production Machine"
ENT.Category 				= "Zeros Productionmachine"
ENT.RenderGroup 			= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	// Is the machine running
	self:NetworkVar("Bool", 1, "IsRunning")


	// What kind of product does this machine produce?
    self:NetworkVar("Int", 1, "ItemID")

	// How much fuel does the machine have?
	self:NetworkVar("Int", 2, "Fuel")

	// How much progress do we have till the product is done?
	self:NetworkVar("Int", 3, "ProductProgress")

	// How much progress till the cycle is done?
	self:NetworkVar("Int", 4, "CycleProgress")


	// How many products can be made per production cycle
	self:NetworkVar("Int", 5, "Productivity")

	// Waste gets produced as a by-product
	self:NetworkVar("Int", 6, "Waste")


	// If the Temperatur hits 100 then the machine is gonna explode
	self:NetworkVar("Int", 7, "Temperatur")

	// Which Temperatur are we currently aiming for
	self:NetworkVar("Int", 8, "TemperaturPointer")

	// Which Temperature do we need to aim for
	self:NetworkVar("Int", 9, "TemperaturTarget")

	// Does the machine need to be repaired?
	self:NetworkVar("Bool", 10, "NeedsRepair")



	// Does the machine need to be repaired?
	self:NetworkVar("Bool", 11, "MissingIngredients")


    if (SERVER) then
        self:SetItemID(0)
		self:SetFuel(300)
		self:SetProductProgress(0)
		self:SetCycleProgress(0)
		self:SetIsRunning(false)

		self:SetProductivity(100)
		self:SetWaste(0)

		self:SetTemperatur(0)
		self:SetTemperaturPointer(5)
		self:SetTemperaturTarget(9)

		self:SetNeedsRepair(false)

		self:SetMissingIngredients(false)
    end
end
