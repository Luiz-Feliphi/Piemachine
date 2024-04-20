zpm = zpm or {}
zpm.Machine = zpm.Machine or {}
zpm.Machine.List = zpm.Machine.List or {}

/*
    Initializes the Machine entity.
    @param Machine The Machine entity to be initialized.
*/
function zpm.Machine.Initialize(Machine)
    zclib.Debug("zpm.Machine.Initialize")
    Machine:SetModel(Machine.Model)
    Machine:PhysicsInit(SOLID_VPHYSICS)
    Machine:SetSolid(SOLID_VPHYSICS)
    Machine:SetMoveType(MOVETYPE_VPHYSICS)
    Machine:SetUseType(SIMPLE_USE)

    Machine:UseClientSideAnimation()

    local phys = Machine:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    zclib.EntityTracker.Add(Machine)

    -- Creates the inventory for the Machine with 20 slots.
    zclib.Inventory.Setup(Machine,20)

    -- Sets up everything required for bone animation.
    zpm.Machine.Bone:Setup(Machine)

    -- Sets up everything required for the Quicktime events.
    zpm.Machine.QTE:Setup(Machine)

    -- Sets up everything required for the fuse events.
    zpm.Machine.Fuse:Setup(Machine)

    table.insert(zpm.Machine.List,Machine)

    Machine:SetSkin(1)


	// TODO Remove this later
	/*
	for k,ProductData in ipairs(zpm.config.Items) do
		if not ProductData then continue end
		if ProductData.machine then continue end
		//if ProductData.visual.mdl ~= "models/props_c17/FurnitureCouch001a.mdl" then continue end

		local ItemData = {
	        // Basic
	        Class = "zpm_item",
	        Name = ProductData.name,
	        Amount = 70,

			Data = {ItemID = k},

	        // Visuals
	        Model = ProductData.visual.mdl,
	        Skin = ProductData.visual.skin,
	        BodyG = ProductData.visual.bg,
	        Color = ProductData.visual.color,
	        Material = ProductData.visual.mat,
	    }

		zclib.Inventory.Give(Machine, ItemData)
	end
	*/
end

/*
    Called when a player uses the Machine entity.
    @param Machine The Machine entity that was used.
    @param ply The player who used the Machine.
*/
local screen01_pos = Vector(169.4,43,81.6)
local screen02_pos = Vector(49.4,-66.4,51.5)
local ladder_endpoint_pos = Vector(-110,-90,100)
function zpm.Machine.OnUse(Machine,ply)

    -- Checks if the player has the correct job to interact with the Machine.
	local CanInteract,ErrorMsg = zpm.Machine.CanInteract(Machine,ply)
    if not CanInteract then
        if ErrorMsg then zclib.Notify(ply, ErrorMsg, 1) end
        return
    end

    -- Refill fuel action.
    if zpm.Machine.Fuel:Refill(Machine,ply) then return end

    -- Opens the product selection interface.
    if zpm.Machine.OnInterface(Machine,ply,screen01_pos) then
        zpm.Machine.OpenInterface(Machine,ply)
        return
    end

	if zpm.Machine.OnInterface(Machine,ply,screen02_pos) then
        zpm.Machine.OpenInterface(Machine,ply)
        return
    end

	-- Teleports the player up the machine
	if zpm.Machine.OnLadderButton(Machine,ply) then
        ply:SetPos(Machine:LocalToWorld(ladder_endpoint_pos))
		zclib.Sound.EmitFromPosition(ply:GetPos(),"zpm_temperatur_change")
        return
    end



    -- Prevents interaction if the machine is turned off.
    if not Machine:GetIsRunning() then return end

    -- Clears the waste.
    if zpm.Machine.Waste:Clear(Machine,ply) then return end

    -- Changes the temperature level.
    if zpm.Machine.Temperatur:Change(Machine,ply) then return end

    -- Interacts with the fuses.
    if zpm.Machine.Fuse:Interact(Machine,ply) then return end

    -- Only triggers every 0.5 seconds to prevent spam.
    if Machine.NextButtonPress and Machine.NextButtonPress > CurTime() then return end
    Machine.NextButtonPress = CurTime() + 0.5

    -- Animates the pressed button, if possible.
    zpm.Machine.Button:Press(Machine,ply)

    -- Interacts with the Quicktime events.
    if zpm.Machine.QTE:Interact(Machine,ply) then return end

    -- Interacts with the repair buttons.
    if zpm.Machine.Repair:Interact(Machine,ply) then return end
end

