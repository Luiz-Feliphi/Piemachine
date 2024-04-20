zpm = zpm or {}
zpm.Machine = zpm.Machine or {}


/*
	Adds a ingredient data to the inventory
*/
local Ingrediet_Pos = Vector(131, 54.5, 36.5)
function zpm.Machine.AddIngredient(Machine,Product)

	local InsertPos = Machine:LocalToWorld(Ingrediet_Pos)
	if not zclib.util.InDistance(InsertPos, Product:GetPos(), 40) then return end

	local ItemID,ItemAmount = zpm.Item.GetData(Product)
	if not ItemID then return end

	local ProductData = zpm.config.Items[ItemID]
	if not ProductData then return end

	local ItemData = {
        // Basic
        Class = "zpm_item",
        Name = ProductData.name,
        Amount = ItemAmount,

		Data = {ItemID = ItemID},

        // Visuals
        Model = ProductData.visual.mdl,
        Skin = ProductData.visual.skin,
        BodyG = ProductData.visual.bg,
        Color = ProductData.visual.color,
        Material = ProductData.visual.mat,
    }

	if not ProductData.machine then
		zpm.ItemMove.Create(Machine,ItemID,ItemAmount,"InsertRail")
	end

	zclib.Inventory.Give(Machine, ItemData)

	zclib.Entity.SafeRemove(Product)
end

/*
	Check if the Machines inventory has all of the requiered ingredients
*/
function zpm.Machine.HasIngredients(Machine)
	local ProductData = zpm.config.Items[Machine:GetItemID()]
	if not ProductData then return false end
	if not ProductData.machine.ingredients then return false end

	local IngredientInv = {}
	for slot_id, slot_data in ipairs(zclib.Inventory.Get(Machine)) do
		if slot_data.Class ~= "zpm_item" then continue end
		local p_id = zclib.ItemDefinition.GetUniqueID("zpm_item", slot_data)
		local p_amount = zclib.Inventory.GetAmount(Machine, slot_id)
		IngredientInv[ p_id ] = (IngredientInv[ p_id ] or 0) + p_amount
	end

	local HasEnoughIngredients = true
	for product_id,product_amount in pairs(ProductData.machine.ingredients) do
		if not IngredientInv[product_id] then
			HasEnoughIngredients = false
			break
		end

		if IngredientInv[product_id] < product_amount then
			HasEnoughIngredients = false
			break
		end
	end

	return HasEnoughIngredients
end

/*
	Remove all the requiered ingredients from the inventory
*/
function zpm.Machine.RemoveIngredients(Machine)
	local ProductData = zpm.config.Items[Machine:GetItemID()]
	if not ProductData then return end
	if not ProductData.machine.ingredients then return end

	local ToRemove = table.Copy(ProductData.machine.ingredients)

	for slot_id, slot_data in ipairs(zclib.Inventory.Get(Machine)) do
		if slot_data.Class ~= "zpm_item" then continue end

		// Do we need to remove this product id?
		local p_id = zclib.ItemDefinition.GetUniqueID("zpm_item", slot_data)
		local RemoveAmount = ToRemove[p_id]
		if not RemoveAmount then continue end

		// Is there still something left to remove or are we done with this product id?
		if RemoveAmount <= 0 then continue end

		// How much can we remove from this slot?
		local RemoveableAmount = math.Clamp(RemoveAmount,0,slot_data.Amount)

		// Remove from the inventory slot
		slot_data.Amount = (slot_data.Amount or 1) - RemoveableAmount
	    if slot_data.Amount <= 0 then Machine.zclib_inv[slot_id] = {} end

		// Remove from the list
		ToRemove[p_id] = ToRemove[p_id] - RemoveableAmount
	end

	// Tell every client that this inventory just changed
	zclib.Inventory.Synch(Machine)
end
