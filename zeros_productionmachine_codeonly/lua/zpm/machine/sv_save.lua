zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

file.CreateDir("zpm")
zclib.STM.Setup("zpm_machine", "zpm/" .. string.lower(game.GetMap()) .. "_machines" .. ".txt", function()
    local data = {}
    for u, j in ipairs(ents.FindByClass("zpm_machine")) do
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
        local ent = ents.Create("zpm_machine")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end

		ent.IsPublicEntity = true
    end
    zpm.Print("Finished loading Machines!")
end, function()
    for k, v in ipairs(ents.FindByClass("zpm_machine")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

function zpm.Machine.Save(ply)
    zclib.Notify(ply, "Production machines have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Save("zpm_machine")
end

function zpm.Machine.Remove(ply)
    zclib.Notify(ply, "Production machines have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zpm_machine")
end

concommand.Add( "zpm_machine_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zpm.Machine.Save(ply)
    end
end )

concommand.Add( "zpm_machine_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zpm.Machine.Remove(ply)
    end
end )
