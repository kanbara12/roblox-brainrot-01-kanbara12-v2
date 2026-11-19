-- ConveyorService: moves brainrots along the belt and handles buys.
-- Brainrots roll out of the SPAWN GATE, walk the glowing conveyor, and
-- despawn at the EXIT portal unless a player clicks one and buys it
-- into a free base slot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local BrainrotRenderer = require(ReplicatedStorage.Shared.BrainrotRenderer)
local PlotLayout = require(ReplicatedStorage.Shared.PlotLayout)
local GameState = require(script.Parent.GameState)

local ConveyorService = {}

ConveyorService.SPAWN_X = -80
ConveyorService.DESPAWN_X = 80
ConveyorService.CONVEYOR_Y = 3.5
ConveyorService.CONVEYOR_Z = -40
ConveyorService.SPEED = 6
ConveyorService.SPAWN_INTERVAL = 7
ConveyorService.MAX_ON_BELT = 6

local conveyorBrainrots = {}
local conveyorFolder = nil
local buyEvent = nil
local lastSpawn = 0
local goldenHourActive = false

function ConveyorService.setGoldenHourActive(active)
	goldenHourActive = active
end

function ConveyorService.isGoldenHourActive()
	return goldenHourActive
end

function ConveyorService.init(remotes)
	conveyorFolder = Instance.new("Folder")
	conveyorFolder.Name = "ConveyorBrainrots"
	conveyorFolder.Parent = Workspace
	buyEvent = remotes.BuyBrainrot
	buyEvent.OnServerEvent:Connect(function(player, modelId)
		ConveyorService.handleBuyBrainrotRequest(player, modelId)
	end)
end

function ConveyorService.spawnConveyorBrainrot()
	if #conveyorBrainrots >= ConveyorService.MAX_ON_BELT then
		return nil
	end
	local def, mutation = BrainrotCatalog.rollBrainrot(goldenHourActive)
	local rigY = 2.5 + 2.0 * (def.scale or 1)
	local position = Vector3.new(ConveyorService.SPAWN_X, rigY, ConveyorService.CONVEYOR_Z)
	local model = BrainrotRenderer.buildBrainrotRig(def, mutation, position)
	local income = BrainrotCatalog.calculateBrainrotIncome(def, mutation, 1)
	BrainrotRenderer.attachOverheadBillboard(model, def, mutation, income, true)
	model.Name = def.id .. "_" .. tostring(math.random(1000, 9999))
	model.Parent = conveyorFolder

	local clicker = Instance.new("ClickDetector")
	clicker.Name = "BuyClickDetector"
	clicker.MaxActivationDistance = 40
	clicker.Parent = model.PrimaryPart
	clicker.MouseClick:Connect(function(player)
		ConveyorService.handleBuyBrainrotRequest(player, model.Name)
	end)

	local record = {
		model = model,
		def = def,
		mutation = mutation,
		cost = BrainrotCatalog.getBrainrotCost(def, mutation),
		income = income,
		rigY = rigY,
	}
	table.insert(conveyorBrainrots, record)
	return record
end

function ConveyorService.stepConveyorMovement(dt)
	for index = #conveyorBrainrots, 1, -1 do
		local record = conveyorBrainrots[index]
		local model = record.model
		if not model or not model.Parent then
			table.remove(conveyorBrainrots, index)
		else
			local primary = model.PrimaryPart
			if primary then
				local newX = primary.Position.X + ConveyorService.SPEED * dt
				model:PivotTo(CFrame.new(newX, record.rigY or ConveyorService.CONVEYOR_Y, ConveyorService.CONVEYOR_Z))
				if newX >= ConveyorService.DESPAWN_X then
					ConveyorService.despawnConveyorBrainrot(record)
				end
			end
		end
	end
end

function ConveyorService.despawnConveyorBrainrot(record)
	for index, other in ipairs(conveyorBrainrots) do
		if other == record then
			table.remove(conveyorBrainrots, index)
			break
		end
	end
	if record.model and record.model.Parent then
		record.model:Destroy()
	end
end

function ConveyorService.findConveyorBrainrot(modelId)
	for _, record in ipairs(conveyorBrainrots) do
		if record.model and record.model.Name == modelId then
			return record
		end
	end
	return nil
end

function ConveyorService.handleBuyBrainrotRequest(player, modelId)
	local record = ConveyorService.findConveyorBrainrot(modelId)
	if not record then
		return false
	end
	local state = GameState.getPlayerState(player)
	if not state then
		return false
	end
	local slot = GameState.findFreeSlot(player)
	if not slot then
		return false
	end
	if not GameState.spendCash(player, record.cost) then
		return false
	end
	for index, other in ipairs(conveyorBrainrots) do
		if other == record then
			table.remove(conveyorBrainrots, index)
			break
		end
	end
	local model = record.model
	local clicker = model.PrimaryPart:FindFirstChild("BuyClickDetector")
	if clicker then
		clicker:Destroy()
	end
	local target = PlotLayout.getSlotRigPosition(state.plotName, slot, record.def.scale)
	-- Walk the rig home: anchored parts only move together via PivotTo, so
	-- step the whole model along a short arc instead of tweening one part.
	local startPos = model.PrimaryPart.Position
	local steps = 24
	for step = 1, steps do
		local t = step / steps
		local pos = startPos:Lerp(target, t) + Vector3.new(0, math.sin(t * math.pi) * 4, 0)
		model:PivotTo(CFrame.new(pos))
		task.wait(0.05)
	end
	model:PivotTo(CFrame.new(target))
	local brainrot = {
		def = record.def,
		mutation = record.mutation,
		cost = record.cost,
		income = record.income,
		model = model,
		owner = player,
	}
	if not GameState.assignBrainrotToSlot(player, slot, brainrot) then
		GameState.addCash(player, record.cost)
		model:Destroy()
		return false
	end
	local billboard = model:FindFirstChild("OverheadBillboard", true)
	if billboard then
		local costLabel = billboard:FindFirstChild("CostLabel")
		if costLabel then
			costLabel.Text = "YOURS  |  SLOT " .. tostring(slot)
			costLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
		end
	end
	local StealService = require(script.Parent.StealService)
	StealService.attachStealClickDetector(player, slot, model)
	return true
end

function ConveyorService.startConveyorLoop()
	task.spawn(function()
		while true do
			local now = os.clock()
			if now - lastSpawn >= ConveyorService.SPAWN_INTERVAL then
				lastSpawn = now
				ConveyorService.spawnConveyorBrainrot()
			end
			task.wait(0.5)
		end
	end)
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function(dt)
		ConveyorService.stepConveyorMovement(dt)
	end)
end

return ConveyorService
