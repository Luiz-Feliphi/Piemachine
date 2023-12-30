zpm = zpm or {}
zpm.Item = zpm.Item or {}

zpm.Item.IngredientClass = {}
zpm.Item.IngredientClass["zpm_item"] = true

function zpm.Item.GetData(ent)
	if string.find(ent:GetClass(),"zpm_item") then return ent:GetItemID(), ent:GetItemAmount() end

	local Conversions = zpm.Item.Conversion[ent:GetClass()]
	if not Conversions then return end

	local ItemID, ItemAmount
	for _, func in ipairs(Conversions) do
		local id, am = func(ent)
		if not id then continue end
		ItemID = id
		ItemAmount = am
		break
	end

	return ItemID,ItemAmount
end

/*
	Applys all the visual data to the entity
*/
function zpm.Item.ApplyVisuals(ent,ItemID)

	local ProductData = zpm.config.Items[ ItemID ]
	if not ProductData then return false end
	if not ProductData.visual.mdl then return false end

	ent:SetModel(ProductData.visual.mdl)

	if ProductData.visual.skin then
		ent:SetSkin(ProductData.visual.skin or 0)
	elseif ProductData.ent.skin then
		ent:SetSkin(ProductData.ent.skin or 0)
	end

	if ProductData.visual.mat then
		ent:SetMaterial(ProductData.visual.mat)
	end

	if ProductData.visual.color then
		ent:SetColor(ProductData.visual.color)
	end
end

/*
	Returns a list of product ids this player can make
*/
function zpm.Item.GetRecipeList(ply)
	local list = {}
	for k,v in ipairs(zpm.config.Items) do
		if not v then continue end
		if not v.machine then continue end
		if v.jobs and not v.jobs[ply:Team()] then continue end
		table.insert(list,k)
	end
	return list
end

/*
	Returns the name of the item
*/
function zpm.Item.GetName(ItemID)
	local dat = zpm.config.Items[ItemID]
	if not dat or not dat.name then return "nil" end
	return dat.name
end

/*
	Returns if the item is a product that can be sold
*/
function zpm.Item.IsProduct(ItemID)
	local dat = zpm.config.Items[ItemID]
	if not dat or not dat.machine then return false end
	return true
end

/*
	Returns the sell value
*/
function zpm.Item.GetPrice(ItemID)
	local dat = zpm.config.Items[ItemID]
	if not dat or not dat.money then return 0 end
	return dat.money
end


/*
	Register the item for zclib Inventory
*/
local function GetVisualData(SlotData)
	local ItemID = SlotData.Data.ItemID
	if not ItemID then return end
	local ItemData = zpm.config.Items[ItemID]
	if not ItemData then return end
	if not ItemData.ent then return end
	return ItemData.ent
