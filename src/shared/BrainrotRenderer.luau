-- BrainrotRenderer: turns a catalog definition into a visible multi-part rig.
-- One module, one job: build the model, paint the mutation, hang the label.
-- Shared (ReplicatedStorage) so the server spawns the same rig the client
-- sees on the conveyor and on a base; the client only adds popups and HUD.

local BrainrotCatalog = require(script.Parent.BrainrotCatalog)

local BrainrotRenderer = {}

local function makePart(name, shape, size, color, position, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape
	part.Size = size
	part.Color = color
	part.Position = position
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	return part
end

local function makeWedge(name, size, color, position)
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Position = position
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	return part
end

-- One joke part per extras keyword. Each is 1-3 parts, so a rig lands at
-- 14-24 parts: body, head, 2 eyes, 2 pupils, mouth, 2 arms, 2 legs, 2 feet
-- plus the extras below.
local function addExtra(model, keyword, origin, scale, bodyColor, accentColor)
	local parts = {}
	local function add(part)
		part.Parent = model
		table.insert(parts, part)
	end
	local ox, oy, oz = origin.X, origin.Y, origin.Z
	if keyword == "Pepperoni" then
		add(makePart("Pepperoni", Enum.PartType.Cylinder, Vector3.new(0.2, 0.7, 0.7), Color3.fromRGB(200, 40, 40),
			Vector3.new(ox + math.random(-8, 8) * 0.1 * scale, oy + 0.6 * scale, oz + 0.4 * scale)))
	elseif keyword == "CheeseDrip" then
		add(makePart("CheeseDrip", Enum.PartType.Ball, Vector3.new(0.8, 0.5, 0.5) * scale, Color3.fromRGB(255, 220, 80),
			Vector3.new(ox, oy - 0.4 * scale, oz + 0.9 * scale)))
	elseif keyword == "BananaPeel" then
		add(makeWedge("BananaPeel", Vector3.new(1.2, 0.4, 0.6) * scale, Color3.fromRGB(255, 230, 100),
			Vector3.new(ox - 0.9 * scale, oy - 0.5 * scale, oz)))
	elseif keyword == "TailCurl" then
		add(makePart("TailCurl", Enum.PartType.Cylinder, Vector3.new(0.3, 1.4, 0.3) * scale, accentColor,
			Vector3.new(ox, oy + 0.2 * scale, oz - 1.0 * scale)))
	elseif keyword == "FishTail" then
		add(makeWedge("FishTail", Vector3.new(1.0, 1.0, 0.3) * scale, accentColor,
			Vector3.new(ox, oy, oz - 1.2 * scale)))
	elseif keyword == "FinTop" then
		add(makeWedge("FinTop", Vector3.new(0.8, 0.9, 0.3) * scale, accentColor,
			Vector3.new(ox, oy + 1.1 * scale, oz)))
	elseif keyword == "Bubbles" then
		add(makePart("Bubble", Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5) * scale, Color3.fromRGB(180, 230, 255),
			Vector3.new(ox + 0.8 * scale, oy + 1.2 * scale, oz)))
		add(makePart("Bubble2", Enum.PartType.Ball, Vector3.new(0.35, 0.35, 0.35) * scale, Color3.fromRGB(180, 230, 255),
			Vector3.new(ox - 0.7 * scale, oy + 1.5 * scale, oz + 0.3 * scale)))
	elseif keyword == "LogBat" then
		add(makePart("LogBat", Enum.PartType.Cylinder, Vector3.new(0.5, 1.6, 0.5) * scale, Color3.fromRGB(120, 80, 40),
			Vector3.new(ox + 1.3 * scale, oy + 0.6 * scale, oz)))
	elseif keyword == "DrumStick" then
		add(makePart("DrumStick", Enum.PartType.Ball, Vector3.new(0.6, 0.6, 0.6) * scale, Color3.fromRGB(240, 220, 180),
			Vector3.new(ox - 1.0 * scale, oy + 1.2 * scale, oz)))
	elseif keyword == "TutuSkirt" then
		add(makePart("TutuSkirt", Enum.PartType.Cylinder, Vector3.new(0.3, 2.6, 2.6) * scale, Color3.fromRGB(255, 170, 210),
			Vector3.new(ox, oy - 0.5 * scale, oz)))
	elseif keyword == "CoffeeCup" then
		add(makePart("CoffeeCup", Enum.PartType.Cylinder, Vector3.new(0.8, 0.6, 0.6) * scale, Color3.fromRGB(255, 255, 255),
			Vector3.new(ox + 1.2 * scale, oy + 0.3 * scale, oz + 0.4 * scale)))
	elseif keyword == "BalletShoe" then
		add(makePart("BalletShoe", Enum.PartType.Ball, Vector3.new(0.5, 0.4, 0.9) * scale, Color3.fromRGB(255, 150, 190),
			Vector3.new(ox + 0.5 * scale, oy - 1.2 * scale, oz + 0.5 * scale)))
	elseif keyword == "LongNose" then
		add(makePart("LongNose", Enum.PartType.Cylinder, Vector3.new(0.4, 1.8, 0.4) * scale, accentColor,
			Vector3.new(ox, oy + 0.1 * scale, oz + 1.2 * scale)))
	elseif keyword == "LeafHat" then
		add(makePart("LeafHat", Enum.PartType.Ball, Vector3.new(1.4, 0.4, 1.4) * scale, Color3.fromRGB(60, 180, 80),
			Vector3.new(ox, oy + 1.6 * scale, oz)))
	elseif keyword == "BigFeet" then
		add(makePart("BigFoot", Enum.PartType.Ball, Vector3.new(0.9, 0.5, 1.2) * scale, accentColor,
			Vector3.new(ox + 0.6 * scale, oy - 1.3 * scale, oz + 0.4 * scale)))
	elseif keyword == "CactusArm" then
		add(makePart("CactusArm", Enum.PartType.Cylinder, Vector3.new(0.4, 1.2, 0.4) * scale, bodyColor,
			Vector3.new(ox + 1.2 * scale, oy + 0.4 * scale, oz)))
	elseif keyword == "DesertFlower" then
		add(makePart("DesertFlower", Enum.PartType.Ball, Vector3.new(0.7, 0.7, 0.7) * scale, Color3.fromRGB(255, 120, 200),
			Vector3.new(ox + 0.4 * scale, oy + 1.7 * scale, oz)))
	elseif keyword == "FrogEye" then
		add(makePart("FrogEye", Enum.PartType.Ball, Vector3.new(0.6, 0.6, 0.6) * scale, Color3.fromRGB(255, 255, 255),
			Vector3.new(ox + 0.7 * scale, oy + 1.6 * scale, oz + 0.6 * scale)))
	elseif keyword == "LilyPad" then
		add(makePart("LilyPad", Enum.PartType.Cylinder, Vector3.new(0.2, 1.2, 1.2) * scale, Color3.fromRGB(50, 160, 70),
			Vector3.new(ox - 1.0 * scale, oy - 1.2 * scale, oz + 0.6 * scale)))
	elseif keyword == "CowHorn" then
		add(makePart("CowHorn", Enum.PartType.Cylinder, Vector3.new(0.3, 1.0, 0.3) * scale, Color3.fromRGB(255, 240, 200),
			Vector3.new(ox + 0.9 * scale, oy + 1.6 * scale, oz)))
	elseif keyword == "SaturnRing" then
		local ring = makePart("SaturnRing", Enum.PartType.Cylinder, Vector3.new(0.25, 4.2, 4.2) * scale, accentColor,
			Vector3.new(ox, oy + 0.2 * scale, oz))
		ring.Material = Enum.Material.Neon
		add(ring)
	elseif keyword == "SharkFin" then
		add(makeWedge("SharkFin", Vector3.new(1.0, 1.2, 0.3) * scale, Color3.fromRGB(70, 110, 200),
			Vector3.new(ox, oy + 1.3 * scale, oz - 0.2 * scale)))
	elseif keyword == "SharkTail" then
		add(makeWedge("SharkTail", Vector3.new(1.2, 1.2, 0.3) * scale, Color3.fromRGB(70, 110, 200),
			Vector3.new(ox, oy + 0.2 * scale, oz - 1.5 * scale)))
	elseif keyword == "Sneaker" then
		add(makePart("Sneaker", Enum.PartType.Block, Vector3.new(0.7, 0.4, 1.3) * scale, Color3.fromRGB(255, 255, 255),
			Vector3.new(ox + 0.6 * scale, oy - 1.3 * scale, oz + 0.5 * scale)))
	elseif keyword == "CamelHump" then
		add(makePart("CamelHump", Enum.PartType.Ball, Vector3.new(1.0, 0.8, 1.0) * scale, accentColor,
			Vector3.new(ox + 0.6 * scale, oy + 1.3 * scale, oz)))
	elseif keyword == "FridgeDoor" then
		add(makePart("FridgeDoor", Enum.PartType.Block, Vector3.new(0.2, 1.6, 1.4) * scale, Color3.fromRGB(230, 240, 250),
			Vector3.new(ox, oy + 0.2 * scale, oz + 0.9 * scale)))
	elseif keyword == "IceCube" then
		add(makePart("IceCube", Enum.PartType.Block, Vector3.new(0.6, 0.6, 0.6) * scale, Color3.fromRGB(180, 230, 255),
			Vector3.new(ox - 1.1 * scale, oy - 0.8 * scale, oz + 0.7 * scale)))
	elseif keyword == "MiniShark" then
		add(makeWedge("MiniShark", Vector3.new(0.8, 0.7, 0.4) * scale, Color3.fromRGB(90, 150, 255),
			Vector3.new(ox + 1.4 * scale, oy + 0.2 * scale, oz + 0.5 * scale)))
	elseif keyword == "Tentacle" then
		add(makePart("Tentacle", Enum.PartType.Cylinder, Vector3.new(0.3, 1.6, 0.3) * scale, accentColor,
			Vector3.new(ox + (math.random(-10, 10) * 0.08) * scale, oy - 1.4 * scale, oz + (math.random(-10, 10) * 0.05) * scale)))
	elseif keyword == "JellyCrown" then
		add(makePart("JellyCrown", Enum.PartType.Ball, Vector3.new(0.9, 0.5, 0.9) * scale, Color3.fromRGB(0, 230, 200),
			Vector3.new(ox, oy + 1.7 * scale, oz)))
	elseif keyword == "GoldCrown" then
		local crown = makePart("GoldCrown", Enum.PartType.Cylinder, Vector3.new(0.5, 1.4, 1.4) * scale, Color3.fromRGB(255, 215, 0),
			Vector3.new(ox, oy + 1.8 * scale, oz))
		crown.Material = Enum.Material.Neon
		add(crown)
	elseif keyword == "RainbowTrail" then
		local trail = makePart("RainbowTrail", Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5) * scale, Color3.fromRGB(255, 80, 200),
			Vector3.new(ox, oy + 0.6 * scale, oz - 1.2 * scale))
		trail.Material = Enum.Material.Neon
		add(trail)
	elseif keyword == "DarkAura" then
		local aura = makePart("DarkAura", Enum.PartType.Ball, Vector3.new(3.2, 3.2, 3.2) * scale, Color3.fromRGB(60, 0, 90),
			Vector3.new(ox, oy + 0.3 * scale, oz))
		aura.Transparency = 0.7
		aura.Material = Enum.Material.Neon
		add(aura)
	elseif keyword == "SecretStar" then
		local star = makePart("SecretStar", Enum.PartType.Ball, Vector3.new(0.6, 0.6, 0.6) * scale, Color3.fromRGB(255, 215, 0),
			Vector3.new(ox + (math.random(-14, 14) * 0.1) * scale, oy + 1.4 * scale, oz + 0.5 * scale))
		star.Material = Enum.Material.Neon
		add(star)
	end
	return parts
