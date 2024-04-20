zpm = zpm or {}
zpm.Machine = zpm.Machine or {}
zpm.Machine.UpdateMaterials = {}

matproxy.Add({
    name = "zpm_texturescroll",
    init = function(self, mat, values)
		self.speed = values.speed
    end,
    bind = function(self, mat, ent)
		if not ent:GetIsRunning() then return end

		local speed = mat:GetFloat(self.speed)
		local move = CurTime() * speed
		local vm = Matrix()
		vm:Translate( Vector(move,0,0) )
		mat:SetMatrix("$baseTextureTransform",vm)
		mat:SetMatrix("$bumptransform",vm)
    end
})

local CachedMaterials = {}
local phong_range = Vector(2, 2, 15)
function zpm.Machine.GetMaterial(MatID)

	local m_material

	if CachedMaterials[MatID] == nil then

		CachedMaterials[MatID] = CreateMaterial(MatID, "VertexLitGeneric", {
			["$basetexture"] = "zerochain/props_animalfarm/piemachine/pm_inserter_belt_diff",
			["$halflambert"] = 1,
			["$model"] = 1,

			["$bumpmap"] = "zerochain/props_animalfarm/piemachine/pm_inserter_belt_nrm",
			["$normalmapalphaenvmapmask"] = 1,

			["$phong"] = 1,
			["$phongexponent"] = 3,
			["$phongboost"] = 5,
			["$phongfresnelranges"] = phong_range,

			[ "$belt_speed" ] = 0,
			[ "$belt_movevar" ] = 0,

			["Proxies"] = {

				[ "zpm_texturescroll" ] = {
					[ "speed" ] = "$belt_speed",
				},
			}
		})
	end

	m_material = CachedMaterials[MatID]

	m_material:SetTexture("$basetexture", "zerochain/props_animalfarm/piemachine/pm_inserter_belt_diff")
	m_material:SetInt("$halflambert", 1)
	m_material:SetInt("$model", 1)

	m_material:SetTexture("$bumpmap", "zerochain/props_animalfarm/piemachine/pm_inserter_belt_nrm")
	m_material:SetInt("$normalmapalphaenvmapmask", 1)

	m_material:SetInt("$phong", 1)
	m_material:SetFloat("$phongexponent", 3)
	m_material:SetFloat("$phongboost", 5)
	m_material:SetVector("$phongfresnelranges", phong_range)

	// $model + $normalmapalphaenvmapmask + $opaquetexture
	m_material:SetInt("$flags", 2048 + 4194304 + 16777216)

	// Refresh the material
	m_material:Recompute()

	return m_material
end

function zpm.Machine.UpdateMaterial(Machine,index,id,speed)

	local matID = "zpm_Machine_paint_mat_" .. Machine:EntIndex() .. id

	// Builds / Updates / Caches the material
	local mat = zpm.Machine.GetMaterial(matID)
	if mat then
		mat:SetFloat("$belt_speed",speed)
	end

	Machine:SetSubMaterial(index, "!" .. matID)
end

function zpm.Machine.PreDraw()
	if not zclib.Convar.GetBool("zpm_cl_materials") then return end
    for ent,_ in pairs(zpm.Machine.UpdateMaterials) do

        if not IsValid(ent) then
			continue
		end

		if not ent.m_Initialized then continue end

        // If we cant see the Machine then skip
        if zclib.util.IsInsideViewCone(ent:GetPos(),EyePos(),EyeAngles(),1000,2000) == false then
			ent.UpdatedMachine_material = nil
            continue
        end

		if ent.UpdatedMachine_material == nil then

			ent:SetSubMaterial()

			// Creates / Updates the Machines lua materials
			zpm.Machine.UpdateMaterial(ent,31,"insert_rail",-3)
			zpm.Machine.UpdateMaterial(ent,27,"insert_belt",0.5)

			ent.UpdatedMachine_material = true
		end
    end
end
zclib.Hook.Remove("PreDrawHUD", "zpm_Machine_draw")
zclib.Hook.Add("PreDrawHUD", "zpm_Machine_draw", zpm.Machine.PreDraw)