end
zclib.ItemDefinition.Register({
    Class = "zpm_item",

	// Specifies that we cant collect the item in to our inventory (Since we dont use the PersonalInventory from ZerosInventory)
	PreventCollect = true,

    // Overwrites the Items name
    Name = function(ItemData)
		local ItemID = isentity(ItemData) and ItemData:GetItemID() or ItemData.Data.ItemID
		return zpm.config.Items[ItemID].name
	end,

    // Specifies the money value of the item
    Price = function(ItemData)
        local ItemID = isentity(ItemData) and ItemData:GetItemID() or ItemData.Data.ItemID
        local ItemAmount = isentity(ItemData) and ItemData:GetItemAmount() or ItemData.Amount
        return (zpm.config.Items[ItemID].money or 0) * ItemAmount
    end,

    // Gets called when the entity being picked up
    GetData = function(ent)
        return {ItemID = ent:GetItemID()}
    end,

    // Gets called when the entity being spawned in the world
    SetData = function(ItemData, ent)
        ent:SetItemID(ItemData.Data.ItemID)
		ent:SetItemAmount(ItemData.Amount)
    end,

    // Returns the value which makes the item identify between other items of the same class
    GetUniqueID = function(ItemData)
        return ItemData.Data.ItemID
    end,

	// Gets used to figure out the Amount var
    GetAmount = function(ItemData)
        return isentity(ItemData) and ItemData:GetItemAmount() or ItemData.Amount
    end,

    // Returns how many of those item classes which have the same GetUniqueID can be stacked
    GetStackLimit = function(ItemData)
        return 100
    end,

    // Overwrites the Items model data
	Model = function(_,SlotData)
		local visual = GetVisualData(SlotData)
		if not visual then return end
		return visual.mdl
	end,
	Skin = function(_,SlotData)
		local visual = GetVisualData(SlotData)
		if not visual then return end
		return visual.skin
	end,
	BodyG = function(_,SlotData)
		local visual = GetVisualData(SlotData)
		if not visual then return end
		return visual.bg
	end,
    Color = function(_,SlotData)
		local visual = GetVisualData(SlotData)
		if not visual then return end
		return visual.color
	end,
    Material = function(_,SlotData)
		local visual = GetVisualData(SlotData)
		if not visual then return end
		return visual.mat
	end,

    // This can be used to give the Item a custom background and color
    BG_Image = zclib.Materials.Get("item_bg"),
    BG_Color = function(SlotData)
		if not SlotData then return end
		if not SlotData.Data then return end

		local ItemID = SlotData.Data.ItemID
		if not ItemID then return end

		local ItemData = zpm.config.Items[ItemID]
		if not ItemData then return end
		if not ItemData.money then return zclib.colors["text01"] end

		return zclib.colors["green01"]
	end,

    // This will add the Drop/throw option in the optionbox
    OnDrop = function()
    end,

    // This will add the destroy option in the optionbox
    OnDestroy = function()
    end,

	/*
		Here we add custom Inventory slot options for products that can be sold
	*/
	CustomOptions = function(SlotData)
		local Options = {}

		local ItemID = SlotData.Data.ItemID
		if not ItemID then return end

		local ItemAmount = SlotData.Amount
		if not ItemAmount then return end

		local ItemData = zpm.config.Items[ItemID]
		if not ItemData then return end
		if not ItemData.money then return end

		local Money = ItemData.money * ItemAmount

		Options["sell"] = {
			name = zpm.language["Sell for"] .. " " .. zclib.Money.Display(Money,true),
			color = zclib.colors[ "green01" ],
			func = function(ply,ent,SlotID,pnl)

				if SERVER then
					zclib.Money.Give(ply, Money)

					// Delete the item from the inventory
					return true
				else
					if pnl then zclib.vgui.PlayEffectAtPanel("Sell", pnl) end
				end
			end
		}

		return Options
	end
})

if CLIENT then
	zclib.Snapshoter.SetPath("zpm_item",function(ItemData)
		if ItemData.data.ItemID then
			return "zpm/" .. ItemData.data.ItemID
		end
	end)

	zclib.Hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosPieMachine", function(ent, dat)
		if dat and dat.class == "zpm_item" and dat.data and dat.data.ItemID then
			local ItemID = dat.data.ItemID
			if not ItemID then return end
			local ItemData = zpm.config.Items[ItemID]
			if not ItemData then return end
			if not ItemData.ent then return end

			if ItemData.ent.mdl then
				ent:SetModel(ItemData.ent.mdl)
			end

			if ItemData.ent.skin then
				ent:SetSkin(ItemData.ent.skin)
			end

			if ItemData.ent.bg then
				for k, v in pairs(ItemData.ent.bg) do
					ent:SetBodygroup(k, v)
				end
			end

			if ItemData.ent.mat then
				ent:SetMaterial(ItemData.ent.mat)
			end

			if ItemData.ent.color then
				render.SetColorModulation(ItemData.ent.color.r / 255, ItemData.ent.color.g / 255, ItemData.ent.color.b / 255, 255)
			end
		end
	end)
end

for id,data in ipairs(zpm.config.Items) do

	local class = "zpm_item_" .. string.lower(string.Replace(data.name, " ", "_"))

	local ENT = {}
	ENT.Class = class
	ENT.Type = "anim"
	ENT.Base = "zpm_item"
	ENT.PrintName = data.name
	ENT.Category = "Zeros Productionmachine"
	ENT.Spawnable = true
	ENT.Model = data.ent.mdl
	ENT.CustomSkin = data.ent.skin

	if CLIENT then
		//local img = zclib.Snapshoter.Get(RenderData, self)
		ENT.CustomIcon = data.ent.mdl
	end


	function ENT:SetupDataTables()
	    self:NetworkVar("Int", 1, "ItemID")
		self:NetworkVar("Int", 2, "ItemAmount")

	    if (SERVER) then
	        self:SetItemID(id)
			self:SetItemAmount(data.ent.amount)
	    end
	end

	scripted_ents.Register(ENT, class)

	zpm.Item.IngredientClass[class] = true

	if data.visual.mdl then util.PrecacheModel(data.visual.mdl) end
	if data.ent.mdl then util.PrecacheModel(data.ent.mdl) end
end