end

function BrainrotRenderer.buildBrainrotRig(def, mutation, position)
	local scale = def.scale or 1
	local model = Instance.new("Model")
	model.Name = def.id .. "_rig"

	local origin = position or Vector3.new(0, 3, 0)
	local bodyShape = Enum.PartType.Ball
	if def.bodyShape == "Block" then
		bodyShape = Enum.PartType.Block
	elseif def.bodyShape == "Cylinder" then
		bodyShape = Enum.PartType.Cylinder
	elseif def.bodyShape == "Wedge" then
		bodyShape = Enum.PartType.Wedge
	end

	local body
	if def.bodyShape == "Wedge" then
		body = makeWedge("Body", Vector3.new(2.2, 2.0, 2.6) * scale, def.bodyColor, origin)
	else
		body = makePart("Body", bodyShape, Vector3.new(2.2, 2.2, 2.2) * scale, def.bodyColor, origin)
	end
	body.Parent = model
	model.PrimaryPart = body
	body.CanQuery = true -- the ClickDetector that buys/steals lives on this part

	local head = makePart("Head", Enum.PartType.Ball, Vector3.new(1.7, 1.7, 1.7) * scale, def.bodyColor,
		origin + Vector3.new(0, 1.6 * scale, 0.2 * scale))
	head.Parent = model

	-- Goofy face: two eyes, two pupils, a smile bar, and a SurfaceGui face.
	local eyeL = makePart("EyeLeft", Enum.PartType.Ball, Vector3.new(0.45, 0.55, 0.3) * scale, Color3.fromRGB(255, 255, 255),
		origin + Vector3.new(-0.45 * scale, 1.8 * scale, 1.0 * scale))
	eyeL.Parent = model
	local eyeR = makePart("EyeRight", Enum.PartType.Ball, Vector3.new(0.45, 0.55, 0.3) * scale, Color3.fromRGB(255, 255, 255),
		origin + Vector3.new(0.45 * scale, 1.8 * scale, 1.0 * scale))
	eyeR.Parent = model
	local pupilL = makePart("PupilLeft", Enum.PartType.Ball, Vector3.new(0.2, 0.25, 0.15) * scale, Color3.fromRGB(10, 10, 10),
		origin + Vector3.new(-0.45 * scale, 1.8 * scale, 1.15 * scale))
	pupilL.Parent = model
	local pupilR = makePart("PupilRight", Enum.PartType.Ball, Vector3.new(0.2, 0.25, 0.15) * scale, Color3.fromRGB(10, 10, 10),
		origin + Vector3.new(0.45 * scale, 1.8 * scale, 1.15 * scale))
	pupilR.Parent = model
	local mouth = makePart("Mouth", Enum.PartType.Block, Vector3.new(0.7, 0.15, 0.15) * scale, Color3.fromRGB(10, 10, 10),
		origin + Vector3.new(0, 1.25 * scale, 1.0 * scale))
	mouth.Parent = model

	local faceGui = Instance.new("SurfaceGui")
	faceGui.Name = "FaceGui"
	faceGui.Face = Enum.NormalId.Front
	faceGui.Parent = head
	local faceLabel = Instance.new("TextLabel")
	faceLabel.Name = "Face"
	faceLabel.Size = UDim2.fromScale(1, 1)
	faceLabel.BackgroundTransparency = 1
	faceLabel.Text = def.face or ":)"
	faceLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
	faceLabel.TextScaled = true
	faceLabel.Font = Enum.Font.GothamBlack
	faceLabel.Parent = faceGui

	-- Arms, legs, feet: the rig walks the conveyor on these.
	for _, side in ipairs({ -1, 1 }) do
		local arm = makePart("Arm" .. (side < 0 and "Left" or "Right"), Enum.PartType.Cylinder,
			Vector3.new(0.4, 1.2, 0.4) * scale, def.accentColor,
			origin + Vector3.new(1.35 * scale * side, 0.3 * scale, 0))
		arm.Parent = model
		local leg = makePart("Leg" .. (side < 0 and "Left" or "Right"), Enum.PartType.Cylinder,
			Vector3.new(0.5, 1.0, 0.5) * scale, def.accentColor,
			origin + Vector3.new(0.6 * scale * side, -1.4 * scale, 0))
		leg.Parent = model
		local foot = makePart("Foot" .. (side < 0 and "Left" or "Right"), Enum.PartType.Block,
			Vector3.new(0.7, 0.35, 1.1) * scale, Color3.fromRGB(40, 40, 40),
			origin + Vector3.new(0.6 * scale * side, -1.95 * scale, 0.2 * scale))
		foot.Parent = model
	end

	for _, extra in ipairs(def.extras or {}) do
		addExtra(model, extra, origin, scale, def.bodyColor, def.accentColor)
	end

	if mutation then
		BrainrotRenderer.applyMutationVisuals(model, mutation)
	end
	return model
