-- BrainrotCatalog: every brainrot BRAINROT BAY can spawn, on one ladder.
-- One module, one job: definitions, rarity rolls, mutation rolls, prices.
-- The server and the client both read this module, so the HUD, the conveyor
-- and the base always agree on what a brainrot costs and earns.

local BrainrotCatalog = {}

-- Rarity ladder, cheapest first. Color is the badge color the HUD shows.
BrainrotCatalog.RARITIES = {
	{ name = "Common", color = Color3.fromRGB(200, 200, 200), weight = 46 },
	{ name = "Rare", color = Color3.fromRGB(80, 160, 255), weight = 26 },
	{ name = "Epic", color = Color3.fromRGB(180, 90, 255), weight = 14 },
	{ name = "Legendary", color = Color3.fromRGB(255, 170, 0), weight = 8 },
	{ name = "Mythic", color = Color3.fromRGB(255, 70, 120), weight = 4 },
	{ name = "Brainrot God", color = Color3.fromRGB(0, 220, 220), weight = 1.5 },
	{ name = "Secret", color = Color3.fromRGB(20, 20, 20), weight = 0.5 },
}

-- Mutation ladder. multiplier multiplies both income and the look.
BrainrotCatalog.MUTATIONS = {
	{ name = "None", multiplier = 1, weight = 70, badge = "" },
	{ name = "Golden", multiplier = 2, weight = 18, badge = "GOLDEN x2" },
	{ name = "Diamond", multiplier = 5, weight = 9, badge = "DIAMOND x5" },
	{ name = "Rainbow", multiplier = 10, weight = 3, badge = "RAINBOW x10" },
}

-- The cast. bodyShape picks the rig silhouette, extras add the joke parts,
-- face is the goofy SurfaceGui expression on the head.
BrainrotCatalog.DEFINITIONS = {
	{ id = "noobini", name = "Noobini Pizzanini", rarity = "Common", cost = 10, income = 2,
		bodyShape = "Wedge", bodyColor = Color3.fromRGB(255, 190, 90), accentColor = Color3.fromRGB(220, 60, 60),
		scale = 1.0, face = ">:D", extras = { "Pepperoni", "Pepperoni", "CheeseDrip" } },
	{ id = "chimpanzini", name = "Chimpanzini Bananini", rarity = "Common", cost = 25, income = 4,
		bodyShape = "Ball", bodyColor = Color3.fromRGB(255, 225, 80), accentColor = Color3.fromRGB(140, 90, 40),
		scale = 1.0, face = "o_O", extras = { "BananaPeel", "TailCurl" } },
	{ id = "trippi", name = "Trippi Troppi", rarity = "Common", cost = 60, income = 8,
		bodyShape = "Ball", bodyColor = Color3.fromRGB(90, 180, 255), accentColor = Color3.fromRGB(255, 140, 60),
		scale = 1.1, face = ":3", extras = { "FishTail", "FinTop", "Bubbles" } },
	{ id = "tungtung", name = "Tung Tung Tung Sahur", rarity = "Rare", cost = 150, income = 15,
		bodyShape = "Cylinder", bodyColor = Color3.fromRGB(150, 100, 55), accentColor = Color3.fromRGB(90, 60, 30),
		scale = 1.2, face = "O_O", extras = { "LogBat", "LogBat", "DrumStick" } },
	{ id = "ballerina", name = "Ballerina Cappuccina", rarity = "Rare", cost = 300, income = 28,
		bodyShape = "Cylinder", bodyColor = Color3.fromRGB(255, 220, 200), accentColor = Color3.fromRGB(255, 120, 180),
		scale = 1.1, face = "~_~", extras = { "TutuSkirt", "CoffeeCup", "BalletShoe" } },
	{ id = "patapim", name = "Brr Brr Patapim", rarity = "Rare", cost = 500, income = 45,
		bodyShape = "Ball", bodyColor = Color3.fromRGB(120, 200, 120), accentColor = Color3.fromRGB(220, 230, 190),
		scale = 1.3, face = ":P", extras = { "LongNose", "LeafHat", "BigFeet" } },
	{ id = "lirili", name = "Lirili Larila", rarity = "Epic", cost = 900, income = 75,
		bodyShape = "Cylinder", bodyColor = Color3.fromRGB(60, 200, 90), accentColor = Color3.fromRGB(255, 200, 220),
		scale = 1.3, face = "^-^", extras = { "CactusArm", "CactusArm", "DesertFlower" } },
	{ id = "boneca", name = "Boneca Ambalabu", rarity = "Epic", cost = 1500, income = 120,
		bodyShape = "Ball", bodyColor = Color3.fromRGB(90, 220, 130), accentColor = Color3.fromRGB(255, 255, 255),
		scale = 1.4, face = "UwU", extras = { "FrogEye", "FrogEye", "LilyPad" } },
	{ id = "vaca", name = "La Vaca Saturno Saturnita", rarity = "Epic", cost = 2500, income = 190,
		bodyShape = "Block", bodyColor = Color3.fromRGB(255, 255, 255), accentColor = Color3.fromRGB(255, 200, 40),
		scale = 1.5, face = "moo?", extras = { "CowHorn", "CowHorn", "SaturnRing" } },
	{ id = "tralalero", name = "Tralalero Tralala", rarity = "Legendary", cost = 5000, income = 350,
		bodyShape = "Wedge", bodyColor = Color3.fromRGB(80, 140, 255), accentColor = Color3.fromRGB(255, 255, 255),
		scale = 1.7, face = ">:3", extras = { "SharkFin", "SharkTail", "Sneaker", "Sneaker" } },
	{ id = "frigo", name = "Frigo Camelo", rarity = "Legendary", cost = 9000, income = 600,
		bodyShape = "Block", bodyColor = Color3.fromRGB(200, 220, 235), accentColor = Color3.fromRGB(190, 140, 80),
		scale = 1.8, face = "B-)", extras = { "CamelHump", "CamelHump", "FridgeDoor", "IceCube" } },
	{ id = "tralaleritos", name = "Los Tralaleritos", rarity = "Mythic", cost = 20000, income = 1200,
		bodyShape = "Wedge", bodyColor = Color3.fromRGB(60, 120, 255), accentColor = Color3.fromRGB(255, 210, 60),
		scale = 1.9, face = "!!!", extras = { "SharkFin", "MiniShark", "MiniShark", "SharkTail" } },
	{ id = "graipuss", name = "Graipuss Medussi", rarity = "Mythic", cost = 40000, income = 2500,
		bodyShape = "Ball", bodyColor = Color3.fromRGB(160, 90, 220), accentColor = Color3.fromRGB(0, 230, 200),
		scale = 2.0, face = "@_@", extras = { "Tentacle", "Tentacle", "Tentacle", "JellyCrown" } },
	{ id = "combinazione", name = "La Grande Combinazione", rarity = "Brainrot God", cost = 100000, income = 6000,
		bodyShape = "Block", bodyColor = Color3.fromRGB(255, 210, 60), accentColor = Color3.fromRGB(255, 60, 60),
		scale = 2.3, face = "GOD", extras = { "GoldCrown", "SharkFin", "SaturnRing", "RainbowTrail" } },
	{ id = "garama", name = "Garama and Madundung", rarity = "Secret", cost = 250000, income = 15000,
		bodyShape = "Cylinder", bodyColor = Color3.fromRGB(30, 30, 40), accentColor = Color3.fromRGB(255, 215, 0),
		scale = 2.5, face = "???", extras = { "GoldCrown", "DarkAura", "SecretStar", "SecretStar" } },
}

