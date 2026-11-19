-- StealService: the tension. Click a brainrot on someone else's base, carry
-- it home over your head, and deposit it on your own base. A slap drops what
-- you carry; a locked base cannot be stolen from at all.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameState = require(script.Parent.GameState)
local PlotLayout = require(ReplicatedStorage.Shared.PlotLayout)

local StealService = {}

StealService.SLAP_RANGE = 10
StealService.SLAP_COOLDOWN = 3
StealService.CARRY_RETURN_SECONDS = 10

local stealEvent = nil
local slapEvent = nil
local lockEvent = nil

function StealService.init(remotes)
	stealEvent = remotes.StealBrainrot
	slapEvent = remotes.SlapPlayer
	lockEvent = remotes.ActivateLock
	stealEvent.OnServerEvent:Connect(function(player, ownerUserId, slot)
		local owner = Players:GetPlayerByUserId(ownerUserId)
		if owner then
			StealService.startStealBrainrot(player, owner, slot)
		end
	end)
	slapEvent.OnServerEvent:Connect(function(player)
		StealService.handleSlapPlayer(player)
	end)
	lockEvent.OnServerEvent:Connect(function(player)
		StealService.activateBaseLock(player)
	end)
end

-- Clicking a base brainrot is how a steal starts; the detector is attached
-- when the brainrot lands on a base (conveyor buys and rival spawns alike).
function StealService.attachStealClickDetector(owner, slot, model)
	local clicker = Instance.new("ClickDetector")
	clicker.Name = "StealClickDetector"
	clicker.MaxActivationDistance = 40
	clicker.Parent = model.PrimaryPart
	clicker.MouseClick:Connect(function(player)
		if player == owner then
			return
		end
		StealService.startStealBrainrot(player, owner, slot)
	end)
end

function StealService.startStealBrainrot(thief, owner, slot)
	local thiefState = GameState.getPlayerState(thief)
	local ownerState = GameState.getPlayerState(owner)
	if not thiefState or not ownerState then
		return false
	end
	if thiefState.carried ~= nil then
		return false
	end
	if GameState.isBaseLocked(owner, os.clock()) then
		return false
	end
	local brainrot = GameState.getSlotBrainrot(owner, slot)
	if not brainrot then
		return false
	end
	GameState.clearBaseSlot(owner, slot)
	brainrot.originalOwner = owner
	brainrot.originalSlot = slot
	thiefState.carried = brainrot
	StealService.carryBrainrotAboveHead(thief, brainrot.model)
	if stealEvent then
		stealEvent:FireClient(thief, "STEALING! RETURN TO YOUR BASE!", brainrot.def.name)
	end
	return true
end

function StealService.carryBrainrotAboveHead(player, model)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			if part ~= model.PrimaryPart then
				local weld = Instance.new("WeldConstraint")
				weld.Name = "CarryWeld"
				weld.Part0 = part
				weld.Part1 = model.PrimaryPart
				weld.Parent = part
			end
		end
	end
	model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 4, 0)))
	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = model.PrimaryPart
	weld.Part1 = root
	weld.Parent = model.PrimaryPart
end

-- The thief deposits by walking onto their own base pad; init.server wires
-- each base pad's Touched event to this.
function StealService.completeStealDeposit(player)
	local state = GameState.getPlayerState(player)
	if not state or not state.carried then
		return false
	end
	local slot = GameState.findFreeSlot(player)
	if not slot then
		return false
	end
	local brainrot = state.carried
	state.carried = nil
	local model = brainrot.model
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant.Name == "CarryWeld" then
			descendant:Destroy()
		end
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	local target = PlotLayout.getSlotRigPosition(state.plotName, slot, brainrot.def.scale)
	model:PivotTo(CFrame.new(target))
	brainrot.owner = player
	if not GameState.assignBrainrotToSlot(player, slot, brainrot) then
		return false
	end
	if brainrot.isRivalBrainrot then
		local RivalPlotService = require(script.Parent.RivalPlotService)
		local restockSlot = brainrot.originalSlot
		task.delay(20, function()
			RivalPlotService.restockRivalSlot(restockSlot)
		end)
	end
	if stealEvent then
		stealEvent:FireClient(player, "STOLEN! +" .. brainrot.def.name, brainrot.def.name)
	end
	return true
