zpm = zpm or {}
zpm.Buildkit = zpm.Buildkit or {}

function zpm.Buildkit.Trace(start_pos,end_pos)

    debugoverlay.Line( start_pos, end_pos, 0.1, Color( 255, 255,255 ), true )

    local c_trace = zclib.util.TraceLine({
        start = start_pos,
        endpos = end_pos,
        filter = {},
        mask = MASK_SOLID_BRUSHONLY,
    }, "zpm.Buildkit.Trace")
    return c_trace.Hit
end

local function RotCheck(val)
    if val > (0 + 25) or val < (0 - 25) then
        return false
    else
        return true
    end
end

// Tells us if there is enough space for the current tent layout
local min,max = Vector(-90,-80,0),Vector(90,80,95)
function zpm.Buildkit.HasSpace(Buildkit)

    // Check if we got enough space
    local pos = Buildkit:GetPos() + Buildkit:GetUp() * (max.z / 4)
    local left = zpm.Buildkit.Trace(pos,pos + Buildkit:GetRight() * max.y)
    local right = zpm.Buildkit.Trace(pos,pos + Buildkit:GetRight() * min.y)
    local forward = zpm.Buildkit.Trace(pos,pos + Buildkit:GetForward() * max.x)
    local back = zpm.Buildkit.Trace(pos,pos + Buildkit:GetForward() * min.x)
    local up = zpm.Buildkit.Trace(pos,pos + Buildkit:GetUp() * max.z)
    local down = zpm.Buildkit.Trace(pos,pos - Buildkit:GetUp() * 50)

    if left or right or forward or back or up then
        return false
    else
        // Adds a extra check to see if we are on a ground
        if zpm.config.Buildkit.OnGroundCheck == true and down == false then return false end

        // Check if the tent is rotated correctly
        local t_ang = Buildkit:GetAngles()
        if zpm.config.Buildkit.RotationCheck == true and RotCheck(t_ang.p) == false or RotCheck(t_ang.r) == false then return false end

        return true
    end
end

function zpm.Buildkit.IsAreaFree(Buildkit)

    // Check if the area is clear
    local AreaClear = true

    for k,v in ipairs(ents.FindInSphere(Buildkit:GetPos(),200)) do
        if not IsValid(v) then continue end
        if not v:IsPlayer() then continue end

        AreaClear = false
        break
    end

    return AreaClear
end
