AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	zpm.NPC.Initialize(self)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		self.lastUsed = CurTime() + 0.25
		zpm.NPC.OnUse(self, ply)
	end
end

function ENT:OnTakeDamage(dmginfo)
	return 0
end
