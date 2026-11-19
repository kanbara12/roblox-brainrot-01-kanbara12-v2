-- BRAINROT BAY — server entry point.
-- Wires the remotes, assigns plots, starts the conveyor, the income loop,
-- the events and the solo rival plot. No game logic lives here; every
-- mechanic belongs to its own module.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameState = require(script.GameState)
local ConveyorService = require(script.ConveyorService)
local IncomeService = require(script.IncomeService)
local StealService = require(script.StealService)
local RebirthService = require(script.RebirthService)
local EventService = require(script.EventService)
local RivalPlotService = require(script.RivalPlotService)

-- RemoteEvents, one per player action. The client only ever asks; the
-- server decides.
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "BrainrotRemotes"
remotesFolder.Parent = ReplicatedStorage

local function makeRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local remotes = {
	BuyBrainrot = makeRemote("BuyBrainrot"),
	StealBrainrot = makeRemote("StealBrainrot"),
	SlapPlayer = makeRemote("SlapPlayer"),
	ActivateLock = makeRemote("ActivateLock"),
	Rebirth = makeRemote("Rebirth"),
	IncomeTick = makeRemote("IncomeTick"),
	GameEvent = makeRemote("GameEvent"),
}

local services = {
	ConveyorService = ConveyorService,
	StealService = StealService,
}

ConveyorService.init(remotes)
IncomeService.init(remotes)
StealService.init(remotes)
RebirthService.init(remotes)
EventService.init(remotes, services)
RivalPlotService.init(remotes, services)

local plotAssignment = {}
local nextPlot = 1
local plotNames = { "PlotA", "PlotB" }

local function assignPlotToPlayer(player)
	local plotName = plotNames[nextPlot]
	nextPlot = nextPlot + 1
	if nextPlot > #plotNames then
		nextPlot = 1
	end
	plotAssignment[player] = plotName
	return plotName
end

-- Walking onto your own base pad while carrying deposits the steal.
local function wireBasePadDeposit(plotName)
	local pad = Workspace:FindFirstChild("BasePad_" .. plotName, true)
	if pad and pad:IsA("BasePart") then
		pad.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end
			local state = GameState.getPlayerState(player)
			if state and state.plotName == plotName and state.carried ~= nil then
				StealService.completeStealDeposit(player)
			end
		end)
	end
end

wireBasePadDeposit("PlotA")
wireBasePadDeposit("PlotB")

local function onPlayerAdded(player)
	local plotName = assignPlotToPlayer(player)
	GameState.initPlayerState(player, plotName)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		local state = GameState.getPlayerState(player)
		if state and state.rebirths > 0 then
			RebirthService.applyRebirthAura(player)
		end
	end)
end

local function onPlayerRemoving(player)
	local state = GameState.getPlayerState(player)
	if state and state.carried ~= nil then
		StealService.dropCarriedBrainrot(player, true)
	end
	GameState.removePlayerState(player)
	plotAssignment[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

RivalPlotService.populateSoloRivalPlot()
ConveyorService.startConveyorLoop()
IncomeService.startIncomeLoop()
EventService.startEventScheduler()

task.spawn(function()
	while true do
		task.wait(5)
		StealService.expireBaseLocks()
	end
end)

print("BRAINROT BAY server ready: conveyor, income, steal, rebirth, events, rival plot live.")
