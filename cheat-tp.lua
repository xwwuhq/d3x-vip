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
-- ANIMATION SYSTEM
-- ========================
local activeGradients = {}
local animationAngle = 0
local rainbowHue = 0

local function registerGradient(gradient)
    table.insert(activeGradients, gradient)
end

local gradientUpdateCounter = 0
RunService.Heartbeat:Connect(function(dt)
    gradientUpdateCounter = gradientUpdateCounter + 1
    if gradientUpdateCounter % 2 ~= 0 then return end

    animationAngle = (animationAngle + (dt * 120)) % 360
    rainbowHue = (rainbowHue + (dt * 0.3)) % 1
    
    for i = #activeGradients, 1, -1 do
        local grad = activeGradients[i]
        if grad and grad.Parent then
            grad.Rotation = animationAngle
        else
            table.remove(activeGradients, i)
        end
    end
end)

local function createRainbowGradient(instance, speed)
    speed = speed or 1
    local gradient = Instance.new("UIGradient")
    gradient.Parent = instance
    
    local function updateRainbow()
        local h = (tick() * speed * 0.15) % 1
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 0.8, 1)),
            ColorSequenceKeypoint.new(0.2, Color3.fromHSV((h + 0.1) % 1, 0.85, 1)),
            ColorSequenceKeypoint.new(0.4, Color3.fromHSV((h + 0.2) % 1, 0.9, 1)),
            ColorSequenceKeypoint.new(0.6, Color3.fromHSV((h + 0.3) % 1, 0.85, 1)),
            ColorSequenceKeypoint.new(0.8, Color3.fromHSV((h + 0.4) % 1, 0.8, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.5) % 1, 0.75, 1))
        })
    end
    
    RunService.Heartbeat:Connect(updateRainbow)
    registerGradient(gradient)
    return gradient
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

-- UI Elements
local autoGrabProgressFrame = nil
local circularProgress = nil
local circularProgressFill = nil
local progressText = nil

-- Circle Parts
local CIRCLE_SEGMENTS = 80
local SEGMENT_HEIGHT = 0.2
local SEGMENT_THICKNESS = 0.3
local circleParts = {}

-- ========================
-- UTILITY FUNCTIONS
-- ========================
local function getHRP()
    local c = LocalPlayer.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c.PrimaryPart
end

-- ========================
-- VISUAL CIRCLE SYSTEM
-- ========================
local function destroyCircleParts()
    for _, part in ipairs(circleParts) do
        if part and part.Parent then part:Destroy() end
    end
    circleParts = {}
    pcall(function()
        RunService:UnbindFromRenderStep("AutoGrabCircleFollow")
    end)
end