/*
	This function is called when the machine is touched by another entity.
	If the machine is running and the touching entity is a valid ingredient, then the ingredient is added to the machine.
*/
function zpm.Machine.Touch(Machine,other)
	if not IsValid(Machine) then return end
	if not IsValid(other) then return end

	if not Machine:GetIsRunning() then return end

	if not zpm.Item.IngredientClass[other:GetClass()] then return end

	if zclib.Entity.GettingRemoved(other) then return end

	zpm.Machine.AddIngredient(Machine,other)
end

util.AddNetworkString("zpm.Machine.OpenInterface")
function zpm.Machine.OpenInterface(Machine,ply)
	zclib.Debug("zpm.Machine.OpenInterface")

	net.Start("zpm.Machine.OpenInterface")
	net.WriteEntity(Machine)
	net.Send(ply)
end

/*
	Starts / Stops the machines
*/
util.AddNetworkString("zpm.Machine.Toggle")
net.Receive("zpm.Machine.Toggle", function(len,ply)
	if zclib.Player.Timeout(nil,ply) then return end
    zclib.Debug("zpm.Machine.Toggle Len: " .. len)

    local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if Machine:GetClass() ~= "zpm_machine" then return end
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if not zclib.util.InDistance(Machine:GetPos(), ply:GetPos(), 800) then return end

	if not zpm.Machine.CanInteract(Machine,ply) then return end

	if Machine:GetItemID() <= 0 then return end
	if Machine:GetFuel() <= 0 then return end

	Machine:SetIsRunning(not Machine:GetIsRunning())

	timer.Simple(0.1,function()
		if IsValid(Machine) and IsValid(ply) then
			zpm.Machine.OpenInterface(Machine,ply)
		end
	end)

	if Machine:GetIsRunning() then
		zpm.Machine.StartProduction(Machine)
	else
		zpm.Machine.StopProduction(Machine)
	end
end)

/*
	Changes the active produces Product
*/
util.AddNetworkString("zpm.Machine.SelectProduct")
net.Receive("zpm.Machine.SelectProduct", function(len,ply)
	if zclib.Player.Timeout(nil,ply) then return end
    zclib.Debug("zpm.Machine.SelectProduct Len: " .. len)

    local Machine = net.ReadEntity()
	local ItemID = net.ReadUInt(10)

	if not ItemID then return end
	if not IsValid(Machine) then return end
	if Machine:GetClass() ~= "zpm_machine" then return end
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if not zclib.util.InDistance(Machine:GetPos(), ply:GetPos(), 800) then return end

	if not zpm.Machine.CanInteract(Machine,ply) then return end

	if ItemID == 0 then
		Machine:SetItemID(0)
		return
	end

	local ProductData = zpm.config.Items[ItemID]
	if not ProductData then return end
	if not ProductData.machine.ingredients then return end

	if not zpm.Item.CanMake(ItemID,ply) then return end

	Machine:SetItemID(ItemID)
end)

