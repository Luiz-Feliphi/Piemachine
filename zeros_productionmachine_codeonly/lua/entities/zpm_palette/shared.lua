ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/props_junk/wood_pallet001a.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Palette"
ENT.Category = "Zeros Productionmachine"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
