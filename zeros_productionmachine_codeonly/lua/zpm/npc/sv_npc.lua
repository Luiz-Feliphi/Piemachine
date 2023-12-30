zpm = zpm or {}
zpm.NPC = zpm.NPC or {}

function zpm.NPC.Initialize(NPC)
	NPC:SetModel("models/Humans/Group03/male_09.mdl")
	NPC:SetSolid(SOLID_BBOX)
	NPC:SetHullSizeNormal()

	NPC:SetNPCState(NPC_STATE_SCRIPT)
	NPC:SetHullType(HULL_HUMAN)
	NPC:SetUseType(SIMPLE_USE)
end

function zpm.NPC.OnUse(NPC,ply)
	zpm.NPC.Sell(NPC, ply)
end

function zpm.NPC.Sell(NPC, ply)

	local Earning = 0
	for _,v in ipairs(ents.FindInSphere(NPC:GetPos(),1500)) do
		if not IsValid(v) then continue end

		if string.sub(v:GetClass(),1,8) == "zpm_item" then

			if not zpm.Item.IsProduct(v:GetItemID()) then continue end

			Earning = (Earning or 0) + zpm.Item.GetPrice(v:GetItemID())

			zclib.NetEvent.Create("zclib_sell", { v:GetPos() })

			SafeRemoveEntity(v)
			continue
		end

		if v:GetClass() ~= "zpm_palette" then continue end
		if not v.ProductList then continue end

		for _,id in pairs(v.ProductList) do
			Earning = (Earning or 0) + zpm.Item.GetPrice(id)
		end
		zclib.NetEvent.Create("zclib_sell", {v:GetPos()})
		SafeRemoveEntity(v)
	end
	if not Earning or Earning <= 0 then
		zclib.Notify(ply, zpm.language["npc_sell_noproduct"], 1)
		return
	end

	// Give the player the Cash
	zclib.Money.Give(ply, Earning)
	zclib.Notify(ply, "+" .. zclib.Money.Display(Earning,true), 0)

	// Custom Hook
	hook.Run("zpm_OnProductSold", ply,NPC,Earning)
end




file.CreateDir("zpm")
zclib.STM.Setup("zpm_npc", "zpm/" .. string.lower(game.GetMap()) .. "_npcs" .. ".txt", function()
    local data = {}
    for u, j in ipairs(ents.FindByClass("zpm_npc")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end
    return data
end, function(data)
    for k, v in ipairs(data) do
        local ent = ents.Create("zpm_npc")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    zpm.Print("Finished loading npcs!")
end, function()
    for k, v in ipairs(ents.FindByClass("zpm_npc")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

function zpm.NPC.Save(ply)
    zclib.Notify(ply, "NPCs have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Save("zpm_npc")
end

function zpm.NPC.Remove(ply)
    zclib.Notify(ply, "NPCs have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zpm_npc")
end

concommand.Add( "zpm_npc_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zpm.Machine.Save(ply)
    end
end )

concommand.Add( "zpm_npc_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zpm.Machine.Remove(ply)
    end
end )