/*
	Starts production of the selected product for a given machine.
	@param Machine (Entity) - The machine that will start production.
*/
local product_endpos = Vector(75,-90,50)
function zpm.Machine.StartProduction(Machine)

	// Remove old timer
	local timerid = "zpm.Machine.Production_" .. Machine:EntIndex()
	zclib.Timer.Remove(timerid)

	// Set machine skin to default
	Machine:SetSkin(0)

	// Get product ID and its data from config
	local ItemID = Machine:GetItemID()
	local ProductData = zpm.config.Items[ItemID]
	if not ProductData then return end

	// Check if the machine has fuel to continue production
	if Machine:GetFuel() <= 0 then
		zpm.Machine.StopProduction(Machine)
		return
	end


	// Check if the machine has all the required ingredients in its inventory
	if not zpm.Machine.HasIngredients(Machine) then

		Machine:SetMissingIngredients(true)

		// Try again in 1 second if the machine is still turned on
		timer.Simple(1,function()
			if IsValid(Machine) and Machine:GetIsRunning() then

				// Use fuel
				zpm.Machine.Fuel:Check(Machine)

				zpm.Machine.StartProduction(Machine)
			end
		end)

		return
	end

	Machine:SetMissingIngredients(false)

	// Create visual of the ingredients being added to the machine via convey belt
	for p_id,p_amount in pairs(ProductData.machine.ingredients) do
		zpm.ItemMove.Create(Machine,p_id,p_amount,"ConveyBelt")
	end

	// Remove ingredients from inventory
	zpm.Machine.RemoveIngredients(Machine)

	Machine:SetProductProgress(0)

	// Restart production cycle
	zpm.Machine.CycleRestart(Machine)

	// Start production timer
	zclib.Timer.Create(timerid, 1,0, function()

		if not IsValid(Machine) then
			zclib.Timer.Remove(timerid)
			return
		end

		// Check if the machine has fuel to continue production
		if Machine:GetFuel() <= 0 then
			zpm.Machine.StopProduction(Machine)
			return
		end

		// Use fuel
		zpm.Machine.Fuel:Check(Machine)

		// Perform temperature check
		zpm.Machine.Temperatur:Check(Machine)

		// Check for unsolved QTEs
		zpm.Machine.QTE:Check(Machine)

		// Check for unsolved fuse events
		zpm.Machine.Fuse:Check(Machine)

		// Increase the waste
		zpm.Machine.Waste:Check(Machine)

		// Check if there is any repair game going on
		zpm.Machine.Repair:Check(Machine)

		// Check if the machine has all the required ingredients in its inventory
		if not zpm.Machine.HasIngredients(Machine) then
			//zpm.Machine.StartProduction(Machine)
			Machine:SetMissingIngredients(true)
			return
		end

		Machine:SetMissingIngredients(false)

		// Increase the progress of the current production cycle
		Machine:SetCycleProgress(Machine:GetCycleProgress() + 1)

		// Increase the progress of the current product
		Machine:SetProductProgress(Machine:GetProductProgress() + 1)

		// Did we finish another product?
		if Machine:GetProductProgress() > ProductData.machine.time then
			zclib.Debug("zpm.Machine.FinishProduction")

			local owner = zclib.Player.GetOwner(Machine)

			// Spawn the finished product and pick it up
			if zpm.config.Items[ ItemID ].onspawn then
				local ent = zpm.config.Items[ ItemID ].onspawn(Machine:LocalToWorld(product_endpos),Machine,owner)
				if IsValid(ent) and IsValid(owner) then
					zclib.Player.SetOwner(ent, owner)
				end
			else
				// BUG Pie does not spawn with correct skin
				local ent = zpm.Item.Spawn(ItemID,math.Round((1 / 100) * Machine:GetProductivity()),Machine:LocalToWorld(product_endpos),owner)
				if zpm.config.Machine.InstantPickup then zclib.Inventory.PickUpEntity(Machine, ent) end
			end

			// Reset product progress
			Machine:SetProductProgress(0)

			// Check if there are still ingredients in the machine
			if zpm.Machine.HasIngredients(Machine) then
				// Create a visual of the ingredients being added to the machine via convey belt
				for p_id,p_amount in pairs(ProductData.machine.ingredients) do zpm.ItemMove.Create(Machine,p_id,p_amount,"ConveyBelt") end

				// Remove the ingredients from the inventory
				zpm.Machine.RemoveIngredients(Machine)
			else
				// If there are no ingredients, start production again
				zpm.Machine.StartProduction(Machine)
			end
		end

		// Check if the machine's cycle has completed
		// Each cycle will take zpm.config.Machine.CycleLength seconds
		if Machine:GetCycleProgress() >= zpm.config.Machine.CycleLength then
			// Restart the cycle
			zpm.Machine.CycleRestart(Machine)
		end
	end)
end

/*
	Restarts the cycle
*/
function zpm.Machine.CycleRestart(Machine)
	// Lets start at 0
	Machine:SetCycleProgress(0)

	// While producing something we should make a quick time event appear which increases the productivity
	zpm.Machine.QTE:Create(Machine)

	// Changes the target temperatur which the player needs to adjust
	zpm.Machine.Temperatur:ChangeTarget(Machine)
end

/*
	Stop production
*/
function zpm.Machine.StopProduction(Machine)
	// Log that production is being stopped
	zclib.Debug("zpm.Machine.StopProduction")

	// Emit a sound effect to indicate that the machine is shutting down
	Machine:EmitSound("zpm_machine_shutdown")

	// Set the machine's skin to 1
	Machine:SetSkin(1)

	// Remove the timer that was controlling the production cycle
	zclib.Timer.Remove("zpm.Machine.Production_" .. Machine:EntIndex())

	// Set the machine's running state to false
	Machine:SetIsRunning(false)

	// Reset the progress of the product and the cycle
	Machine:SetProductProgress(0)
	Machine:SetCycleProgress(0)

	Machine:SetTemperatur(0)

	// If configured to do so, reset the machine's productivity to its minimum value
	if zpm.config.Machine.Productivity.ResetOnProductionStop then
		Machine:SetProductivity(zpm.config.Machine.Productivity.min)
	end

	// Set up the QTE and fuse for the machine
	zpm.Machine.QTE:Setup(Machine)
	zpm.Machine.Fuse:Setup(Machine)

	// Reset the machine's repair state
	zpm.Machine.Repair:Reset(Machine)
end

/*
	Send the player the inventory of all machines
*/
zclib.Hook.Add("zclib_PlayerJoined", "zpm.Machine.Inventory.Synch", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        for k,v in pairs(zpm.Machine.List) do
			if not IsValid(v) then continue end
        	zclib.Inventory.SynchForPlayer(v,ply)
        end
    end)
end)
