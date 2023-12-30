local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/props_junk/PopCan01a.mdl")
ITEM:SetDescription("A item")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data
	ent:SetItemID(data.ItemID)
	ent:SetItemAmount(data.ItemAmount)
end)

function ITEM:GetData(ent)
	return {
		ItemID = ent:GetItemID(),
		ItemAmount = ent:GetItemAmount(),
	}
end

function ITEM:OnPickup(ply, ent)
	if (not IsValid(ent)) then return end

	local info = {
		ent = self:GetEntityClass(ent),
		dropEnt = self:GetDropEntityClass(ent),
		amount = self:GetEntityAmount(ent),
		data = self:GetData(ent)
	}

	self:Pickup(ply, ent, info)

	return true
end

function ITEM:CanStack(newItem, invItem)
	local ent = isentity(newItem)

	local itemID = ent and newItem:GetItemID() or newItem.data.ItemID
	return itemID == invItem.data.ItemID
end

function ITEM:GetVisualAmount(item)
	return item.data.ItemAmount
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetSkin(tbl)
	local ItemID = tbl.data.ItemID
	local ItemData = zpm.config.Items[ItemID]
	local skin = 0

	if ItemData and ItemData.ent and ItemData.ent.skin then
		skin = ItemData.skin
	end

	return skin
end



function ITEM:GetModel(item)
	local mdl = "models/props_junk/PopCan01a.mdl"
	if isstring(item) then
		mdl = item
	else
		local ItemID = isentity(item) and item:GetItemID() or item.data.ItemID
		local ItemData = zpm.config.Items[ItemID]
		if ItemData and ItemData.ent and ItemData.ent.mdl then
			mdl = ItemData.mdl
		end
	end
	return mdl
end

function ITEM:GetName(item)
	local name = "Undefind"

	local ent = isentity(item)
	local itemID = ent and item:GetItemID() or item.data.ItemID

	local ItemData = zpm.config.Items[itemID]

	if ItemData and ItemData.name then
		name = ItemData.name
	end

	return name
end


ITEM:Register("zpm_item")
