include("shared.lua")

function ENT:Initialize()
	zpm.Palette.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zpm.Palette.Draw(self)
end

function ENT:OnRemove()
	zpm.Palette.OnRemove(self)
end

function ENT:Think()
	zpm.Palette.Think(self)
end
