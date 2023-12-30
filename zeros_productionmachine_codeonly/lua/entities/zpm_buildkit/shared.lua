ENT.Type 					= "anim"
ENT.Base 					= "base_anim"
ENT.AutomaticFrameAdvance 	= true
ENT.Model 					= "models/zerochain/props_animalfarm/zafa_buildkit.mdl"
ENT.Spawnable 				= true
ENT.AdminSpawnable 			= false
ENT.PrintName 				= "Buildkit"
ENT.Category 				= "Zeros Productionmachine"
ENT.RenderGroup 			= RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

    self:NetworkVar("Int", 1, "BuildState")
    self:NetworkVar("Int", 2, "BuildCompletion")

    if (SERVER) then
        // Unfolded
        self:SetBuildState(0)
        self:SetBuildCompletion(-1)
    end
end
