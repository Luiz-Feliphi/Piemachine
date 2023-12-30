if not SERVER then return end
zpm = zpm or {}
zpm.Palette = zpm.Palette or {}

function zpm.Palette.Initialize(Palette)
    zclib.EntityTracker.Add(Palette)

    Palette:SetMaxHealth(100)
    Palette:SetHealth(100)

    Palette.ProductList = {}

    Palette.LastProductChange = CurTime()

	/*
	timer.Simple(1,function()
		local ProductIDS = {}
		for k, v in pairs(zpm.config.Items) do
			if not v.machine then continue end
			table.insert(ProductIDS, k)
		end

		for i = 1, zpm.config.Palette.Limit do
			table.insert(Palette.ProductList, ProductIDS[ math.random(#ProductIDS) ])
		end
		zpm.Palette.Update(Palette)
	end)
	*/
end

function zpm.Palette.OnRemove(Palette)
    zclib.EntityTracker.Remove(Palette)
end

local item_pos = Vector(50,0,50)
function zpm.Palette.OnUse(Palette, ply)
	if not zclib.Player.IsOwner(ply, Palette) then return end

    if Palette.LastProductChange and CurTime() < (Palette.LastProductChange + 0.5) then return end

    local valid_data,valid_key
    for k,v in pairs(Palette.ProductList) do
        if v and k then
            valid_data = v
            valid_key = k
        end
    end
    table.remove(Palette.ProductList,valid_key)

    if valid_data then

		zpm.Item.Spawn(valid_data,1,Palette:LocalToWorld(item_pos),ply)

        zpm.Palette.Update(Palette)

        Palette:EmitSound("zpm_crate_place")
    end
    Palette.LastProductChange = CurTime()
end

function zpm.Palette.OnStartTouch(Palette,other)
    if not IsValid(Palette) then return end
    if not IsValid(other) then return end
    if Palette.LastProductChange and CurTime() < (Palette.LastProductChange + 0.25) then return end
    if zclib.util.CollisionCooldown(other) then return end
    if table.Count(Palette.ProductList) >= zpm.config.Palette.Limit then return end

    if string.sub(other:GetClass(),1,8) ~= "zpm_item" then return end
    if other:GetItemAmount() <= 0 then return end
	if not zpm.Item.IsProduct(other:GetItemID()) then return end

    zpm.Palette.AddProduct(Palette,other,other:GetItemID(),other:GetItemAmount())
    Palette.LastProductChange = CurTime()

    Palette:EmitSound("zpm_crate_place")
end

util.AddNetworkString("zpm_Palette_Update")
function zpm.Palette.Update(Palette)
    local e_String = util.TableToJSON(Palette.ProductList)
    local e_Compressed = util.Compress(e_String)
    net.Start("zpm_Palette_Update")
    net.WriteEntity(Palette)
    net.WriteUInt(#e_Compressed,16)
    net.WriteData(e_Compressed,#e_Compressed)
    net.Broadcast()
end

function zpm.Palette.AddProduct(Palette,ent,ItemID,ItemAmount)
    zclib.Debug("zpm.Palette.AddProduct")

    // Stop moving if you have physics
    if ent.PhysicsDestroy then ent:PhysicsDestroy() end

    // Hide entity
    if ent.SetNoDraw then ent:SetNoDraw(true) end

	timer.Simple(0.1, function()
		if IsValid(ent) then

			for i = 1, ItemAmount do
				table.insert(Palette.ProductList, ItemID)
			end

			zpm.Palette.Update(Palette)

			SafeRemoveEntity(ent)
		end
	end)
end


concommand.Add("zpm_debug_Palette_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        local tr = ply:GetEyeTrace()

        if tr.Hit then
            local ent = ents.Create("zpm_item_palette")
            if not IsValid(ent) then return end
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            ent:Activate()

            timer.Simple(1,function()
                ent.ProductList = {}
                for i = 1, 32 do
                    table.insert(ent.ProductList, {
                        t = 2,
                        a = zpm.config.Crate.Capacity,
                        q = 100
                    })
                end
                ent.LastProductChange = CurTime()
                zclib.Player.SetOwner(ent, ply)
                zpm.Palette.Update(ent)
            end)
        end
    end
end)
