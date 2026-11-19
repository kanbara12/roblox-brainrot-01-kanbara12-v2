-- HudController: everything the player reads and presses. One module, one
-- job: build the ScreenGui, show cash and income, list the base slots, open
-- the rarity catalog, flash event banners. It never owns state; it renders
-- what the server tells it and asks the server for every action.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local BrainrotRenderer = require(ReplicatedStorage.Shared.BrainrotRenderer)

local HudController = {}

local player = Players.LocalPlayer
local remotes = nil
local gui = nil
local cashLabel = nil
local rebirthBadge = nil
local eventBanner = nil
local stealBanner = nil
local slotsPanel = nil
local catalogModal = nil
local lockButton = nil
local rebirthButton = nil
local slapButton = nil
local catalogButton = nil

local function makeButton(name, text, position, size, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = gui
	return button
end

function HudController.buildHud()
	gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBayGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false

	-- Cash readout: top RIGHT, clear of Roblox's top-left menu buttons.
	cashLabel = Instance.new("TextLabel")
	cashLabel.Name = "CashLabel"
	cashLabel.AnchorPoint = Vector2.new(1, 0)
	cashLabel.Position = UDim2.new(1, -16, 0, 16)
	cashLabel.Size = UDim2.fromOffset(360, 52)
	cashLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
	cashLabel.BackgroundTransparency = 0.25
	cashLabel.Text = "$100 (+$0/s)"
	cashLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	cashLabel.TextStrokeTransparency = 0
	cashLabel.TextSize = 28
	cashLabel.Font = Enum.Font.GothamBlack
	cashLabel.Parent = gui

	rebirthBadge = Instance.new("TextLabel")
	rebirthBadge.Name = "RebirthBadge"
	rebirthBadge.AnchorPoint = Vector2.new(1, 0)
	rebirthBadge.Position = UDim2.new(1, -16, 0, 74)
	rebirthBadge.Size = UDim2.fromOffset(360, 30)
	rebirthBadge.BackgroundTransparency = 1
	rebirthBadge.Text = ""
	rebirthBadge.TextColor3 = Color3.fromRGB(255, 215, 0)
	rebirthBadge.TextStrokeTransparency = 0
	rebirthBadge.TextSize = 20
	rebirthBadge.Font = Enum.Font.GothamBold
	rebirthBadge.Parent = gui

	-- Event banner: center top, big enough to read at a glance.
	eventBanner = Instance.new("TextLabel")
	eventBanner.Name = "EventBanner"
	eventBanner.AnchorPoint = Vector2.new(0.5, 0)
	eventBanner.Position = UDim2.new(0.5, 0, 0, 80)
	eventBanner.Size = UDim2.fromOffset(700, 56)
	eventBanner.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
	eventBanner.BackgroundTransparency = 0.2
	eventBanner.Text = ""
	eventBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
	eventBanner.TextStrokeTransparency = 0
	eventBanner.TextSize = 26
	eventBanner.Font = Enum.Font.GothamBlack
	eventBanner.Visible = false
	eventBanner.Parent = gui

	stealBanner = Instance.new("TextLabel")
	stealBanner.Name = "StealBanner"
	stealBanner.AnchorPoint = Vector2.new(0.5, 0)
	stealBanner.Position = UDim2.new(0.5, 0, 0, 144)
	stealBanner.Size = UDim2.fromOffset(700, 44)
	stealBanner.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
	stealBanner.BackgroundTransparency = 0.2
	stealBanner.Text = ""
	stealBanner.TextColor3 = Color3.fromRGB(255, 230, 120)
	stealBanner.TextStrokeTransparency = 0
	stealBanner.TextSize = 24
	stealBanner.Font = Enum.Font.GothamBlack
	stealBanner.Visible = false
	stealBanner.Parent = gui

	-- Base slots panel: left middle, 8 numbered rows.
	slotsPanel = Instance.new("Frame")
	slotsPanel.Name = "BaseSlotsPanel"
	slotsPanel.Position = UDim2.new(0, 16, 0.5, -160)
	slotsPanel.Size = UDim2.fromOffset(300, 320)
	slotsPanel.BackgroundColor3 = Color3.fromRGB(15, 25, 40)
	slotsPanel.BackgroundTransparency = 0.2
	slotsPanel.Parent = gui
	local slotsTitle = Instance.new("TextLabel")
	slotsTitle.Name = "SlotsTitle"
	slotsTitle.Size = UDim2.new(1, 0, 0, 36)
	slotsTitle.BackgroundTransparency = 1
	slotsTitle.Text = "MY BASE  (8 SLOTS)"
	slotsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	slotsTitle.TextSize = 20
	slotsTitle.Font = Enum.Font.GothamBlack
	slotsTitle.Parent = slotsPanel
	for slot = 1, 8 do
		local row = Instance.new("TextLabel")
		row.Name = "SlotRow" .. tostring(slot)
		row.Position = UDim2.new(0, 8, 0, 36 + (slot - 1) * 34)
		row.Size = UDim2.new(1, -16, 0, 30)
		row.BackgroundTransparency = 1
		row.Text = tostring(slot) .. ".  --- empty ---"
		row.TextColor3 = Color3.fromRGB(200, 200, 200)
		row.TextSize = 16
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Font = Enum.Font.GothamBold
		row.Parent = slotsPanel
	end

	-- Bottom-center action buttons.
	lockButton = makeButton("LockButton", "LOCK BASE (30s)", UDim2.new(0.5, -330, 1, -76),
		UDim2.fromOffset(200, 56), Color3.fromRGB(40, 120, 200))
	rebirthButton = makeButton("RebirthButton", "REBIRTH ($50,000)", UDim2.new(0.5, -110, 1, -76),
		UDim2.fromOffset(220, 56), Color3.fromRGB(180, 140, 0))
	slapButton = makeButton("SlapButton", "SLAP [E]", UDim2.new(0.5, 130, 1, -76),
		UDim2.fromOffset(140, 56), Color3.fromRGB(200, 60, 60))
	catalogButton = makeButton("CatalogButton", "BRAINROT INDEX", UDim2.new(0.5, 290, 1, -76),
		UDim2.fromOffset(200, 56), Color3.fromRGB(90, 60, 160))

	catalogModal = Instance.new("Frame")
	catalogModal.Name = "RarityCatalogModal"
	catalogModal.AnchorPoint = Vector2.new(0.5, 0.5)
	catalogModal.Position = UDim2.fromScale(0.5, 0.5)
	catalogModal.Size = UDim2.fromOffset(560, 460)
	catalogModal.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
	catalogModal.Visible = false
	catalogModal.Parent = gui
	HudController.renderRarityCatalogModal()

	gui.Parent = player:WaitForChild("PlayerGui")
end

function HudController.updateCashDisplay(cash, perSecond)
	if cashLabel then
		cashLabel.Text = "$" .. tostring(cash) .. " (+$" .. tostring(perSecond) .. "/s)"
	end
end

function HudController.updateRebirthBadge(rebirths)
	if rebirthBadge then
		if rebirths > 0 then
			rebirthBadge.Text = "REBIRTH x" .. tostring(rebirths) .. "  |  Income x" .. tostring(2 ^ rebirths)
		else
			rebirthBadge.Text = ""
		end
	end
end

-- Reads the player's own base straight from the world: every bought rig
-- carries a billboard that says "YOURS | SLOT n".
function HudController.renderBaseSlots()
	if not slotsPanel then
		return
	end
	local owned = {}
	local folder = Workspace:FindFirstChild("ConveyorBrainrots")
	if folder then
		for _, model in ipairs(folder:GetChildren()) do
			if model:IsA("Model") then
				local billboard = model:FindFirstChild("OverheadBillboard", true)
				if billboard then
					local costLabel = billboard:FindFirstChild("CostLabel")
					local nameLabel = billboard:FindFirstChild("BrainrotName")
					local incomeLabel = billboard:FindFirstChild("IncomeLabel")
					if costLabel and nameLabel and incomeLabel then
						local slot = string.match(costLabel.Text, "SLOT (%d+)")
						if slot then
							owned[tonumber(slot)] = nameLabel.Text .. "  " .. incomeLabel.Text
						end
					end
				end
			end
		end
	end
	for slot = 1, 8 do
		local row = slotsPanel:FindFirstChild("SlotRow" .. tostring(slot))
		if row then
			if owned[slot] then
				row.Text = tostring(slot) .. ".  " .. owned[slot]
				row.TextColor3 = Color3.fromRGB(140, 255, 140)
			else
				row.Text = tostring(slot) .. ".  --- empty ---"
				row.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end
	end
end

function HudController.renderRarityCatalogModal()
	if not catalogModal then
		return
	end
	local title = Instance.new("TextLabel")
	title.Name = "CatalogTitle"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "BRAINROT INDEX  —  15 characters, 7 rarities"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBlack
	title.Parent = catalogModal
	local y = 48
	for _, def in ipairs(BrainrotCatalog.DEFINITIONS) do
		local row = Instance.new("TextLabel")
		row.Name = "CatalogRow_" .. def.id
		row.Position = UDim2.new(0, 12, 0, y)
		row.Size = UDim2.new(1, -24, 0, 24)
		row.BackgroundTransparency = 1
		row.Text = def.name .. "  [" .. string.upper(def.rarity) .. "]  $" .. tostring(def.cost) .. "  +$" .. tostring(def.income) .. "/s"
		row.TextColor3 = BrainrotCatalog.getRarityColor(def.rarity)
		row.TextSize = 15
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Font = Enum.Font.GothamBold
		row.Parent = catalogModal
		y = y + 26
	end
	local footer = Instance.new("TextLabel")
	footer.Name = "CatalogFooter"
	footer.Position = UDim2.new(0, 12, 0, y + 4)
	footer.Size = UDim2.new(1, -24, 0, 24)
	footer.BackgroundTransparency = 1
	footer.Text = "Mutations: Golden x2  |  Diamond x5  |  Rainbow x10"
	footer.TextColor3 = Color3.fromRGB(255, 215, 0)
	footer.TextSize = 15
	footer.Font = Enum.Font.GothamBold
	footer.Parent = catalogModal
end

function HudController.showEventBanner(message, seconds)
	if not eventBanner then
		return
	end
	eventBanner.Text = message
	eventBanner.Visible = true
	task.delay(seconds or 6, function()
		eventBanner.Visible = false
	end)
end

function HudController.showStealBanner(message, seconds)
	if not stealBanner then
		return
	end
	stealBanner.Text = message
	stealBanner.Visible = true
	task.delay(seconds or 5, function()
		stealBanner.Visible = false
	end)
end

function HudController.bindButtons(remoteTable)
	remotes = remoteTable
	lockButton.MouseButton1Click:Connect(function()
		remotes.ActivateLock:FireServer()
	end)
	rebirthButton.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)
	slapButton.MouseButton1Click:Connect(function()
		remotes.SlapPlayer:FireServer()
	end)
	catalogButton.MouseButton1Click:Connect(function()
		catalogModal.Visible = not catalogModal.Visible
	end)
	ContextActionService:BindAction("BrainrotSlap", function(_, state)
		if state == Enum.UserInputState.Begin then
			remotes.SlapPlayer:FireServer()
		end
	end, false, Enum.KeyCode.E)
	ContextActionService:BindAction("BrainrotLock", function(_, state)
		if state == Enum.UserInputState.Begin then
			remotes.ActivateLock:FireServer()
		end
	end, false, Enum.KeyCode.L)
