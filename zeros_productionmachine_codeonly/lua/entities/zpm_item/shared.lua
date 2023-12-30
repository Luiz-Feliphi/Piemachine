ENT.Type 					= "anim"
ENT.Base 					= "base_anim"
ENT.AutomaticFrameAdvance 	= true
ENT.Model 					= "models/props_junk/cardboard_box001a.mdl"
ENT.Spawnable 				= false
ENT.AdminSpawnable 			= false
ENT.PrintName 				= "Product"
ENT.Category 				= "Zeros Productionmachine"
ENT.RenderGroup 			= RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "ItemID")
	self:NetworkVar("Int", 2, "ItemAmount")

    if (SERVER) then
        self:SetItemID(0)
		self:SetItemAmount(0)
    end
end
