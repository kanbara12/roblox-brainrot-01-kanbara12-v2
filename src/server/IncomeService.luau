-- IncomeService: money ticks up every second for every brainrot on a base.
-- One loop, one job: compute each player's $/s, pay it, tell the client so
-- the HUD and the floating +$ popups can show it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local GameState = require(script.Parent.GameState)

local IncomeService = {}

IncomeService.TICK_SECONDS = 1

local incomeEvent = nil

function IncomeService.init(remotes)
	incomeEvent = remotes.IncomeTick
end

function IncomeService.computePlayerIncomePerSecond(player)
	local state = GameState.getPlayerState(player)
	if not state then
		return 0
	end
	local multiplier = GameState.getRebirthMultiplier(player)
	local total = 0
	for _, brainrot in pairs(state.slots) do
		if brainrot then
			total = total + BrainrotCatalog.calculateBrainrotIncome(brainrot.def, brainrot.mutation, multiplier)
		end
	end
	return total
end

function IncomeService.tickAllPlayerIncome()
	for player, _ in pairs(GameState.getAllPlayerStates()) do
		local perSecond = IncomeService.computePlayerIncomePerSecond(player)
		if perSecond > 0 then
			local cash = GameState.addCash(player, perSecond)
			if incomeEvent then
				incomeEvent:FireClient(player, cash, perSecond)
			end
		else
			local state = GameState.getPlayerState(player)
			if state and incomeEvent then
				incomeEvent:FireClient(player, state.cash, 0)
			end
		end
	end
end

function IncomeService.startIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(IncomeService.TICK_SECONDS)
			IncomeService.tickAllPlayerIncome()
		end
	end)
end

return IncomeService
