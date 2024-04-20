zpm = zpm or {}
zpm.Item = zpm.Item or {}

function zpm.Item.Spawn(ItemID,ItemAmount,Pos,ply)
	local Product = ents.Create("zpm_item")
	Product:SetItemID(ItemID)
	Product:SetItemAmount(ItemAmount)
	Product.Model = zpm.config.Items[ ItemID ].ent.mdl
	Product:SetPos(Pos)
	Product:Spawn()
	Product:Activate()

	if ply then zclib.Player.SetOwner(Product, ply) end

	return Product
end

function zpm.Item.Initialize(Product)
	Product:SetModel(Product.Model)
	Product:PhysicsInit(SOLID_VPHYSICS)
	Product:SetSolid(SOLID_VPHYSICS)
	Product:SetMoveType(MOVETYPE_VPHYSICS)
	Product:SetUseType(SIMPLE_USE)
	Product:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = Product:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	if Product.CustomSkin then Product:SetSkin(Product.CustomSkin) end
end

function zpm.Item.OnTouch(Product,other)
	if not IsValid(other) then return end
	if not IsValid(Product) then return end
	if other:GetClass() ~= "zpm_item" then return end
	if zclib.util.CollisionCooldown(other) then return end
	if other.LastTouch and other.LastTouch + 1 > CurTime() then return end
    other.LastTouch = CurTime()

	if other:GetItemID() ~= Product:GetItemID() then return end

	Product:SetItemAmount(Product:GetItemAmount() + other:GetItemAmount())

	SafeRemoveEntity(other)
end

concommand.Add("zpm_spawn_products", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr and tr.Hit and tr.HitPos then
			undo.Create("zpm_item")

			for k,v in ipairs(zpm.config.Items) do
				local ent = zpm.Item.Spawn(k, 100, tr.HitPos + zclib.util.GetRandomPositionInsideCircle(25, 120, 15), ply)
				ent:SetAngles(Angle(0, math.random(360), 0))
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
			end

			undo.Finish()
		end
	end
end)

function zpm.Item.OnUse(Item,ply)
	local ItemID,ItemAmount = zpm.Item.GetData(Item)

	local ProductData = zpm.config.Items[ ItemID ]
	if not ProductData then return end
	if not ProductData.hunger then return end

	// Lets check if the darkrp hungermod var exists
	if ProductData.hunger.energy and ProductData.hunger.energy > 0 and ply.getDarkRPVar and ply:getDarkRPVar("Energy") then
		local newEnergy = math.Clamp((ply:getDarkRPVar("Energy") or 100) + ProductData.hunger.energy, 0, 100)
		ply:setDarkRPVar("Energy", newEnergy)
	end

	if ProductData.hunger.health and ProductData.hunger.health > 0 then
		ply:SetHealth(math.Clamp(ply:Health() + ProductData.hunger.health,0,ProductData.hunger.health_cap or ply:GetMaxHealth()))
	end

	if ItemAmount <= 1 then
		SafeRemoveEntity(Item)
	else
		Item:SetItemAmount(ItemAmount - 1)
	end
end