end

function HudController.listenToServer(remoteTable)
	remotes = remoteTable
	remotes.IncomeTick.OnClientEvent:Connect(function(cash, perSecond)
		HudController.updateCashDisplay(cash, perSecond)
		if perSecond > 0 then
			local folder = Workspace:FindFirstChild("ConveyorBrainrots")
			if folder then
				for _, model in ipairs(folder:GetChildren()) do
					if model:IsA("Model") then
						local billboard = model:FindFirstChild("OverheadBillboard", true)
						if billboard then
							local costLabel = billboard:FindFirstChild("CostLabel")
							if costLabel and string.find(costLabel.Text, "YOURS", 1, true) then
								BrainrotRenderer.spawnCashTickPopup(model, perSecond)
								break
							end
						end
					end
				end
			end
		end
	end)
	remotes.GameEvent.OnClientEvent:Connect(function(message)
		HudController.showEventBanner(message, 6)
	end)
	remotes.StealBrainrot.OnClientEvent:Connect(function(message)
		HudController.showStealBanner(message, 5)
	end)
	remotes.SlapPlayer.OnClientEvent:Connect(function(message)
		HudController.showStealBanner(message, 4)
	end)
	remotes.ActivateLock.OnClientEvent:Connect(function(message)
		HudController.showStealBanner(message, 4)
	end)
	remotes.Rebirth.OnClientEvent:Connect(function(message)
		HudController.showEventBanner(message, 6)
		local count = string.match(message, "REBIRTH (%d+)")
		if count then
			HudController.updateRebirthBadge(tonumber(count))
		end
	end)
	task.spawn(function()
		while true do
			task.wait(2)
			HudController.renderBaseSlots()
		end
	end)
	-- Rainbow rigs cycle their hue every frame.
	RunService.RenderStepped:Connect(function()
		local now = os.clock()
		for _, folder in ipairs({ Workspace:FindFirstChild("ConveyorBrainrots"), Workspace }) do
			if folder then
				for _, model in ipairs(folder:GetChildren()) do
					if model:IsA("Model") then
						BrainrotRenderer.cycleRainbowLight(model, now)
					end
				end
			end
		end
	end)
end

return HudController
