-- RebirthService: trade everything for a permanent x2 income multiplier.
-- Cash and brainrots reset; the multiplier and the golden aura stay forever.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = require(script.Parent.GameState)

local RebirthService = {}

RebirthService.REBIRTH_CASH_COST = 50000
RebirthService.MAX_REBIRTHS = 10

local rebirthEvent = nil

function RebirthService.init(remotes)
	rebirthEvent = remotes.Rebirth
	rebirthEvent.OnServerEvent:Connect(function(player)
		RebirthService.performPlayerRebirth(player)
	end)
end

function RebirthService.canPlayerRebirth(player)
	local state = GameState.getPlayerState(player)
	if not state then
		return false, "no state"
	end
	if state.rebirths >= RebirthService.MAX_REBIRTHS then
		return false, "max rebirths reached"
	end
	if state.cash < RebirthService.REBIRTH_CASH_COST then
		return false, "need $" .. tostring(RebirthService.REBIRTH_CASH_COST)
	end
	return true, "ready"
end

function RebirthService.performPlayerRebirth(player)
	local can, reason = RebirthService.canPlayerRebirth(player)
	if not can then
		return false, reason
	end
	local state = GameState.getPlayerState(player)
	for slot = 1, GameState.MAX_SLOTS do
		local brainrot = GameState.clearBaseSlot(player, slot)
		if brainrot and brainrot.model and brainrot.model.Parent then
			brainrot.model:Destroy()
		end
	end
	if state.carried and state.carried.model and state.carried.model.Parent then
		state.carried.model:Destroy()
	end
	state.carried = nil
	state.cash = GameState.STARTING_CASH
	local count = GameState.incrementRebirth(player)
	RebirthService.applyRebirthAura(player)
	if rebirthEvent then
		rebirthEvent:FireClient(player, "REBIRTH " .. tostring(count) .. "! Income x" .. tostring(2 ^ count) .. " forever!")
	end
	return true, "rebirth " .. tostring(count)
end

function RebirthService.applyRebirthAura(player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local old = root:FindFirstChild("RebirthAura")
	if old then
		old:Destroy()
	end
	local sparkles = Instance.new("Sparkles")
	sparkles.Name = "RebirthAura"
	sparkles.SparkleColor = Color3.fromRGB(255, 215, 0)
	sparkles.Parent = root
	local light = Instance.new("PointLight")
	light.Name = "RebirthLight"
	light.Color = Color3.fromRGB(255, 215, 0)
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = root
end

return RebirthService
