-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- PARAMÈTRES DU GRAB
local GRAB_RADIUS = 20
local GRAB_COOLDOWN = 0.15
local GRAB_DURATION = 1.5

-- VARIABLES D'ÉTAT
local isOn = false -- Le script est éteint par défaut
local isActivelyGrabbing = false
local lastGrabAttempt = 0
local allAnimalsCache = {}
local cachedPrompts = {}
local internalGrabCache = {}

----------------------------------------------------------------                
-- PARTIE UI (INTERFACE STYLÉE)
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GrabberUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Fond du bouton (Le rail)
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.new(0, 60, 0, 30)
bg.Position = UDim2.new(0.5, -30, 0.1, 0) -- En haut au milieu
bg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
bg.BorderSizePixel = 0
bg.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = bg

-- Le cercle coulissant
local circle = Instance.new("Frame")
circle.Name = "Circle"
circle.Size = UDim2.new(0, 26, 0, 26)
circle.Position = UDim2.new(0, 2, 0.5, -13)
circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
circle.BorderSizePixel = 0
circle.Parent = bg

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circle

-- Le bouton invisible pour cliquer
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = bg

-- Label d'état
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 100, 0, 20)
label.Position = UDim2.new(0.5, -50, 1, 5)
label.BackgroundTransparency = 1
label.Text = "AUTO-GRAB: OFF"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 12
label.Parent = bg

-- ANIMATION DU BOUTON
local function toggleUI()
	isOn = not isOn
	
	local targetPos = isOn and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
	local targetColor = isOn and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(200, 200, 200)
	
	TweenService:Create(circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
	TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
	
	label.Text = "AUTO-GRAB: " .. (isOn and "ON" or "OFF")
	label.TextColor3 = isOn and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 255, 255)
end

toggleBtn.MouseButton1Click:Connect(toggleUI)

----------------------------------------------------------------                
-- LOGIQUE DU SCRIPT ORIGINAL (MODIFIÉE)
----------------------------------------------------------------

if not getconnections then
	getconnections = function() return {} end
end

local function getHRP()
	local c = LocalPlayer.Character
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c.PrimaryPart
end

local function isMyBase(plotName)
	local plot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yourBase = sign:FindFirstChild("YourBase")
		if yourBase and yourBase:IsA("BillboardGui") then
			return yourBase.Enabled == true
		end
	end
	return false
end

local function isGrabPrompt(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then return false end
	local objText = (prompt.ObjectText or ""):lower()
	local actText = (prompt.ActionText or ""):lower()
	return objText:find("steal") or actText:find("steal")
end

local function findPromptForAnimal(animalData)
	if not animalData then return nil end
	if cachedPrompts[animalData.uid] and cachedPrompts[animalData.uid].Parent then
		return cachedPrompts[animalData.uid]
	end

	local plot = workspace.Plots:FindFirstChild(animalData.plot)
	local podiums = plot and plot:FindFirstChild("AnimalPodiums")
	local podium = podiums and podiums:FindFirstChild(animalData.slot)
	local spawn = podium and podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")

	if spawn then
		for _, p in ipairs(spawn:GetDescendants()) do
			if p:IsA("ProximityPrompt") and isGrabPrompt(p) then
				cachedPrompts[animalData.uid] = p
				return p
			end
		end
	end
	return nil
end

local function executeGrab(prompt)
	isActivelyGrabbing = true
	local start = tick()
	
	-- Simulation de maintien (hold)
	pcall(function()
		local conns = getconnections(prompt.PromptButtonHoldBegan)
		for _, c in ipairs(conns) do task.spawn(c.Function) end
	end)

	task.wait(GRAB_DURATION)

	-- Déclenchement (trigger)
	pcall(function()
		local conns = getconnections(prompt.Triggered)
		for _, c in ipairs(conns) do task.spawn(c.Function) end
	end)

	isActivelyGrabbing = false
end

local function scanPlots()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end
	
	local newCache = {}
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") and not isMyBase(plot.Name) then
			local podiums = plot:FindFirstChild("AnimalPodiums")
			if podiums then
				for _, podium in ipairs(podiums:GetChildren()) do
					table.insert(newCache, {
						plot = plot.Name,
						slot = podium.Name,
						worldPosition = podium:GetPivot().Position,
						uid = plot.Name.."_"..podium.Name
					})
				end
			end
		end
	end
	allAnimalsCache = newCache
end

-- Scanner toutes les 5 secondes
task.spawn(function()
	while true do
		scanPlots()
		task.wait(5)
	end
end)

-- BOUCLE PRINCIPALE
RunService.Heartbeat:Connect(function()
	if not isOn then return end -- ARRÊTE TOUT SI LE BOUTON EST SUR OFF
	if isActivelyGrabbing then return end
	if tick() - lastGrabAttempt < GRAB_COOLDOWN then return end

	local hrp = getHRP()
	if not hrp then return end

	for _, animal in ipairs(allAnimalsCache) do
		local dist = (hrp.Position - animal.worldPosition).Magnitude
		if dist <= GRAB_RADIUS then
			local prompt = findPromptForAnimal(animal)
			if prompt and prompt.Enabled then
				lastGrabAttempt = tick()
				executeGrab(prompt)
				break
			end
		end
	end
end)