local function createCircleBorder()
    destroyCircleParts()

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local points = {}
    for i = 0, CIRCLE_SEGMENTS - 1 do
        local angle = math.rad(i * 360 / CIRCLE_SEGMENTS)
        table.insert(points, Vector3.new(math.cos(angle), 0, math.sin(angle)) * GRAB_RADIUS)
    end

    for i = 1, #points do
        local nextIndex = i % #points + 1
        local p1 = points[i]
        local p2 = points[nextIndex]

        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new((p2 - p1).Magnitude, SEGMENT_HEIGHT, SEGMENT_THICKNESS)
        part.Color = Color3.fromRGB(255, 255, 255)
        part.Material = Enum.Material.Neon
        part.Transparency = 0.15
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.CastShadow = false
        part.Parent = workspace
        
        if i % 4 == 0 then
            local sparkle = Instance.new("ParticleEmitter")
            sparkle.Parent = part
            sparkle.Texture = "rbxassetid://1084976679"
            sparkle.Rate = 2
            sparkle.Lifetime = NumberRange.new(0.3, 0.6)
            sparkle.Speed = NumberRange.new(0.5, 1)
            sparkle.SpreadAngle = Vector2.new(180, 180)
            sparkle.Size = NumberSequence.new(0.1, 0)
            sparkle.Transparency = NumberSequence.new(0.5, 1)
            sparkle.LightEmission = 1
            sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        end
        
        table.insert(circleParts, part)
    end

    RunService:BindToRenderStep("AutoGrabCircleFollow", Enum.RenderPriority.Camera.Value + 1, function()
        local r = char:FindFirstChild("HumanoidRootPart")
        if not r then return end

        local pts = {}
        for i = 0, CIRCLE_SEGMENTS - 1 do
            local angle = math.rad(i * 360 / CIRCLE_SEGMENTS)
            table.insert(pts, Vector3.new(math.cos(angle), 0, math.sin(angle)) * GRAB_RADIUS)
        end

        local time = tick()
        for idx, p in ipairs(circleParts) do
            if p and p.Parent then
                local nextIndex = idx % #pts + 1
                local a = pts[idx]
                local b = pts[nextIndex]
                local center = (a + b) / 2 + Vector3.new(r.Position.X, r.Position.Y - 2.8, r.Position.Z)
                p.Size = Vector3.new((b - a).Magnitude, SEGMENT_HEIGHT, SEGMENT_THICKNESS)
                p.CFrame = CFrame.new(center, center + Vector3.new(b.X - a.X, 0, b.Z - a.Z)) * CFrame.Angles(0, math.pi / 2, 0)
                
                local hue = (time * 0.5 + (idx / #circleParts)) % 1
                p.Color = Color3.fromHSV(hue, 0.9, 1)
            end
        end
    end)
end

local function updateRadiusCircle()
    destroyCircleParts()
    if autoGrabEnabled then
        createCircleBorder()
    end
end

-- ========================
-- UI CREATION
-- ========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoGrabSystem"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 1000
screenGui.Parent = PlayerGui

local function createAutoGrabUI()
    local baseWidth = isMobile and 85 or 100
    local baseHeight = isMobile and 200 or 240

    autoGrabProgressFrame = Instance.new("Frame")
    autoGrabProgressFrame.Name = "AutoGrabPanel"
    autoGrabProgressFrame.Size = UDim2.new(0, baseWidth, 0, baseHeight)
    autoGrabProgressFrame.BackgroundColor3 = Theme.Background
    autoGrabProgressFrame.BackgroundTransparency = 0.1
    autoGrabProgressFrame.Active = true
    autoGrabProgressFrame.Parent = screenGui
    autoGrabProgressFrame.ClipsDescendants = false

    Instance.new("UICorner", autoGrabProgressFrame).CornerRadius = UDim.new(0, 20)
    
    for i = 1, 3 do
        local stroke = Instance.new("UIStroke")
        stroke.Name = "RainbowStroke" .. i
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = i == 1 and 3 or (i == 2 and 2 or 1)
        stroke.Transparency = i == 1 and 0.1 or (i == 2 and 0.3 or 0.5)
        stroke.Parent = autoGrabProgressFrame
        createRainbowGradient(stroke, 1 + (i * 0.3))
    end
    
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Name = "MassiveGlow"
    outerGlow.Size = UDim2.new(1, 60, 1, 60)
    outerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = "rbxassetid://5028857084"
    outerGlow.ImageColor3 = Color3.fromRGB(138, 43, 226)
    outerGlow.ImageTransparency = 0.7
    outerGlow.ZIndex = -1
    outerGlow.Parent = autoGrabProgressFrame
    createRainbowGradient(outerGlow, 1.2)

    if isPC then
        autoGrabProgressFrame.Draggable = true
        if config.uiPositionX and config.uiPositionY then
            autoGrabProgressFrame.Position = UDim2.new(0, config.uiPositionX, 0, config.uiPositionY)
        else
            autoGrabProgressFrame.Position = UDim2.new(0, 20, 0.5, -baseHeight / 2)
        end

        local saving = false
        autoGrabProgressFrame:GetPropertyChangedSignal("Position"):Connect(function()
            if saving then return end
            saving = true
            task.delay(0.5, function()
                config.uiPositionX = autoGrabProgressFrame.AbsolutePosition.X
                config.uiPositionY = autoGrabProgressFrame.AbsolutePosition.Y
                saveConfig(config)
                saving = false
            end)
        end)
    else
        autoGrabProgressFrame.Draggable = false
        autoGrabProgressFrame.Position = UDim2.new(0, 20, 0.5, -baseHeight / 2)
    end

    local circleContainer = Instance.new("Frame")
    circleContainer.Name = "CircleContainer"
    circleContainer.Size = UDim2.new(0, baseWidth - 20, 0, baseWidth - 20)
    circleContainer.Position = UDim2.new(0.5, 0, 0, 15)
    circleContainer.AnchorPoint = Vector2.new(0.5, 0)
    circleContainer.BackgroundTransparency = 1
    circleContainer.Parent = autoGrabProgressFrame

    local circleBg = Instance.new("Frame")
    circleBg.Size = UDim2.new(1, 0, 1, 0)
    circleBg.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleBg.AnchorPoint = Vector2.new(0.5, 0.5)
    circleBg.BackgroundColor3 = Theme.Background2
    circleBg.Parent = circleContainer
    Instance.new("UICorner", circleBg).CornerRadius = UDim.new(1, 0)
    
    local circleBgStroke = Instance.new("UIStroke")
    circleBgStroke.Color = Color3.fromRGB(100, 100, 120)
    circleBgStroke.Thickness = 2
    circleBgStroke.Transparency = 0.6
    circleBgStroke.Parent = circleBg

    circularProgress = Instance.new("ImageLabel")
    circularProgress.Name = "CircularProgress"
    circularProgress.Size = UDim2.new(0.9, 0, 0.9, 0)
    circularProgress.Position = UDim2.new(0.5, 0, 0.5, 0)
    circularProgress.AnchorPoint = Vector2.new(0.5, 0.5)
    circularProgress.BackgroundTransparency = 1
    circularProgress.Image = "rbxassetid://14978080670"
    circularProgress.ImageColor3 = Color3.fromRGB(255, 255, 255)
    circularProgress.Parent = circleBg
    createRainbowGradient(circularProgress, 2)
    
    circularProgressFill = Instance.new("Frame")
    circularProgressFill.Name = "ProgressMask"
    circularProgressFill.Size = UDim2.new(1, 0, 0, 0)
    circularProgressFill.Position = UDim2.new(0, 0, 1, 0)
    circularProgressFill.AnchorPoint = Vector2.new(0, 1)
    circularProgressFill.BackgroundTransparency = 1
    circularProgressFill.ClipsDescendants = true
    circularProgressFill.Parent = circularProgress

    progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Size = UDim2.new(0.7, 0, 0.3, 0)
    progressText.Position = UDim2.new(0.5, 0, 0.5, 0)
    progressText.AnchorPoint = Vector2.new(0.5, 0.5)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.Font = Enum.Font.GothamBold
    progressText.TextSize = isMobile and 16 or 20
    progressText.TextStrokeTransparency = 0.5
    progressText.Parent = circleBg
    createRainbowGradient(progressText, 1.8)

    local powerButton = Instance.new("TextButton")
    powerButton.Name = "PowerButton"
    powerButton.Size = UDim2.new(0, baseWidth - 24, 0, isMobile and 36 or 42)
    powerButton.Position = UDim2.new(0.5, 0, 0, baseWidth + 20)
    powerButton.AnchorPoint = Vector2.new(0.5, 0)
    powerButton.BackgroundColor3 = Theme.Background3
    powerButton.AutoButtonColor = false
    powerButton.Text = ""
    powerButton.Parent = autoGrabProgressFrame
    Instance.new("UICorner", powerButton).CornerRadius = UDim.new(0, 12)
    
    local powerStroke = Instance.new("UIStroke")
    powerStroke.Color = Color3.fromRGB(80, 80, 100)
    powerStroke.Thickness = 2
    powerStroke.Parent = powerButton
    
    local powerIcon = Instance.new("ImageLabel")
    powerIcon.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
    powerIcon.Position = UDim2.new(0, 8, 0.5, 0)
    powerIcon.AnchorPoint = Vector2.new(0, 0.5)
    powerIcon.BackgroundTransparency = 1
    powerIcon.Image = "rbxassetid://7733920644"
    powerIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    powerIcon.Parent = powerButton
    
    local powerLabel = Instance.new("TextLabel")
    powerLabel.Size = UDim2.new(1, -40, 1, 0)
    powerLabel.Position = UDim2.new(0, 36, 0, 0)
    powerLabel.BackgroundTransparency = 1
    powerLabel.Text = "AUTO GRAB"
    powerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    powerLabel.Font = Enum.Font.GothamBold
    powerLabel.TextSize = isMobile and 11 or 13
    powerLabel.TextXAlignment = Enum.TextXAlignment.Left
    powerLabel.Parent = powerButton
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -14, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    statusDot.Parent = powerButton
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local function updatePowerButton(enabled)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if enabled then
            TweenService:Create(powerButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
            TweenService:Create(powerLabel, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(powerIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(statusDot, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}):Play()
            createRainbowGradient(powerStroke, 1.5)
            createRainbowGradient(statusDot, 2)
        else
            TweenService:Create(powerButton, tweenInfo, {BackgroundColor3 = Theme.Background3}):Play()
            TweenService:Create(powerLabel, tweenInfo, {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            TweenService:Create(powerIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            TweenService:Create(statusDot, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 120)}):Play()
            for _, child in ipairs(powerStroke:GetChildren()) do
                if child:IsA("UIGradient") then child:Destroy() end
            end
            for _, child in ipairs(statusDot:GetChildren()) do
                if child:IsA("UIGradient") then child:Destroy() end
            end
            powerStroke.Color = Color3.fromRGB(80, 80, 100)
        end
    end

    powerButton.MouseButton1Click:Connect(function()
        autoGrabEnabled = not autoGrabEnabled
        updatePowerButton(autoGrabEnabled)
        toggleAutoGrab(autoGrabEnabled)
    end)

    local radiusContainer = Instance.new("Frame")
    radiusContainer.Name = "RadiusContainer"
    radiusContainer.Size = UDim2.new(0, baseWidth - 24, 0, isMobile and 32 or 38)
    radiusContainer.Position = UDim2.new(0.5, 0, 1, -(isMobile and 48 or 56))
    radiusContainer.AnchorPoint = Vector2.new(0.5, 0)
    radiusContainer.BackgroundColor3 = Theme.Background2
    radiusContainer.Parent = autoGrabProgressFrame
    Instance.new("UICorner", radiusContainer).CornerRadius = UDim.new(0, 10)
    
    local radiusStroke = Instance.new("UIStroke")
    radiusStroke.Color = Color3.fromRGB(60, 80, 120)
    radiusStroke.Thickness = 2
    radiusStroke.Transparency = 0.4
    radiusStroke.Parent = radiusContainer
    createRainbowGradient(radiusStroke, 1.3)
    
    local radiusLabel = Instance.new("TextLabel")
    radiusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    radiusLabel.Position = UDim2.new(0, 10, 0, 0)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Text = "RADIUS"
    radiusLabel.TextColor3 = Theme.TextSecondary
    radiusLabel.Font = Enum.Font.GothamBold
    radiusLabel.TextSize = isMobile and 9 or 11
    radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
    radiusLabel.Parent = radiusContainer
    
    local radiusBox = Instance.new("TextBox")
    radiusBox.Name = "RadiusBox"
    radiusBox.Size = UDim2.new(0, isMobile and 36 or 42, 0, isMobile and 22 or 26)
    radiusBox.Position = UDim2.new(1, -10, 0.5, 0)
    radiusBox.AnchorPoint = Vector2.new(1, 0.5)
    radiusBox.BackgroundColor3 = Theme.Background3
    radiusBox.BorderSizePixel = 0
    radiusBox.Text = tostring(GRAB_RADIUS)
    radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    radiusBox.Font = Enum.Font.GothamBold
    radiusBox.TextSize = isMobile and 12 or 14
    radiusBox.TextXAlignment = Enum.TextXAlignment.Center
    radiusBox.PlaceholderText = "20"
    radiusBox.ClearTextOnFocus = false
    radiusBox.Parent = radiusContainer
    Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)
    createRainbowGradient(radiusBox, 2.5)

    radiusBox.FocusLost:Connect(function()
        local newRadius = tonumber(radiusBox.Text)
        if newRadius and newRadius >= 5 then
            GRAB_RADIUS = math.floor(newRadius)
            config.grabRadius = GRAB_RADIUS
            saveConfig(config)
            radiusBox.Text = tostring(GRAB_RADIUS)
            updateRadiusCircle()
        else
            radiusBox.Text = tostring(GRAB_RADIUS)
        end
    end)

    if config.autoGrabEnabled then
        autoGrabEnabled = true
        updatePowerButton(true)
        task.spawn(function()
            task.wait(1.5)
            toggleAutoGrab(true)
        end)
    end
end

-- ========================
-- PROGRESS FUNCTIONS
-- ========================
local function updateAutoGrabProgress(progress)
    if not circularProgressFill or not progressText then return end
    progress = math.clamp(progress, 0, 100)
    
    TweenService:Create(circularProgressFill, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, progress / 100, 0)
    }):Play()
    
    progressText.Text = math.floor(progress) .. "%"
    
    if progress >= 100 then
        local scaleTween = TweenService:Create(circularProgress, 
            TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        scaleTween:Play()
        scaleTween.Completed:Wait()
        TweenService:Create(circularProgress, 
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.9, 0, 0.9, 0)}
        ):Play()
    end
end

local function hideAutoGrabProgress()
    updateAutoGrabProgress(0)
    isActivelyGrabbing = false
    grabStartTime = nil
    currentGrabTarget = nil
end

-- ========================
-- GAME LOGIC FUNCTIONS
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

    local uid = animalData.uid
    if uid and cachedPrompts[uid] and cachedPrompts[uid].Parent then
        if isGrabPrompt(cachedPrompts[uid]) then
            return cachedPrompts[uid]
        else
            cachedPrompts[uid] = nil
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

    local attach = spawn:FindFirstChild("PromptAttachment")
    if attach then
        for _, p in ipairs(attach:GetChildren()) do
            if p:IsA("ProximityPrompt") and isGrabPrompt(p) then
                if uid then cachedPrompts[uid] = p end
                return p
            end
        end
    end

    for _, c in ipairs(spawn:GetChildren()) do
        if c:IsA("ProximityPrompt") and isGrabPrompt(c) then
            if uid then cachedPrompts[uid] = c end
            return c
        end
    end

    return nil
end

local function buildGrabCallbacks(prompt)
    if not prompt then return nil end
    if internalGrabCache[prompt] then return internalGrabCache[prompt] end

    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}

    local ok, conns = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok and conns then
        for _, conn in ipairs(conns) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end

    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and conns2 then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end

    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        internalGrabCache[prompt] = data
        return data
    end

    return nil
