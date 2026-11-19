-- GameState: the ONE place server state lives. Every service reads and writes
-- through these functions; no other module keeps its own copy of cash, slots,
-- locks or rebirths. The client never owns state, it only renders it.

local GameState = {}

GameState.STARTING_CASH = 100
GameState.MAX_SLOTS = 8
GameState.BASE_LOCK_SECONDS = 30
GameState.BASE_LOCK_COOLDOWN = 60

local playerStates = {}

function GameState.initPlayerState(player, plotName)
	local state = {
		player = player,
		plotName = plotName,
		cash = GameState.STARTING_CASH,
		rebirths = 0,
		baseLockUntil = 0,
		baseLockCooldownUntil = 0,
		slots = {},
		carried = nil,
		slapCooldownUntil = 0,
	}
	for slot = 1, GameState.MAX_SLOTS do
		state.slots[slot] = nil
	end
	playerStates[player] = state
	return state
end

function GameState.removePlayerState(player)
	playerStates[player] = nil
end

function GameState.getPlayerState(player)
	return playerStates[player]
end

function GameState.getCash(player)
	local state = playerStates[player]
	if not state then
		return 0
	end
	return state.cash
end

function GameState.addCash(player, amount)
	local state = playerStates[player]
	if not state then
		return 0
	end
	state.cash = state.cash + amount
	return state.cash
end

function GameState.spendCash(player, amount)
	local state = playerStates[player]
	if not state then
		return false
	end
	if state.cash < amount then
		return false
	end
	state.cash = state.cash - amount
	return true
end

function GameState.getRebirthMultiplier(player)
	local state = playerStates[player]
	if not state then
		return 1
	end
	return 2 ^ state.rebirths
end

function GameState.incrementRebirth(player)
	local state = playerStates[player]
	if not state then
		return 0
	end
	state.rebirths = state.rebirths + 1
	return state.rebirths
end

function GameState.findFreeSlot(player)
	local state = playerStates[player]
	if not state then
		return nil
	end
	for slot = 1, GameState.MAX_SLOTS do
		if state.slots[slot] == nil then
			return slot
		end
	end
	return nil
end

function GameState.assignBrainrotToSlot(player, slot, brainrot)
	local state = playerStates[player]
	if not state then
		return false
	end
	if slot < 1 or slot > GameState.MAX_SLOTS then
		return false
	end
	if state.slots[slot] ~= nil then
		return false
	end
	state.slots[slot] = brainrot
	return true
end

function GameState.clearBaseSlot(player, slot)
	local state = playerStates[player]
	if not state then
		return nil
	end
	local brainrot = state.slots[slot]
	state.slots[slot] = nil
	return brainrot
end

function GameState.getSlotBrainrot(player, slot)
	local state = playerStates[player]
	if not state then
		return nil
	end
	return state.slots[slot]
end

function GameState.setBaseLockUntil(player, untilTime)
	local state = playerStates[player]
	if not state then
		return
	end
	state.baseLockUntil = untilTime
	state.baseLockCooldownUntil = untilTime + GameState.BASE_LOCK_COOLDOWN
end

function GameState.isBaseLocked(player, now)
	local state = playerStates[player]
	if not state then
		return false
	end
	return now < state.baseLockUntil
end

function GameState.getBaseLockRemaining(player, now)
	local state = playerStates[player]
	if not state then
		return 0
	end
	return math.max(0, state.baseLockUntil - now)
end

function GameState.getBaseLockCooldownRemaining(player, now)
	local state = playerStates[player]
	if not state then
		return 0
	end
	return math.max(0, state.baseLockCooldownUntil - now)
end

function GameState.getAllPlayerStates()
	return playerStates
end

return GameState
