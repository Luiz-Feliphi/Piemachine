zpm = zpm or {}
zpm.Machine = zpm.Machine or {}

function zpm.Machine.IncreaseProductivity(Machine, Amount)
	local productivity = Machine:GetProductivity() + Amount
	productivity = math.Clamp(productivity, zpm.config.Machine.Productivity.min, zpm.config.Machine.Productivity.max)
	Machine:SetProductivity(productivity)
end

function zpm.Machine.DecreaseProductivity(Machine, Amount)
	local productivity = Machine:GetProductivity() - Amount
	productivity = math.Clamp(productivity, zpm.config.Machine.Productivity.min, zpm.config.Machine.Productivity.max)
	Machine:SetProductivity(productivity)
end