end

local function runCallbackList(list)
    for _, fn in ipairs(list) do
        task.spawn(fn)
    end
end

local function executeGrab(prompt, animalData)
    if not prompt then return false end

    local data = buildGrabCallbacks(prompt)
    if not data or not data.ready then return false end

    data.ready = false
    isActivelyGrabbing = true
    grabStartTime = tick()
    currentGrabTarget = animalData

    updateAutoGrabProgress(0)

    task.spawn(function()
        runCallbackList(data.holdCallbacks)

        local elapsed = 0
        while elapsed < GRAB_DURATION and isActivelyGrabbing do
            task.wait(0.03)
            elapsed = tick() - grabStartTime
            local progress = math.min((elapsed / GRAB_DURATION) * 100, 100)
            updateAutoGrabProgress(progress)
        end

        runCallbackList(data.triggerCallbacks)

        updateAutoGrabProgress(100)
        task.wait(0.2)

        isActivelyGrabbing = false
        grabStartTime = nil
        currentGrabTarget = nil
        data.ready = true

        task.wait(0.15)
        if not isActivelyGrabbing then
            hideAutoGrabProgress()
        end
    end)

    return true
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end

    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end

    for _, podium in ipairs(podiums:GetChildren()) do
        if not podium:IsA("Model") then continue end

        local hasAnimal = false
        local animalName = nil

        local base = podium:FindFirstChild("Base")
        if base then
            local spawn = base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        hasAnimal = true
                        animalName = child.Name
                        break
                    end
                end
            end
        end

        if not hasAnimal then
            for _, part in ipairs(podium:GetDescendants()) do
                if part:IsA("Model") and part.Name ~= "Base" and part.Name ~= "Spawn" then
                    hasAnimal = true
                    animalName = part.Name
                    break
                end
            end
        end

        if hasAnimal then
            table.insert(allAnimalsCache, {
                name = animalName or podium.Name,
                plot = plot.Name,
                slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local function initializeScanner()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        plots = workspace:WaitForChild("Plots", 10)
    end
    if not plots then return end

    allAnimalsCache = {}
    for _, plot in ipairs(plots:GetChildren()) do
        scanSinglePlot(plot)
    end

    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then
            task.wait(0.5)
            scanSinglePlot(plot)
        end
    end)

    task.spawn(function()
        while task.wait(5) do
            if not autoGrabEnabled then continue end
            allAnimalsCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                scanSinglePlot(plot)
            end
        end
    end)
end

local function shouldGrab(animalData)
    if not animalData or not animalData.worldPosition then return false end

    local hrp = getHRP()
    if not hrp then return false end

    local currentDistance = (hrp.Position - animalData.worldPosition).Magnitude
    return currentDistance <= GRAB_RADIUS
end

local function getNearestAnimal()
    local hrp = getHRP()
    if not hrp then return nil end

    local nearest = nil
    local minDist = math.huge

    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBase(animalData.plot) then continue end

        if animalData.worldPosition then
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
-- MAIN AUTO GRAB LOOP
-- ========================
local function autoGrabLoop()
    if grabConnection then grabConnection:Disconnect() grabConnection = nil end
    if not autoGrabEnabled then return end

    grabConnection = RunService.Heartbeat:Connect(function()
        if not autoGrabEnabled then return end
        if not shouldUpdate("autoGrab", 0.03) then return end
        if isActivelyGrabbing then return end

        local now = tick()
        if now - lastGrabAttempt < GRAB_COOLDOWN then return end

        local target = getNearestAnimal()
        if not target then
            updateAutoGrabProgress(0)
            return
        end

        if not shouldGrab(target) then
            updateAutoGrabProgress(0)
            return
        end

        local prompt = findPromptForAnimal(target)
        if prompt and prompt.Enabled then
            lastGrabAttempt = now
            executeGrab(prompt, target)
        else
            updateAutoGrabProgress(0)
        end
    end)
end

-- ========================
-- TOGGLE FUNCTION
-- ========================
function toggleAutoGrab(state)
    autoGrabEnabled = state
    config.autoGrabEnabled = state
    saveConfig(config)

    if state then
        if not game:IsLoaded() then game.Loaded:Wait() end
        if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end

        cachedPrompts = {}
        internalGrabCache = {}
        lastGrabAttempt = 0

        updateAutoGrabProgress(0)
        updateRadiusCircle()

        task.spawn(autoGrabLoop)
    else
        hideAutoGrabProgress()
        destroyCircleParts()

        animalScannerRunning = false
        isActivelyGrabbing = false
        grabStartTime = nil
        currentGrabTarget = nil

        if grabConnection then
            grabConnection:Disconnect()
            grabConnection = nil
        end

        cachedPrompts = {}
    end
end

-- ========================
-- CHARACTER HANDLING
-- ========================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    isActivelyGrabbing = false
    grabStartTime = nil
    currentGrabTarget = nil

    if autoGrabEnabled then
        toggleAutoGrab(false)
        task.wait(0.2)
        toggleAutoGrab(true)
    end
end)

screenGui.Destroying:Connect(function()
    destroyCircleParts()
    animalScannerRunning = false
    isActivelyGrabbing = false
    if grabConnection then grabConnection:Disconnect() end
    if autoGrabProgressFrame then autoGrabProgressFrame:Destroy() end
end)

-- ========================
-- INITIALIZATION
-- ========================
createAutoGrabUI()

task.spawn(function()
    task.wait(2)
    initializeScanner()
end)

-- ========================
-- EXPORT FUNCTIONS
-- ========================
return {
    toggle = toggleAutoGrab,
    getStatus = function() return autoGrabEnabled end,
    setRadius = function(newRadius)
        if newRadius and newRadius >= 5 then
            GRAB_RADIUS = newRadius
            config.grabRadius = newRadius
            saveConfig(config)
            updateRadiusCircle()
            return true
        end
        return false
    end,
    cleanup = function()
        destroyCircleParts()
        animalScannerRunning = false
        isActivelyGrabbing = false
        if grabConnection then grabConnection:Disconnect() end
        if screenGui then screenGui:Destroy() end
    end
}