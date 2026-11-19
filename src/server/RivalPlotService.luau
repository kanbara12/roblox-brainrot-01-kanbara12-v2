-- RivalPlotService: the solo player's steal target. A rival's plot sits on
-- the south pier, stocked with a Common, a Golden Legendary and a Diamond
-- Mythic, behind a Lock Shield that cycles open and shut. Stealing from it
-- works exactly like stealing from a real player, so the loop is provable
-- with one player in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local BrainrotRenderer = require(ReplicatedStorage.Shared.BrainrotRenderer)
local GameState = require(script.Parent.GameState)
local PlotLayout = require(ReplicatedStorage.Shared.PlotLayout)

local RivalPlotService = {}

RivalPlotService.SHIELD_UP_SECONDS = 45
RivalPlotService.SHIELD_DOWN_SECONDS = 45

local rivalBrainrots = {}
local shieldUp = true
local stealService = nil
local eventEvent = nil

-- A fake owner the steal code can treat like a player. GameState only ever
-- stores real players, so the rival keeps its own small table instead.
local rivalState = {
	plotName = "Rival",
	slots = {},
}

function RivalPlotService.init(remotes, services)
	stealService = services.StealService
	eventEvent = remotes.GameEvent
	for slot = 1, GameState.MAX_SLOTS do
		rivalState.slots[slot] = nil
	end
end

function RivalPlotService.populateSoloRivalPlot()
	RivalPlotService.clearRivalPlot()
	local picks = {
		{ id = "noobini", mutationName = "None", slot = 1 },
		{ id = "tralalero", mutationName = "Golden", slot = 2 },
		{ id = "graipuss", mutationName = "Diamond", slot = 3 },
	}
	for _, pick in ipairs(picks) do
		local def = BrainrotCatalog.getBrainrotDefinition(pick.id)
		if def then
			local mutation = nil
			for _, entry in ipairs(BrainrotCatalog.MUTATIONS) do
				if entry.name == pick.mutationName then
					mutation = entry
					break
				end
			end
			local income = BrainrotCatalog.calculateBrainrotIncome(def, mutation, 1)
			local position = PlotLayout.getSlotRigPosition("Rival", pick.slot, def.scale)
			local model = BrainrotRenderer.buildBrainrotRig(def, mutation, position)
			BrainrotRenderer.attachOverheadBillboard(model, def, mutation, income, false)
			model.Parent = Workspace
			local brainrot = {
				def = def,
				mutation = mutation,
				cost = BrainrotCatalog.getBrainrotCost(def, mutation),
				income = income,
				model = model,
				owner = "RIVAL_BOT",
				rivalSlot = pick.slot,
			}
			rivalState.slots[pick.slot] = brainrot
			table.insert(rivalBrainrots, brainrot)
			local clicker = Instance.new("ClickDetector")
			clicker.Name = "RivalStealClickDetector"
			clicker.MaxActivationDistance = 40
			clicker.Parent = model.PrimaryPart
			clicker.MouseClick:Connect(function(player)
				RivalPlotService.handleStealFromRivalPlot(player, pick.slot)
			end)
		end
	end
	RivalPlotService.setShieldUp(true)
	RivalPlotService.startShieldCycle()
end

function RivalPlotService.clearRivalPlot()
	for _, brainrot in ipairs(rivalBrainrots) do
		if brainrot.model and brainrot.model.Parent then
			brainrot.model:Destroy()
		end
	end
	rivalBrainrots = {}
	for slot = 1, GameState.MAX_SLOTS do
		rivalState.slots[slot] = nil
	end
end

function RivalPlotService.setShieldUp(up)
	shieldUp = up
	local dome = Workspace:FindFirstChild("LockDome_Rival", true)
	if dome and dome:IsA("BasePart") then
		dome.Transparency = up and 0.55 or 1
	end
	local sign = Workspace:FindFirstChild("RivalShieldSign", true)
	if sign and sign:IsA("TextLabel") then
		sign.Text = up and "LOCK SHIELD: ON" or "LOCK SHIELD: OFF - STEAL NOW!"
	end
end

function RivalPlotService.isShieldUp()
	return shieldUp
end

function RivalPlotService.startShieldCycle()
	task.spawn(function()
		while true do
			task.wait(RivalPlotService.SHIELD_UP_SECONDS)
			RivalPlotService.setShieldUp(false)
			task.wait(RivalPlotService.SHIELD_DOWN_SECONDS)
			RivalPlotService.setShieldUp(true)
		end
	end)
end

function RivalPlotService.handleStealFromRivalPlot(player, slot)
	if RivalPlotService.isShieldUp() then
		if eventEvent then
			eventEvent:FireClient(player, "RIVAL LOCK SHIELD is up! Wait for it to drop!")
		end
		return false
	end
	local state = GameState.getPlayerState(player)
	if not state or state.carried ~= nil then
		return false
	end
	local brainrot = rivalState.slots[slot]
	if not brainrot then
		return false
	end
	rivalState.slots[slot] = nil
	for index, other in ipairs(rivalBrainrots) do
		if other == brainrot then
			table.remove(rivalBrainrots, index)
			break
		end
	end
	brainrot.originalOwner = "RIVAL_BOT"
	brainrot.originalSlot = slot
	brainrot.isRivalBrainrot = true
	state.carried = brainrot
	stealService.carryBrainrotAboveHead(player, brainrot.model)
	if eventEvent then
		eventEvent:FireClient(player, "STEALING FROM RIVAL! RETURN TO YOUR BASE! (" .. brainrot.def.name .. ")")
	end
	return true
end

-- A rival brainrot dropped or deposited stops being the rival's: on deposit
-- the thief owns it outright, so the rival never gets it back.
function RivalPlotService.restockRivalSlot(slot)
	local pool = { "tungtung", "patapim", "lirili", "boneca" }
	local id = pool[math.random(1, #pool)]
	local def = BrainrotCatalog.getBrainrotDefinition(id)
	if not def then
		return
	end
	local mutation = BrainrotCatalog.rollMutationModifier()
	local income = BrainrotCatalog.calculateBrainrotIncome(def, mutation, 1)
	local position = PlotLayout.getSlotRigPosition("Rival", slot, def.scale)
	local model = BrainrotRenderer.buildBrainrotRig(def, mutation, position)
	BrainrotRenderer.attachOverheadBillboard(model, def, mutation, income, false)
	model.Parent = Workspace
	local brainrot = {
		def = def,
		mutation = mutation,
		cost = BrainrotCatalog.getBrainrotCost(def, mutation),
		income = income,
		model = model,
		owner = "RIVAL_BOT",
		rivalSlot = slot,
	}
	rivalState.slots[slot] = brainrot
	table.insert(rivalBrainrots, brainrot)
	local clicker = Instance.new("ClickDetector")
	clicker.Name = "RivalStealClickDetector"
	clicker.MaxActivationDistance = 40
	clicker.Parent = model.PrimaryPart
	clicker.MouseClick:Connect(function(player)
		RivalPlotService.handleStealFromRivalPlot(player, slot)
	end)
end

return RivalPlotService
