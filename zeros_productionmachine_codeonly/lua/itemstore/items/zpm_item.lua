ITEM.Name = "Item"
ITEM.Description = "A item."
ITEM.Model = "models/props_junk/PopCan01a.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = true
ITEM.DropStack = true

function ITEM:GetName()
	local name = "Undefind"

	local itemID = self:GetData("ItemID")
	local itemAmount = self:GetData("ItemAmount")

	if itemAmount == nil then
		itemAmount = 0
	end

	if zpm.config.Items[itemID] and zpm.config.Items[itemID].name then
		name = zpm.config.Items[itemID].name
	end
	return self:GetData("Name", name)
end

function ITEM:GetModel()

	local ItemID = self:GetData("ItemID")
	local ItemData = zpm.config.Items[ItemID]
	local mdl = "models/props_junk/PopCan01a.mdl"

	if ItemData and ItemData.ent and ItemData.ent.mdl then
		mdl = ItemData.ent.mdl
	end

	return self:GetData("Model", mdl)
end

function ITEM:GetColor()

	local ItemID = self:GetData("ItemID")
	local ItemData = zpm.config.Items[ItemID]
	local col = Color(255,255,255)

	if ItemData and ItemData.color then
		col = ItemData.color
	end

	return self:GetData("Color", col)
end

function ITEM:GetSkin()

	local ItemID = self:GetData("ItemID")
	local ItemData = zpm.config.Items[ItemID]
	local skin = 1

	if ItemData and ItemData.ent and ItemData.ent.skin then
		skin = ItemData.ent.skin
	end

	return self:GetData("Skin", skin)
end

function ITEM:CanMerge(item)
	local ItemID = self:GetData("ItemID")
	return item.Data.ItemID == ItemID
end

/*
function ITEM:CanPickup(pl, ent)
	if zclib.Player.IsOwner(pl, ent) then
		return true
	else
		return false
	end
end
*/

function ITEM:SaveData(ent)
	self:SetData("ItemID", ent:GetItemID())
	self:SetAmount( ent:GetItemAmount() )
end

function ITEM:LoadData(ent)
	local ItemID = self:GetData("ItemID")
	ent:SetItemID(ItemID)
	ent:SetItemAmount(self:GetAmount())

	local data = zpm.config.Items[ ItemID ]
	ent.Model = data.ent.mdl
	ent.CustomSkin = data.ent.skin or 0
end