end

function StealService.dropCarriedBrainrot(player, returnToOwner)
	local state = GameState.getPlayerState(player)
	if not state or not state.carried then
		return false
	end
	local brainrot = state.carried
	state.carried = nil
	local model = brainrot.model
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant.Name == "CarryWeld" then
			descendant:Destroy()
		end
	end
	local character = player.Character
	local dropPos = Vector3.new(0, 4, 0)
	if character and character:FindFirstChild("HumanoidRootPart") then
		dropPos = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	model:PivotTo(CFrame.new(dropPos))
	if returnToOwner and brainrot.originalOwner then
		local owner = brainrot.originalOwner
		local ownerState = GameState.getPlayerState(owner)
		task.delay(StealService.CARRY_RETURN_SECONDS, function()
			if not model.Parent then
				return
			end
			if brainrot.isRivalBrainrot then
				model:Destroy()
				local RivalPlotService = require(script.Parent.RivalPlotService)
				RivalPlotService.restockRivalSlot(brainrot.originalSlot)
			elseif ownerState and GameState.getSlotBrainrot(owner, brainrot.originalSlot) == nil then
				local target = PlotLayout.getSlotRigPosition(ownerState.plotName, brainrot.originalSlot, brainrot.def.scale)
				model:PivotTo(CFrame.new(target))
				brainrot.owner = owner
				GameState.assignBrainrotToSlot(owner, brainrot.originalSlot, brainrot)
			else
				model:Destroy()
			end
		end)
	end
	return true
end

function StealService.handleSlapPlayer(slapper)
	local state = GameState.getPlayerState(slapper)
	if not state then
		return false
	end
	if os.clock() < state.slapCooldownUntil then
		return false
	end
	state.slapCooldownUntil = os.clock() + StealService.SLAP_COOLDOWN
	local character = slapper.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return false
	end
	local myPos = character.HumanoidRootPart.Position
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= slapper then
			local otherState = GameState.getPlayerState(other)
			if otherState and otherState.carried ~= nil then
				local otherChar = other.Character
				if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
					local dist = (otherChar.HumanoidRootPart.Position - myPos).Magnitude
					if dist <= StealService.SLAP_RANGE then
						StealService.dropCarriedBrainrot(other, true)
						if slapEvent then
							slapEvent:FireClient(slapper, "SLAP! " .. other.DisplayName .. " dropped the brainrot!")
						end
						return true
					end
				end
			end
		end
	end
	return false
end

function StealService.activateBaseLock(player)
	local state = GameState.getPlayerState(player)
	if not state then
		return false
	end
	local now = os.clock()
	if GameState.getBaseLockCooldownRemaining(player, now) > 0 then
		return false
	end
	GameState.setBaseLockUntil(player, now + GameState.BASE_LOCK_SECONDS)
	StealService.showLockDome(state.plotName, true)
	task.delay(GameState.BASE_LOCK_SECONDS, function()
		StealService.showLockDome(state.plotName, false)
	end)
	if lockEvent then
		lockEvent:FireClient(player, "BASE LOCKED for " .. tostring(GameState.BASE_LOCK_SECONDS) .. "s!")
	end
	return true
end

function StealService.showLockDome(plotName, visible)
	local dome = Workspace:FindFirstChild("LockDome_" .. plotName, true)
	if dome and dome:IsA("BasePart") then
		dome.Transparency = visible and 0.55 or 1
	end
end

function StealService.expireBaseLocks()
	local now = os.clock()
	for player, state in pairs(GameState.getAllPlayerStates()) do
		if state.baseLockUntil > 0 and now >= state.baseLockUntil then
			state.baseLockUntil = 0
			StealService.showLockDome(state.plotName, false)
		end
	end
end

return StealService