local byId = {}
local byRarity = {}
for _, def in ipairs(BrainrotCatalog.DEFINITIONS) do
	byId[def.id] = def
	byRarity[def.rarity] = byRarity[def.rarity] or {}
	table.insert(byRarity[def.rarity], def)
end

function BrainrotCatalog.getBrainrotDefinition(id)
	return byId[id]
end

function BrainrotCatalog.getDefinitionsByRarity(rarity)
	return byRarity[rarity] or {}
end

function BrainrotCatalog.getRarityColor(rarity)
	for _, entry in ipairs(BrainrotCatalog.RARITIES) do
		if entry.name == rarity then
			return entry.color
		end
	end
	return Color3.fromRGB(200, 200, 200)
end

local function rollWeighted(entries)
	local total = 0
	for _, entry in ipairs(entries) do
		total = total + entry.weight
	end
	local roll = math.random() * total
	for _, entry in ipairs(entries) do
		roll = roll - entry.weight
		if roll <= 0 then
			return entry
		end
	end
	return entries[1]
end

function BrainrotCatalog.rollRarityTier(goldenHour)
	local entries = {}
	for _, rarity in ipairs(BrainrotCatalog.RARITIES) do
		local weight = rarity.weight
		if goldenHour and rarity.name ~= "Common" then
			weight = weight * 2
		end
		table.insert(entries, { name = rarity.name, weight = weight })
	end
	return rollWeighted(entries).name
end

function BrainrotCatalog.getGoldenHourRarityWeights()
	local weights = {}
	for _, rarity in ipairs(BrainrotCatalog.RARITIES) do
		if rarity.name == "Common" then
			weights[rarity.name] = rarity.weight
		else
			weights[rarity.name] = rarity.weight * 2
		end
	end
	return weights
end

function BrainrotCatalog.rollMutationModifier()
	return rollWeighted(BrainrotCatalog.MUTATIONS)
end

function BrainrotCatalog.getBrainrotCost(def, mutation)
	local mult = 1
	if mutation then
		mult = mutation.multiplier or 1
	end
	return math.floor(def.cost * mult + 0.5)
end

function BrainrotCatalog.calculateBrainrotIncome(def, mutation, rebirthMultiplier)
	local mult = 1
	if mutation then
		mult = mutation.multiplier or 1
	end
	local rebirth = rebirthMultiplier or 1
	return math.floor(def.income * mult * rebirth + 0.5)
end

-- Pick a random brainrot of a rolled rarity; used by the conveyor spawner.
function BrainrotCatalog.rollBrainrot(goldenHour)
	local rarity = BrainrotCatalog.rollRarityTier(goldenHour)
	local pool = BrainrotCatalog.getDefinitionsByRarity(rarity)
	local def = pool[math.random(1, #pool)]
	local mutation = BrainrotCatalog.rollMutationModifier()
	return def, mutation
end

return BrainrotCatalog