end

function BrainrotRenderer.applyMutationVisuals(model, mutation)
	if not mutation or mutation.name == "None" then
		return
	end
	if mutation.name == "Golden" then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "DarkAura" then
				part.Color = Color3.fromRGB(255, 205, 40)
				part.Reflectance = 0.4
				part.Material = Enum.Material.Metal
			end
		end
		local sparkles = Instance.new("Sparkles")
		sparkles.Name = "GoldenSparkles"
		sparkles.SparkleColor = Color3.fromRGB(255, 220, 80)
		sparkles.Parent = model.PrimaryPart
	elseif mutation.name == "Diamond" then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(150, 230, 255)
				part.Transparency = 0.35
				part.Material = Enum.Material.Glass
				part.Reflectance = 0.3
			end
		end
		local sparkles = Instance.new("Sparkles")
		sparkles.Name = "DiamondSparkles"
		sparkles.SparkleColor = Color3.fromRGB(180, 240, 255)
		sparkles.Parent = model.PrimaryPart
	elseif mutation.name == "Rainbow" then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
			end
		end
		local light = Instance.new("PointLight")
		light.Name = "RainbowLight"
		light.Color = Color3.fromHSV(0, 1, 1)
		light.Range = 12
		light.Brightness = 2
		light.Parent = model.PrimaryPart
		local sparkles = Instance.new("Sparkles")
		sparkles.Name = "RainbowSparkles"
		sparkles.SparkleColor = Color3.fromRGB(255, 100, 220)
		sparkles.Parent = model.PrimaryPart
	end
