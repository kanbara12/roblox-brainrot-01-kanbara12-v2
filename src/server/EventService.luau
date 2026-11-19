-- EventService: the world fights back on a timer. A tsunami wave sweeps the
-- island every few minutes (high ground saves you and your stolen brainrot),
-- and Golden Hour doubles the odds of Rare and better spawns for 60 seconds.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local GameState = require(script.Parent.GameState)
local PlotLayout = require(ReplicatedStorage.Shared.PlotLayout)

local EventService = {}

EventService.EVENT_INTERVAL = 170
EventService.TSUNAMI_WARNING_SECONDS = 10
EventService.GOLDEN_HOUR_SECONDS = 60

local eventEvent = nil
local conveyorService = nil
local stealService = nil
local goldenHourUntil = 0
local nextEventIsTsunami = true

function EventService.init(remotes, services)
	eventEvent = remotes.GameEvent
	conveyorService = services.ConveyorService
	stealService = services.StealService
end

function EventService.isGoldenHourActive()
	return os.clock() < goldenHourUntil
end

function EventService.getGoldenHourRarityWeights()
	return BrainrotCatalog.getGoldenHourRarityWeights()
end

function EventService.announce(message)
	if eventEvent then
		eventEvent:FireAllClients(message)
	end
end

function EventService.isPlayerOnHighGround(player)
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	return PlotLayout.isPositionOnHighGround(root.Position)
end

function EventService.sweepExposedCarriedBrainrots()
	for player, state in pairs(GameState.getAllPlayerStates()) do
		if state.carried ~= nil and not EventService.isPlayerOnHighGround(player) then
			stealService.dropCarriedBrainrot(player, true)
			if eventEvent then
				eventEvent:FireClient(player, "TSUNAMI took your stolen brainrot! Get to HIGH GROUND next time!")
			end
		end
	end
end

function EventService.triggerTsunamiWave()
	EventService.announce("TSUNAMI WAVE! GET TO HIGH GROUND! (10s)")
	task.wait(EventService.TSUNAMI_WARNING_SECONDS)
	local wave = Workspace:FindFirstChild("TsunamiWave")
	if wave and wave:IsA("BasePart") then
		wave.Transparency = 0.35
		local tween = TweenService:Create(wave, TweenInfo.new(8, Enum.EasingStyle.Linear),
			{ CFrame = CFrame.new(0, 6, 120) })
		tween:Play()
		EventService.sweepExposedCarriedBrainrots()
		tween.Completed:Wait()
		task.wait(2)
		wave.Transparency = 1
		wave.CFrame = CFrame.new(0, 6, -140)
	else
		EventService.sweepExposedCarriedBrainrots()
	end
	EventService.announce("The wave passed. The bay is calm... for now.")
end

function EventService.triggerGoldenHour()
	goldenHourUntil = os.clock() + EventService.GOLDEN_HOUR_SECONDS
	if conveyorService then
		conveyorService.setGoldenHourActive(true)
	end
	Lighting.ClockTime = 17.5
	Lighting.Brightness = 2.5
	EventService.announce("GOLDEN HOUR! 2x chance of Rare+ brainrots for 60 seconds!")
	task.wait(EventService.GOLDEN_HOUR_SECONDS)
	goldenHourUntil = 0
	if conveyorService then
		conveyorService.setGoldenHourActive(false)
	end
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	EventService.announce("Golden Hour is over.")
end

function EventService.startEventScheduler()
	task.spawn(function()
		task.wait(90)
		while true do
			if nextEventIsTsunami then
				EventService.triggerTsunamiWave()
			else
				EventService.triggerGoldenHour()
			end
			nextEventIsTsunami = not nextEventIsTsunami
			task.wait(EventService.EVENT_INTERVAL)
		end
	end)
end

return EventService
