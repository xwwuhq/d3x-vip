local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local GRAB_RADIUS = 20
local GRAB_COOLDOWN = 0.15
local GRAB_DURATION = 1.5

local allAnimalsCache = {}
local cachedPrompts = {}
local internalGrabCache = {}

local isActivelyGrabbing = false
local lastGrabAttempt = 0

-- AJOUT
local AutoGrabEnabled = false

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
		if isGrabPrompt(cachedPrompts[animalData.uid]) then
			return cachedPrompts[animalData.uid]
		else
			cachedPrompts[animalData.uid] = nil
		end
	end

	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	local plot = plots:FindFirstChild(animalData.plot)
	if not plot then return nil end

	local podiums = plot:FindFirstChild("AnimalPodiums")
	if not podiums then return nil end

	local podium = podiums:FindFirstChild(animalData.slot)
	if not podium then return nil end

	local base = podium:FindFirstChild("Base")
	if not base then return nil end

	local spawn = base:FindFirstChild("Spawn")
	if not spawn then return nil end

	for _, p in ipairs(spawn:GetDescendants()) do
		if p:IsA("ProximityPrompt") and isGrabPrompt(p) then
			cachedPrompts[animalData.uid] = p
			return p
		end
	end

	return nil
end

local function buildGrabCallbacks(prompt)
	if internalGrabCache[prompt] then return internalGrabCache[prompt] end

	local data = {hold = {}, trigger = {}, ready = true}

	local ok, conns = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok and conns then
		for _, c in ipairs(conns) do
			if type(c.Function) == "function" then
				table.insert(data.hold, c.Function)
			end
		end
	end

	local ok2, conns2 = pcall(getconnections, prompt.Triggered)
	if ok2 and conns2 then
		for _, c in ipairs(conns2) do
			if type(c.Function) == "function" then
				table.insert(data.trigger, c.Function)
			end
		end
	end

	internalGrabCache[prompt] = data
	return data
end

local function runCallbacks(list)
	for _, fn in ipairs(list) do
		task.spawn(fn)
	end
end

local function executeGrab(prompt)
	local data = buildGrabCallbacks(prompt)
	if not data or not data.ready then return end

	data.ready = false
	isActivelyGrabbing = true
	local start = tick()

	task.spawn(function()
		runCallbacks(data.hold)

		while tick() - start < GRAB_DURATION do
			task.wait(0.03)
		end

		runCallbacks(data.trigger)

		isActivelyGrabbing = false
		data.ready = true
	end)
end

local function scanSinglePlot(plot)
	if isMyBase(plot.Name) then return end

	local podiums = plot:FindFirstChild("AnimalPodiums")
	if not podiums then return end

	for _, podium in ipairs(podiums:GetChildren()) do
		if podium:IsA("Model") then
			table.insert(allAnimalsCache,{
				plot = plot.Name,
				slot = podium.Name,
				worldPosition = podium:GetPivot().Position,
				uid = plot.Name.."_"..podium.Name
			})
		end
	end
end

local function initializeScanner()
	local plots = workspace:WaitForChild("Plots",10)
	if not plots then return end

	allAnimalsCache = {}
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("Model") then
			scanSinglePlot(plot)
		end
	end

	task.spawn(function()
		while true do
			task.wait(5)
			allAnimalsCache = {}
			for _, plot in ipairs(plots:GetChildren()) do
				if plot:IsA("Model") then
					scanSinglePlot(plot)
				end
			end
		end
	end)
end

local function getNearestAnimal()
	local hrp = getHRP()
	if not hrp then return nil end

	local nearest = nil
	local minDist = math.huge

	for _, animal in ipairs(allAnimalsCache) do
		if not isMyBase(animal.plot) then
			local d = (hrp.Position - animal.worldPosition).Magnitude
			if d < minDist then
				minDist = d
				nearest = animal
			end
		end
	end

	if minDist <= GRAB_RADIUS then
		return nearest
	end
end

initializeScanner()

RunService.Heartbeat:Connect(function()
	if not AutoGrabEnabled then return end
	if isActivelyGrabbing then return end
	if tick() - lastGrabAttempt < GRAB_COOLDOWN then return end

	local target = getNearestAnimal()
	if not target then return end

	local prompt = findPromptForAnimal(target)
	if prompt and prompt.Enabled then
		lastGrabAttempt = tick()
		executeGrab(prompt)
	end
end)

-- pour la partie 2 (le bouton)
_G.SetAutoGrab = function(state)
	AutoGrabEnabled = state
end

local function createToggle(text)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Size = UDim2.new(1, 0, 0, 40)
	buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	buttonFrame.BackgroundTransparency = 0.6
	buttonFrame.Parent = container
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = buttonFrame
	
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = 14
	label.Parent = buttonFrame
	
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Text = ""
	toggleBtn.Size = UDim2.new(0, 40, 0, 20)
	toggleBtn.Position = UDim2.new(1, -55, 0.5, -10)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleBtn.Parent = buttonFrame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleBtn
	
	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = UDim2.new(0, 2, 0.5, -8)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = toggleBtn
	
	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle
	
	local active = false
	
	toggleBtn.MouseButton1Click:Connect(function()
		active = not active
		
		local goalColor = active and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(60, 60, 60)
		local goalPos = active and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		
		TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = goalPos}):Play()

		if text == "Auto Grab Brainrot" then
			if _G.SetAutoGrab then
				_G.SetAutoGrab(active)
			end
		end
	end)
end