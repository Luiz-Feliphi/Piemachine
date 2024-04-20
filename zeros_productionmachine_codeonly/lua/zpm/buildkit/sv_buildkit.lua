if not SERVER then return end
zpm = zpm or {}
zpm.Buildkit = zpm.Buildkit or {}

function zpm.Buildkit.Initialize(Buildkit)
	Buildkit:SetModel(Buildkit.Model)
    Buildkit:PhysicsInit(SOLID_VPHYSICS)
    Buildkit:SetSolid(SOLID_VPHYSICS)
    Buildkit:SetMoveType(MOVETYPE_VPHYSICS)
    Buildkit:SetUseType(SIMPLE_USE)
    Buildkit:UseClientSideAnimation()
    local phys = Buildkit:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    zclib.EntityTracker.Add(Buildkit)
end

function zpm.Buildkit.OnRemove(Buildkit)
    zclib.Timer.Remove("zpm_Buildkit_ConstructionTimer_" .. Buildkit:EntIndex())
end

function zpm.Buildkit.OnUse(Buildkit,ply)

    local i_state = Buildkit:GetBuildState()

	// Its in the box
	if i_state == 0 then

		Buildkit:SetBuildState(1)

	// Its showing the preview
	elseif i_state == 1 then

		// Start building process
		Buildkit:SetBuildState(2)
        Buildkit:SetBuildCompletion(math.Round(CurTime() + 10))

        // Notify all players to clear the area
        for k,v in ipairs(ents.FindInSphere(Buildkit:GetPos(),500)) do
            if not IsValid(v) then continue end
            if v:IsPlayer() == false then continue end
            zclib.Notify(v, zpm.language["BuildkitBuild_Info"], 3)
        end

        local timerid = "zpm_Buildkit_ConstructionTimer_" .. Buildkit:EntIndex()
        zclib.Timer.Create(timerid, 10, 1, function()
            zpm.Buildkit.CompleteBuilder(Buildkit,ply)
            zclib.Timer.Remove(timerid)
        end)

	// Its building
	elseif i_state == 2 then

		Buildkit:SetBuildState(0)
		zclib.Timer.Remove("zpm_Buildkit_ConstructionTimer_" .. Buildkit:EntIndex())
	end
end

function zpm.Buildkit.CompleteBuilder(Buildkit,ply)
    if not IsValid(Buildkit) then return end
    if not IsValid(ply) then return end

    if zpm.Buildkit.HasSpace(Buildkit) == false or zpm.Buildkit.IsAreaFree(Buildkit) == false then
        zclib.Notify(ply, zpm.language["BuildkitBuild_Abort"], 1)

        Buildkit:SetBuildState(0)
        return
    end

    Buildkit:SetBuildState(2)

    zclib.Sound.EmitFromEntity("buildkit_construction_complete", Buildkit)

    zclib.Notify(ply, zpm.language["ConstructionCompleted"], 0)

	local ent = ents.Create("zpm_machine")
	ent:SetAngles(Buildkit:GetAngles())
	ent:SetPos(Buildkit:LocalToWorld(vector_origin))
	ent:Spawn()
	ent:Activate()

	SafeRemoveEntity(Buildkit)

    zclib.Player.SetOwner(ent, ply)
end
