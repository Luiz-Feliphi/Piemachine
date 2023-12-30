include("shared.lua")

function ENT:Initialize()
	zpm.Buildkit.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zpm.Buildkit.OnDraw(self)
end

function ENT:Think()
	zpm.Buildkit.OnThink(self)
end

function ENT:OnRemove()
	zpm.Buildkit.OnRemove(self)
end