end

-- Hue-cycle the rainbow light. The client calls this on RenderStepped for
-- every rainbow rig it can see; the server never needs it.
function BrainrotRenderer.cycleRainbowLight(model, timeSeconds)
	local light = model:FindFirstChild("RainbowLight", true)
	if light then
		light.Color = Color3.fromHSV((timeSeconds * 0.25) % 1, 1, 1)
	end
end

function BrainrotRenderer.attachOverheadBillboard(model, def, mutation, incomePerSecond, showCost)
	local head = model:FindFirstChild("Head")
	if not head then
		return nil
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "OverheadBillboard"
	gui.Size = UDim2.fromOffset(220, 110)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "BrainrotName"
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Parent = gui

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityBadge"
	rarityLabel.Size = UDim2.new(0.6, 0, 0, 24)
	rarityLabel.Position = UDim2.new(0.2, 0, 0, 32)
	rarityLabel.BackgroundColor3 = BrainrotCatalog.getRarityColor(def.rarity)
	rarityLabel.Text = string.upper(def.rarity)
	rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rarityLabel.TextStrokeTransparency = 0
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = gui

	if mutation and mutation.name ~= "None" then
		local pill = Instance.new("TextLabel")
		pill.Name = "MutationPill"
		pill.Size = UDim2.new(0.6, 0, 0, 22)
		pill.Position = UDim2.new(0.2, 0, 0, 58)
		pill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		pill.Text = "[" .. (mutation.badge or mutation.name) .. "]"
		pill.TextColor3 = Color3.fromRGB(60, 30, 0)
		pill.TextScaled = true
		pill.Font = Enum.Font.GothamBold
		pill.Parent = gui
	end

	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Name = "IncomeLabel"
	incomeLabel.Size = UDim2.new(1, 0, 0, 24)
	incomeLabel.Position = UDim2.new(0, 0, 0, 82)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = "+$" .. tostring(incomePerSecond) .. "/s"
	incomeLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	incomeLabel.TextStrokeTransparency = 0
	incomeLabel.TextScaled = true
	incomeLabel.Font = Enum.Font.GothamBold
	incomeLabel.Parent = gui

	if showCost then
		local cost = BrainrotCatalog.getBrainrotCost(def, mutation)
		local costLabel = Instance.new("TextLabel")
		costLabel.Name = "CostLabel"
		costLabel.Size = UDim2.new(1, 0, 0, 24)
		costLabel.Position = UDim2.new(0, 0, 0, 104)
		costLabel.BackgroundTransparency = 1
		costLabel.Text = "$" .. tostring(cost) .. "  |  CLICK TO BUY"
		costLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
		costLabel.TextStrokeTransparency = 0
		costLabel.TextScaled = true
		costLabel.Font = Enum.Font.GothamBold
		costLabel.Parent = gui
		gui.Size = UDim2.fromOffset(220, 132)
	end
	return gui
end

-- Floating "+$250" popup above a brainrot. Client-side only.
function BrainrotRenderer.spawnCashTickPopup(model, amount)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "CashPopup"
	gui.Size = UDim2.fromOffset(120, 40)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "+$" .. tostring(amount)
	label.TextColor3 = Color3.fromRGB(120, 255, 120)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	task.delay(1.2, function()
		gui:Destroy()
	end)
end

return BrainrotRenderer
