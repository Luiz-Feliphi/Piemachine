if not CLIENT then return end
zpm = zpm or {}
zpm.Buildkit = zpm.Buildkit or {}

function zpm.Buildkit.Initialize(Buildkit) end

function zpm.Buildkit.OnThink(Buildkit)

    local i_state = Buildkit:GetBuildState()

    zclib.util.LoopedSound(Buildkit, "zpm_buildkit_construction_loop", i_state == 2)

    // Here we create the build preview model
    if zclib.util.InDistance(LocalPlayer():GetPos(), Buildkit:GetPos(), 1500) and i_state > 0 then
        if not IsValid(Buildkit.PreviewModel) then
            zpm.Buildkit.CreateClientModel(Buildkit)
        end
    else
        zpm.Buildkit.RemoveClientModel(Buildkit)
    end
end

function zpm.Buildkit.OnRemove(Buildkit)
    zpm.Buildkit.RemoveClientModel(Buildkit)
    Buildkit:StopSound("zpm_buildkit_construction_loop")
end

function zpm.Buildkit.RemoveClientModel(Buildkit)
    if IsValid(Buildkit.PreviewModel) then
        zclib.ClientModel.Remove(Buildkit.PreviewModel)
        Buildkit.PreviewModel = nil
    end
end

function zpm.Buildkit.CreateClientModel(Buildkit)

    local ent = zclib.ClientModel.AddProp()
    if not IsValid(ent) then return end
    ent:SetModel("models/zerochain/props_animalfarm/zafa_piemachine01.mdl")
    ent:SetAngles(Buildkit:LocalToWorldAngles(angle_zero))
    ent:SetPos(Buildkit:LocalToWorld(vector_origin))
    ent:Spawn()

    ent:SetParent(Buildkit)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:SetMaterial("zerochain/zpm/shader/zpm_highlight")

    Buildkit.PreviewModel = ent
    zclib.Debug("zpm.Buildkit.CreateClientModel")
end

local lpos = Vector(0,0,0)
function zpm.Buildkit.OnDraw(Buildkit)
    if zclib.util.InDistance(Buildkit:GetPos(), LocalPlayer():GetPos(), 1500) and IsValid(Buildkit.PreviewModel) then

        Buildkit.PreviewModel:SetPos(Buildkit:LocalToWorld(lpos))
        Buildkit.PreviewModel:SetAngles(Buildkit:GetAngles())

        if Buildkit:GetBuildState() == 1 then
            Buildkit.PreviewModel:SetNoDraw(false)
            Buildkit.PreviewModel:SetMaterial("zerochain/zerolib/shader/zlib_highlight")

            if zpm.Buildkit.HasSpace(Buildkit) and zpm.Buildkit.IsAreaFree(Buildkit) then
                Buildkit.PreviewModel:SetColor(zpm.colors["green01"])
            else
                Buildkit.PreviewModel:SetColor(zpm.colors["red01"])
            end
        else
            zpm.Buildkit.DrawConstruction(Buildkit)
        end
    end
end

function zpm.Buildkit.DrawConstruction(Buildkit)
    local FinishTime = Buildkit:GetBuildCompletion()

    if Buildkit.BuildTime == nil then
        Buildkit.BuildTime = FinishTime - CurTime()
    end

    Buildkit.PreviewModel:SetNoDraw(true)
    Buildkit.PreviewModel:SetMaterial(nil)
    Buildkit.PreviewModel:SetColor(color_white)

    local fract = math.Clamp(FinishTime - CurTime(),0,Buildkit.BuildTime)
    fract = Buildkit.BuildTime - fract

    // Draw the spawning effect
    local delta = (1 / Buildkit.BuildTime) * fract
    math.Clamp(delta, 0, 1)

    render.EnableClipping(true)

        local min, max = Buildkit.PreviewModel:OBBMins(), Buildkit.PreviewModel:OBBMaxs()
        min, max = Buildkit.PreviewModel:LocalToWorld(min), Buildkit.PreviewModel:LocalToWorld(max)

        // The clipping plane only draws objects that face the plane
        local normal = -Buildkit.PreviewModel:GetUp()
        local cutPosition = LerpVector(delta, min, max) // Where it cuts
        local cutDistance = normal:Dot(cutPosition) // Project the vector onto the normal to get the shortest distance between the plane and origin

        // Activate the plane
        render.PushCustomClipPlane(normal, cutDistance)

        // Draw the partial model
        Buildkit.PreviewModel:DrawModel()

        // Remove the plane
        render.PopCustomClipPlane()
    render.EnableClipping(false)

    render.MaterialOverride(zclib.Materials.Get("highlight"))
    if zpm.Buildkit.IsAreaFree(Buildkit) then
        render.SetColorModulation(0.1, 0.3, 0.1)
    else
        render.SetColorModulation(0.3, 0.1, 0.1)
    end
    Buildkit.PreviewModel:DrawModel()
    render.MaterialOverride()
    render.SetColorModulation(1, 1, 1)
end
