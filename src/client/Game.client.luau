-- BRAINROT BAY — client entry point.
-- Builds the HUD, binds the buttons and keys, listens to the server.
-- The client renders and asks; the server decides everything.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HudController = require(script.HudController)

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("BrainrotRemotes")

local remotes = {
	BuyBrainrot = remotesFolder:WaitForChild("BuyBrainrot"),
	StealBrainrot = remotesFolder:WaitForChild("StealBrainrot"),
	SlapPlayer = remotesFolder:WaitForChild("SlapPlayer"),
	ActivateLock = remotesFolder:WaitForChild("ActivateLock"),
	Rebirth = remotesFolder:WaitForChild("Rebirth"),
	IncomeTick = remotesFolder:WaitForChild("IncomeTick"),
	GameEvent = remotesFolder:WaitForChild("GameEvent"),
}

HudController.buildHud()
HudController.bindButtons(remotes)
HudController.listenToServer(remotes)

print("BRAINROT BAY client ready for " .. player.Name)
