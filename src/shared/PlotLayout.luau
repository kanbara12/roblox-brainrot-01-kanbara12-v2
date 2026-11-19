-- PlotLayout: where every base sits in the world, and where each of its 8
-- numbered slots is. One module so the conveyor, the steal service and the
-- rival plot all agree on the same coordinates as the static world in
-- default.project.json.

local PlotLayout = {}

PlotLayout.PLOTS = {
	PlotA = { center = Vector3.new(-45, 1, 30), sign = "YOUR BASE" },
	PlotB = { center = Vector3.new(45, 1, 30), sign = "BASE 2" },
	Rival = { center = Vector3.new(0, 1, 78), sign = "RIVAL BASE" },
}

PlotLayout.SLOT_SPACING_X = 9
PlotLayout.SLOT_SPACING_Z = 11

function PlotLayout.getPlotCenter(plotName)
	local plot = PlotLayout.PLOTS[plotName]
	if not plot then
		return Vector3.new(0, 1, 30)
	end
	return plot.center
end

-- Slots 1-4 are the back row, 5-8 the front row, numbered left to right.
function PlotLayout.getSlotPosition(plotName, slot)
	local center = PlotLayout.getPlotCenter(plotName)
	local col = (slot - 1) % 4
	local row = math.floor((slot - 1) / 4)
	local x = center.X + (col - 1.5) * PlotLayout.SLOT_SPACING_X
	local z = center.Z + (row - 0.5) * PlotLayout.SLOT_SPACING_Z
	return Vector3.new(x, 3.2, z)
end

function PlotLayout.getSlotPadPosition(plotName, slot)
	local pos = PlotLayout.getSlotPosition(plotName, slot)
	return Vector3.new(pos.X, 1.6, pos.Z)
end

-- Rig origin is the body center, so a rig stands on a pad when its origin
-- sits 2 studs per unit of scale above the pad top (2.6).
function PlotLayout.getSlotRigPosition(plotName, slot, scale)
	local pos = PlotLayout.getSlotPosition(plotName, slot)
	return Vector3.new(pos.X, 2.6 + 2.0 * (scale or 1), pos.Z)
end
-- there (or high up anywhere) survives the tsunami.
function PlotLayout.isPositionOnHighGround(position)
	if position.Y > 20 then
		return true
	end
	return false
end

return PlotLayout
