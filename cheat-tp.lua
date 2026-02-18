-- =========================
-- AUTO GRAB SYSTEM (STANDALONE)
-- =========================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
local isPC = not UserInputService.TouchEnabled

if not getconnections then
	getconnections = function() return {} end
end

-- ========================
-- THEME COLORS
-- ========================
local Theme = {
	Primary = Color3.fromRGB(138, 43, 226),
	Secondary = Color3.fromRGB(255, 20, 147),
	Accent = Color3.fromRGB(0, 255, 255),
	Background = Color3.fromRGB(8, 12, 20),
	Background2 = Color3.fromRGB(15, 20, 32),
	Background3 = Color3.fromRGB(22, 28, 42),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 200),
}

-- ========================
-- CONFIGURATION SYSTEM
-- ========================
local lastUpdateTimes = {}
local function shouldUpdate(key, interval)
	local now = tick()
	if not lastUpdateTimes[key] or (now - lastUpdateTimes[key]) >= interval then
		lastUpdateTimes[key] = now
		return true
	end
	return false
end

local CONFIG_FILE = "AutoGrabConfig.json"

local function saveConfig(data)
	if writefile then
		pcall(function()
			writefile(CONFIG_FILE, HttpService:JSONEncode(data))
		end)
	end
end

local function loadConfig()
	if readfile and isfile then
		if isfile(CONFIG_FILE) then
			local success, result = pcall(function()
				return HttpService:JSONDecode(readfile(CONFIG_FILE))
			end)
			if success then return result end
		end
	end
	return {
		autoGrabEnabled = false,
		grabRadius = 20,
		uiPositionX = nil,
		uiPositionY = nil,
	}
end

local config = loadConfig()

-- ========================
-- CORE VARIABLES
-- ========================
local autoGrabEnabled = false
local GRAB_RADIUS = config.grabRadius or 20

local allAnimalsCache = {}
local internalGrabCache = {}
local cachedPrompts = {}
local grabConnection = nil
local isActivelyGrabbing = false
local lastGrabAttempt = 0
local GRAB_COOLDOWN = 0.1
local GRAB_DURATION = 1.5
local grabStartTime = nil
local currentGrabTarget = nil
local animalScannerRunning = false

-- ========================
-- UTILITY FUNCTIONS
-- ========================
local function getHRP()
	local c = LocalPlayer.Character
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
end

-- ========================
-- GAME LOGIC
-- ========================
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
	local objText = prompt.ObjectText and prompt.ObjectText:lower() or ""
	local actText = prompt.ActionText and prompt.ActionText:lower() or ""
	return objText:find("steal") or actText:find("steal")
end

local function findPromptForAnimal(animalData)
	if not animalData then return nil end

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

	for _, c in ipairs(spawn:GetDescendants()) do
		if c:IsA("ProximityPrompt") and isGrabPrompt(c) then
			return c
		end
	end

	return nil
end

local function getNearestAnimal()
	local hrp = getHRP()
	if not hrp then return nil end

	local nearest = nil
	local minDist = math.huge

	for _, animalData in ipairs(allAnimalsCache) do
		if not isMyBase(animalData.plot) then
			local dist = (hrp.Position - animalData.worldPosition).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = animalData
			end
		end
	end

	return nearest
end

-- ========================
-- ANIMAL SCANNER
-- ========================
local function scanAnimals()
	if animalScannerRunning then return end
	animalScannerRunning = true

	task.spawn(function()
		while true do
			allAnimalsCache = {}

			local plots = workspace:FindFirstChild("Plots")
			if plots then
				for _, plot in ipairs(plots:GetChildren()) do
					local podiums = plot:FindFirstChild("AnimalPodiums")
					if podiums then
						for _, podium in ipairs(podiums:GetChildren()) do
							local base = podium:FindFirstChild("Base")
							if base then
								local spawn = base:FindFirstChild("Spawn")
								if spawn then
									table.insert(allAnimalsCache, {
										plot = plot.Name,
										slot = podium.Name,
										worldPosition = spawn.Position
									})
								end
							end
						end
					end
				end
			end

			task.wait(2)
		end
	end)
end

scanAnimals()

-- ========================
-- AUTO GRAB CORE
-- ========================
local function tryGrabAnimal(animalData)
	if not animalData then return end
	if isActivelyGrabbing then return end
	if tick() - lastGrabAttempt < GRAB_COOLDOWN then return end

	lastGrabAttempt = tick()
	local prompt = findPromptForAnimal(animalData)
	if not prompt then return end

	currentGrabTarget = animalData
	isActivelyGrabbing = true
	grabStartTime = tick()

	fireproximityprompt(prompt)

	task.delay(GRAB_DURATION, function()
		isActivelyGrabbing = false
		currentGrabTarget = nil
	end)
end

local function startAutoGrab()
	if grabConnection then return end
	grabConnection = RunService.Heartbeat:Connect(function()
		if not autoGrabEnabled then return end

		local nearest = getNearestAnimal()
		if nearest then
			local hrp = getHRP()
			if hrp then
				local dist = (hrp.Position - nearest.worldPosition).Magnitude
				if dist <= GRAB_RADIUS then
					tryGrabAnimal(nearest)
				end
			end
		end
	end)
end

local function stopAutoGrab()
	if grabConnection then
		grabConnection:Disconnect()
		grabConnection = nil
	end
end

-- ========================
-- GUI VEXO | X77
-- ========================
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "VexoGui"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromScale(0.22, 0.12)
Main.Position = UDim2.fromScale(0.39, 0.05)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.fromScale(1, 0.4)
Title.BackgroundTransparency = 1
Title.Text = "Vexo | X77"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.fromScale(0.8, 0.4)
Toggle.Position = UDim2.fromScale(0.1, 0.5)
Toggle.Text = "AUTO GRAB : OFF"
Toggle.BackgroundColor3 = Theme.Background2
Toggle.TextColor3 = Theme.Text
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true
Toggle.BorderSizePixel = 0

local ToggleCorner = Instance.new("UICorner", Toggle)
ToggleCorner.CornerRadius = UDim.new(0, 12)

-- ========================
-- TOGGLE LOGIC
-- ========================
Toggle.MouseButton1Click:Connect(function()
	autoGrabEnabled = not autoGrabEnabled
	config.autoGrabEnabled = autoGrabEnabled
	saveConfig(config)

	if autoGrabEnabled then
		Toggle.Text = "AUTO GRAB : ON"
		Toggle.BackgroundColor3 = Theme.Primary
		startAutoGrab()
	else
		Toggle.Text = "AUTO GRAB : OFF"
		Toggle.BackgroundColor3 = Theme.Background2
		stopAutoGrab()
	end
end)

-- ========================
-- LOAD SAVED STATE
-- ========================
if config.autoGrabEnabled then
	autoGrabEnabled = true
	Toggle.Text = "AUTO GRAB : ON"
	Toggle.BackgroundColor3 = Theme.Primary
	startAutoGrab()
end

print("Vexo | X77 chargé avec succès")