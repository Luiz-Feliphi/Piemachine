include("shared.lua")

function ENT:Initialize()
	zpm.Machine.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zpm.Machine.OnDraw(self)
end

function ENT:Think()
	zpm.Machine.OnThink(self)
end

function ENT:OnRemove()
	zpm.Machine.OnRemove(self)
end
