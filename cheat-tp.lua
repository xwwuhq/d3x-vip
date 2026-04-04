task.spawn(function()
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local s = isMobile and 0.65 or 1 -- UI Scale factor

local function waitForCharacter()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        return char
    end
    return Player.CharacterAdded:Wait()
end

task.spawn(function()
    waitForCharacter()
end)

if not getgenv then
    getgenv = function() return _G end
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local ConfigFileName = "7XXHQ_Hub_Config.json"

local Enabled = {
    SpeedBoost = false,
    AntiRagdoll = false,
    SpinBot = false,
    SpeedWhileStealing = false,
    AutoSteal = false,
    Unwalk = false,
    Optimizer = false,
    Galaxy = false,
    SpamBat = false,
    BatAimbot = false,
    GalaxySkyBright = false,
    AutoWalkEnabled = false,
    AutoRightEnabled = false,
    AutoPlayLeftEnabled = false,
    AutoPlayRightEnabled = false,
    InfJump = false,
    ESP = false,
    Hover = false,
    Stats = false,
    SpeedMeter = false
}

local Values = {
    BoostSpeed = 30,
    SpinSpeed = 30,
    StealingSpeedValue = 29,
    STEAL_RADIUS = 20,
    STEAL_DURATION = 1.3,
    AutoLeftSpeed = 59.5,
    AutoRightSpeed = 59.5,
    AutoWalkReturnSpeed = 30,
    AutoPlayReturnSpeed = 30,
    AutoWalkWaitTime = 1.0,
    AutoPlayWaitTime = 1.0,
    AutoPlayExitDist = 6.0,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70,
    HOP_POWER = 35,
    HOP_COOLDOWN = 0.08,
    FOV = 105.8,
    HoverHeight = 15
}

local KEYBINDS = {
    SPEED = Enum.KeyCode.V,
    SPIN = Enum.KeyCode.N,
    GALAXY = Enum.KeyCode.M,
    BATAIMBOT = Enum.KeyCode.X,
    NUKE = Enum.KeyCode.Q,
    AUTOLEFT = Enum.KeyCode.Z,
    AUTORIGHT = Enum.KeyCode.C,
    AUTOPLAYLEFT = Enum.KeyCode.F10,
    AUTOPLAYRIGHT = Enum.KeyCode.F11,
    ANTIRAGDOLL = Enum.KeyCode.F1,
    SPEEDSTEAL = Enum.KeyCode.F2,
    AUTOSTEAL = Enum.KeyCode.F3,
    UNWALK = Enum.KeyCode.F4,
    OPTIMIZER = Enum.KeyCode.F5,
    SPAMBAT = Enum.KeyCode.F6,
    GALAXY_SKY = Enum.KeyCode.F7,
    INFJUMP = Enum.KeyCode.F8,
    ESP = Enum.KeyCode.P,
    HOVER = Enum.KeyCode.G,
    STATS = Enum.KeyCode.F9,
    SPEEDMETER = Enum.KeyCode.J
}

local CurrentThemeIndex = 1
local isRainbow = false
local CurrentBgEffectIndex = 1

local configLoaded = false
pcall(function()
    if readfile and isfile and isfile(ConfigFileName) then
        local data = HttpService:JSONDecode(readfile(ConfigFileName))
        if data then
            for k, v in pairs(data) do
                if Enabled[k] ~= nil then Enabled[k] = v end
            end
            for k, v in pairs(data) do
                if Values[k] ~= nil then Values[k] = v end
            end
            if data.KEY_SPEED then KEYBINDS.SPEED = Enum.KeyCode[data.KEY_SPEED] end
            if data.KEY_SPIN then KEYBINDS.SPIN = Enum.KeyCode[data.KEY_SPIN] end
            if data.KEY_GALAXY then KEYBINDS.GALAXY = Enum.KeyCode[data.KEY_GALAXY] end
            if data.KEY_BATAIMBOT then KEYBINDS.BATAIMBOT = Enum.KeyCode[data.KEY_BATAIMBOT] end
            if data.KEY_AUTOLEFT then KEYBINDS.AUTOLEFT = Enum.KeyCode[data.KEY_AUTOLEFT] end
            if data.KEY_AUTORIGHT then KEYBINDS.AUTORIGHT = Enum.KeyCode[data.KEY_AUTORIGHT] end
            if data.KEY_AUTOPLAYLEFT then KEYBINDS.AUTOPLAYLEFT = Enum.KeyCode[data.KEY_AUTOPLAYLEFT] end
            if data.KEY_AUTOPLAYRIGHT then KEYBINDS.AUTOPLAYRIGHT = Enum.KeyCode[data.KEY_AUTOPLAYRIGHT] end
            if data.KEY_ANTIRAGDOLL then KEYBINDS.ANTIRAGDOLL = Enum.KeyCode[data.KEY_ANTIRAGDOLL] end
            if data.KEY_SPEEDSTEAL then KEYBINDS.SPEEDSTEAL = Enum.KeyCode[data.KEY_SPEEDSTEAL] end
            if data.KEY_AUTOSTEAL then KEYBINDS.AUTOSTEAL = Enum.KeyCode[data.KEY_AUTOSTEAL] end
            if data.KEY_UNWALK then KEYBINDS.UNWALK = Enum.KeyCode[data.KEY_UNWALK] end
            if data.KEY_OPTIMIZER then KEYBINDS.OPTIMIZER = Enum.KeyCode[data.KEY_OPTIMIZER] end
            if data.KEY_SPAMBAT then KEYBINDS.SPAMBAT = Enum.KeyCode[data.KEY_SPAMBAT] end
            if data.KEY_GALAXY_SKY then KEYBINDS.GALAXY_SKY = Enum.KeyCode[data.KEY_GALAXY_SKY] end
            if data.KEY_INFJUMP then KEYBINDS.INFJUMP = Enum.KeyCode[data.KEY_INFJUMP] end
            if data.KEY_ESP then KEYBINDS.ESP = Enum.KeyCode[data.KEY_ESP] end
            if data.KEY_HOVER then KEYBINDS.HOVER = Enum.KeyCode[data.KEY_HOVER] end
            if data.KEY_STATS then KEYBINDS.STATS = Enum.KeyCode[data.KEY_STATS] end
            if data.KEY_SPEEDMETER then KEYBINDS.SPEEDMETER = Enum.KeyCode[data.KEY_SPEEDMETER] end
            
            if data.CurrentThemeIndex then CurrentThemeIndex = data.CurrentThemeIndex end
            if data.isRainbow ~= nil then isRainbow = data.isRainbow end
            if data.CurrentBgEffectIndex then CurrentBgEffectIndex = data.CurrentBgEffectIndex end
            
            configLoaded = true
        end
    end
end)

local function SaveConfig()
    local data = {}
    for k, v in pairs(Enabled) do data[k] = v end
    for k, v in pairs(Values) do data[k] = v end
    data.KEY_SPEED = KEYBINDS.SPEED.Name
    data.KEY_SPIN = KEYBINDS.SPIN.Name
    data.KEY_GALAXY = KEYBINDS.GALAXY.Name
    data.KEY_BATAIMBOT = KEYBINDS.BATAIMBOT.Name
    data.KEY_AUTOLEFT = KEYBINDS.AUTOLEFT.Name
    data.KEY_AUTORIGHT = KEYBINDS.AUTORIGHT.Name
    data.KEY_AUTOPLAYLEFT = KEYBINDS.AUTOPLAYLEFT.Name
    data.KEY_AUTOPLAYRIGHT = KEYBINDS.AUTOPLAYRIGHT.Name
    data.KEY_ANTIRAGDOLL = KEYBINDS.ANTIRAGDOLL.Name
    data.KEY_SPEEDSTEAL = KEYBINDS.SPEEDSTEAL.Name
    data.KEY_AUTOSTEAL = KEYBINDS.AUTOSTEAL.Name
    data.KEY_UNWALK = KEYBINDS.UNWALK.Name
    data.KEY_OPTIMIZER = KEYBINDS.OPTIMIZER.Name
    data.KEY_SPAMBAT = KEYBINDS.SPAMBAT.Name
    data.KEY_GALAXY_SKY = KEYBINDS.GALAXY_SKY.Name
    data.KEY_INFJUMP = KEYBINDS.INFJUMP.Name
    data.KEY_ESP = KEYBINDS.ESP.Name
    data.KEY_HOVER = KEYBINDS.HOVER.Name
    data.KEY_STATS = KEYBINDS.STATS.Name
    data.KEY_SPEEDMETER = KEYBINDS.SPEEDMETER.Name
    
    data.CurrentThemeIndex = CurrentThemeIndex
    data.isRainbow = isRainbow
    data.CurrentBgEffectIndex = CurrentBgEffectIndex
    
    local success = false
    if writefile then
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(data))
            success = true
        end)
    end
    return success
end

local Connections = {}
local isStealing = false
local lastBatSwing = 0
local BAT_SWING_COOLDOWN = 0.12

local SlapList = {
    {1, "Bat"}, {2, "Slap"}, {3, "Iron Slap"}, {4, "Gold Slap"},
    {5, "Diamond Slap"}, {6, "Emerald Slap"}, {7, "Ruby Slap"},
    {8, "Dark Matter Slap"}, {9, "Flame Slap"}, {10, "Nuclear Slap"},
    {11, "Galaxy Slap"}, {12, "Glitched Slap"}
}

local ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
local REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
local BALLOON_REMOTE = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_ID, true)

local function INSTANT_NUKE(target)
    if not BALLOON_REMOTE or not target then return end
    for _, p in ipairs({"balloon", "ragdoll", "jumpscare", "morph", "tiny", "rocket", "inverse", "jail"}) do
        BALLOON_REMOTE:FireServer(ADMIN_KEY, target, p)
    end
end

local function getNearestPlayer()
    local c = Player.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local pos = h.Position
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local oh = p.Character:FindFirstChild("HumanoidRootPart")
            if oh then
                local d = (pos - oh.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function findBat()
    local c = Player.Character
    if not c then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    for _, i in ipairs(SlapList) do
        local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
        if t then return t end
    end
    return nil
end

local function startSpamBat()
    if Connections.spamBat then return end
    Connections.spamBat = RunService.Heartbeat:Connect(function()
        if not Enabled.SpamBat then return end
        local c = Player.Character
        if not c then return end
        local bat = findBat()
        if not bat then return end
        if bat.Parent ~= c then bat.Parent = c end
        local now = tick()
        if now - lastBatSwing < BAT_SWING_COOLDOWN then return end
        lastBatSwing = now
        pcall(function() bat:Activate() end)
    end)
end

local function stopSpamBat()
    if Connections.spamBat then Connections.spamBat:Disconnect() Connections.spamBat = nil end
end

local spinBAV = nil
local function startSpinBot()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if spinBAV then spinBAV:Destroy() spinBAV = nil end
    for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
    spinBAV = Instance.new("BodyAngularVelocity")
    spinBAV.Name = "SpinBAV"
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    spinBAV.Parent = hrp
end

local function stopSpinBot()
    if spinBAV then spinBAV:Destroy() spinBAV = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Enabled.SpinBot and spinBAV then
        if Player:GetAttribute("Stealing") then
            spinBAV.AngularVelocity = Vector3.new(0, 0, 0)
        else
            spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
        end
    end
end)

local speedMeterConnection = nil
local speedMeterGui = nil

local function toggleSpeedMeter(state)
    if speedMeterConnection then
        speedMeterConnection:Disconnect()
        speedMeterConnection = nil
    end
    if speedMeterGui then
        speedMeterGui:Destroy()
        speedMeterGui = nil
    end

    if state then
        local char = Player.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        
        speedMeterGui = Instance.new("BillboardGui")
        speedMeterGui.Name = "7XXHQSpeedMeter"
        speedMeterGui.Adornee = head
        speedMeterGui.Size = UDim2.new(0, 150, 0, 40)
        speedMeterGui.StudsOffset = Vector3.new(0, 3.5, 0)
        speedMeterGui.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel", speedMeterGui)
        textLabel.Name = "SpeedText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Speed: 0"
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16 * s
        
        local successHl, _ = pcall(function() speedMeterGui.Parent = game:GetService("CoreGui") end)
        if not successHl then speedMeterGui.Parent = Player:WaitForChild("PlayerGui") end
        
        speedMeterConnection = RunService.Heartbeat:Connect(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = Player.Character.HumanoidRootPart
            if speedMeterGui and speedMeterGui:FindFirstChild("SpeedText") then
                local horizontalVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                local speed = math.round(horizontalVelocity.Magnitude)
                speedMeterGui.SpeedText.Text = "Speed: " .. tostring(speed)
            end
        end)
    end
end

local aimbotConnection = nil
local lockedTarget = nil
local AIMBOT_SPEED = 60
local MELEE_OFFSET = 3
local MAX_DISTANCE = math.huge 

local aimbotHighlight = Instance.new("Highlight")
aimbotHighlight.Name = "AimbotTargetESP"
aimbotHighlight.FillColor = Color3.fromRGB(255, 0, 0)
aimbotHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
aimbotHighlight.FillTransparency = 0.5
aimbotHighlight.OutlineTransparency = 0
local successHl, _ = pcall(function() aimbotHighlight.Parent = game:GetService("CoreGui") end)
if not successHl then aimbotHighlight.Parent = Player:WaitForChild("PlayerGui") end

local function isTargetValid(targetChar)
    if not targetChar then return false end
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local ff = targetChar:FindFirstChildOfClass("ForceField")
    return hum and hrp and hum.Health > 0 and not ff
end

local function getBestTarget(myHRP)
    if lockedTarget and isTargetValid(lockedTarget) then
        return lockedTarget:FindFirstChild("HumanoidRootPart"), lockedTarget
    end

    local shortestDistance = MAX_DISTANCE
    local newTargetChar = nil
    local newTargetHRP = nil

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and isTargetValid(targetPlayer.Character) then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = (targetHRP.Position - myHRP.Position).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                newTargetHRP = targetHRP
                newTargetChar = targetPlayer.Character
            end
        end
    end
    
    lockedTarget = newTargetChar
    return newTargetHRP, newTargetChar
end

local function startBatAimbot()
    if aimbotConnection then return end
    
    local c = Player.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    
    hum.AutoRotate = false
    local attachment = h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment", h)
    attachment.Name = "AimbotAttachment"
    
    local align = h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation", h)
    align.Name = "AimbotAlign"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0 = attachment
    align.MaxTorque = math.huge
    align.Responsiveness = 200
    
    aimbotConnection = RunService.Heartbeat:Connect(function(dt)
        if not Enabled.BatAimbot then return end
        
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local currentHRP = Player.Character.HumanoidRootPart
        local currentHum = Player.Character:FindFirstChildOfClass("Humanoid")
        
        local bat = findBat()
        if bat and bat.Parent ~= Player.Character then currentHum:EquipTool(bat) end
        
        local targetHRP, targetChar = getBestTarget(currentHRP)
        
        if targetHRP and targetChar then
            aimbotHighlight.Adornee = targetChar
            
            local targetVelocity = targetHRP.AssemblyLinearVelocity
            local speed = targetVelocity.Magnitude
            local dynamicPredictTime = math.clamp(speed / 150, 0.05, 0.2)
            
            local predictedPos = targetHRP.Position + (targetVelocity * dynamicPredictTime)
            
            local dirToTarget = (predictedPos - currentHRP.Position)
            local distance3D = dirToTarget.Magnitude
            
            local targetStandPos = predictedPos
            if distance3D > 0 then
                targetStandPos = predictedPos - (dirToTarget.Unit * MELEE_OFFSET)
            end

            align.CFrame = CFrame.lookAt(currentHRP.Position, predictedPos)
            
            local moveDir = (targetStandPos - currentHRP.Position)
            local distToStandPos = moveDir.Magnitude
            
            if distToStandPos > 1 then
                currentHRP.AssemblyLinearVelocity = moveDir.Unit * AIMBOT_SPEED
            else
                currentHRP.AssemblyLinearVelocity = targetVelocity
            end
        else
            lockedTarget = nil
            currentHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            aimbotHighlight.Adornee = nil
        end
    end)
end

local function stopBatAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    
    if h then
        local att = h:FindFirstChild("AimbotAttachment")
        if att then att:Destroy() end
        
        local align = h:FindFirstChild("AimbotAlign")
        if align then align:Destroy() end
        
        h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if hum then
        hum.AutoRotate = true
    end
    
    lockedTarget = nil
    aimbotHighlight.Adornee = nil
end

local galaxyVectorForce, galaxyAttachment, galaxyEnabled, hopsEnabled = nil, nil, false, false
local lastHopTime, spaceHeld, originalJumpPower = 0, false, 50

local function captureJumpPower()
    local c = Player.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.JumpPower > 0 then originalJumpPower = hum.JumpPower end
    end
end
task.spawn(function() task.wait(1) captureJumpPower() end)
Player.CharacterAdded:Connect(function() task.wait(1) captureJumpPower() end)

local function setupGalaxyForce()
    pcall(function()
        local c = Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if galaxyVectorForce then galaxyVectorForce:Destroy() end
        if galaxyAttachment then galaxyAttachment:Destroy() end
        galaxyAttachment = Instance.new("Attachment", h)
        galaxyVectorForce = Instance.new("VectorForce", h)
        galaxyVectorForce.Attachment0 = galaxyAttachment
        galaxyVectorForce.ApplyAtCenterOfMass = true
        galaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        galaxyVectorForce.Force = Vector3.new(0, 0, 0)
    end)
end

local function updateGalaxyForce()
    if not galaxyEnabled or not galaxyVectorForce then return end
    local c = Player.Character
    if not c then return end
    local mass = 0
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
    local tg = Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent / 100)
    galaxyVectorForce.Force = Vector3.new(0, mass * (Values.DEFAULT_GRAVITY - tg) * 0.95, 0)
end

local function adjustGalaxyJump()
    pcall(function()
        local c = Player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if not galaxyEnabled then hum.JumpPower = originalJumpPower return end
        local ratio = math.sqrt((Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent / 100)) / Values.DEFAULT_GRAVITY)
        hum.JumpPower = originalJumpPower * ratio
    end)
end

local function doMiniHop()
    if not hopsEnabled then return end
    pcall(function()
        local c = Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if tick() - lastHopTime < Values.HOP_COOLDOWN then return end
        lastHopTime = tick()
        if hum.FloorMaterial == Enum.Material.Air then
            h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
        end
    end)
end

local function startGalaxy() galaxyEnabled = true hopsEnabled = true setupGalaxyForce() adjustGalaxyJump() end
local function stopGalaxy()
    galaxyEnabled = false hopsEnabled = false
    if galaxyVectorForce then galaxyVectorForce:Destroy() galaxyVectorForce = nil end
    if galaxyAttachment then galaxyAttachment:Destroy() galaxyAttachment = nil end
    adjustGalaxyJump()
end

RunService.Heartbeat:Connect(function()
    if hopsEnabled and spaceHeld then doMiniHop() end
    if galaxyEnabled then updateGalaxyForce() end
end)

local function getMovementDirection()
    local c = Player.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedBoost then return end
        pcall(function()
            local c = Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local md = getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(md.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * Values.BoostSpeed)
            end
        end)
    end)
end
local function stopSpeedBoost() if Connections.speed then Connections.speed:Disconnect() Connections.speed = nil end end

local hoverTargetY = 0
local function ToggleHover(state)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        hoverTargetY = hrp.Position.Y + Values.HoverHeight
    else
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -10, hrp.AssemblyLinearVelocity.Z) end
    end
end

RunService.Heartbeat:Connect(function()
    if Enabled.Hover then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local myY = hrp.Position.Y
            local error = hoverTargetY - myY
            local currentY = math.clamp(error * 10, -50, 50)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, currentY, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

local POSITION_1 = Vector3.new(-476.48, -6.28, 92.73)
local POSITION_2 = Vector3.new(-483.12, -4.95, 94.80)
local POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)

local dirL = (Vector3.new(POSITION_1.X, 0, POSITION_1.Z) - Vector3.new(POSITION_2.X, 0, POSITION_2.Z)).Unit
local dirR = (Vector3.new(POSITION_R1.X, 0, POSITION_R1.Z) - Vector3.new(POSITION_R2.X, 0, POSITION_R2.Z)).Unit

local function GET_POS_1_OUT() return POSITION_1 + (dirL * Values.AutoPlayExitDist) end
local function GET_POS_R1_OUT() return POSITION_R1 + (dirR * Values.AutoPlayExitDist) end

local coordESPFolder = Instance.new("Folder", workspace)
coordESPFolder.Name = "7XXHQ_CoordESP"

local function createCoordMarker(position, labelText, color)
    local dot = Instance.new("Part", coordESPFolder)
    dot.Name = "CoordMarker_" .. labelText
    dot.Anchored = true dot.CanCollide = false dot.CastShadow = false
    dot.Material = Enum.Material.Neon dot.Color = color dot.Shape = Enum.PartType.Ball
    dot.Size = Vector3.new(1, 1, 1) dot.Position = position dot.Transparency = 0.2

    local bb = Instance.new("BillboardGui", dot)
    bb.AlwaysOnTop = true bb.Size = UDim2.new(0, 100, 0, 20) bb.StudsOffset = Vector3.new(0, 2, 0)
    
    local text = Instance.new("TextLabel", bb)
    text.Size = UDim2.new(1, 0, 1, 0) text.BackgroundTransparency = 1 text.Text = labelText
    text.TextColor3 = color text.Font = Enum.Font.GothamBold text.TextSize = 12
    return dot
end

createCoordMarker(POSITION_1, "L1", Color3.fromRGB(255, 100, 100))
createCoordMarker(POSITION_2, "L END", Color3.fromRGB(220, 20, 60))
createCoordMarker(POSITION_R1, "R1", Color3.fromRGB(255, 150, 50))
createCoordMarker(POSITION_R2, "R END", Color3.fromRGB(220, 100, 30))

local autoWalkPhase, autoRightPhase = 1, 1
local autoPlayLeftPhase, autoPlayRightPhase = 1, 1

local AutoWalkEnabled, AutoRightEnabled = false, false
local AutoPlayLeftEnabled, AutoPlayRightEnabled = false, false

local autoWalkConnection, autoRightConnection = nil, nil
local autoPlayLeftConnection, autoPlayRightConnection = nil, nil

local function faceCam(angleY)
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local camera = workspace.CurrentCamera
    if camera then
        if angleY == 0 then
            camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 5, h.Position.Z - 12) * CFrame.Angles(math.rad(-15), 0, 0)
        else
            camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 2, h.Position.Z + 12) * CFrame.Angles(0, math.rad(180), 0)
        end
    end
end

local autoPlayLeftWait = false
local autoPlayLeftWaitStart = 0

local function startAutoPlayLeft()
    if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() end
    autoPlayLeftPhase = 1
    autoPlayLeftWait = false
    autoPlayLeftWaitStart = 0
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then
        local walkOri = h:FindFirstChild("AutoWalkOri")
        if not walkOri then
            local walkAtt = Instance.new("Attachment", h)
            walkAtt.Name = "AutoWalkAtt"
            walkOri = Instance.new("AlignOrientation", h)
            walkOri.Name = "AutoWalkOri"
            walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            walkOri.Attachment0 = walkAtt
            walkOri.MaxTorque = math.huge
            walkOri.Responsiveness = 200
        end
    end

    local sequence = {GET_POS_1_OUT, POSITION_1, POSITION_2, POSITION_1, GET_POS_1_OUT, GET_POS_R1_OUT, POSITION_R1, POSITION_R2}

    autoPlayLeftConnection = RunService.Heartbeat:Connect(function()
        if not AutoPlayLeftEnabled then return end
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local wo = hrp:FindFirstChild("AutoWalkOri")
        
        if autoPlayLeftWait then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            if tick() - autoPlayLeftWaitStart >= Values.AutoPlayWaitTime then
                autoPlayLeftWait = false
                autoPlayLeftPhase = autoPlayLeftPhase + 1
            end
            return
        end
        
        if autoPlayLeftPhase <= #sequence then
            local targetPos = sequence[autoPlayLeftPhase]
            if type(targetPos) == "function" then targetPos = targetPos() end
            
            local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
            
            if dist < 1 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if autoPlayLeftPhase == 3 then
                    autoPlayLeftWait = true
                    autoPlayLeftWaitStart = tick()
                else
                    autoPlayLeftPhase = autoPlayLeftPhase + 1
                end
            else
                local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                
                local speedToUse = (autoPlayLeftPhase >= 4) and Values.AutoPlayReturnSpeed or Values.AutoLeftSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * speedToUse, hrp.AssemblyLinearVelocity.Y, moveDir.Z * speedToUse)
            end
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            AutoPlayLeftEnabled, Enabled.AutoPlayLeftEnabled = false, false
            if VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(false) end
            if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() autoPlayLeftConnection = nil end
            local wa = hrp:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
            faceCam(0)
        end
    end)
end

local function stopAutoPlayLeft()
    if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() autoPlayLeftConnection = nil end
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
        local wo = h:FindFirstChild("AutoWalkOri")
        local wa = h:FindFirstChild("AutoWalkAtt")
        if wo then wo:Destroy() end
        if wa then wa:Destroy() end
    end
end

local autoPlayRightWait = false
local autoPlayRightWaitStart = 0

local function startAutoPlayRight()
    if autoPlayRightConnection then autoPlayRightConnection:Disconnect() end
    autoPlayRightPhase = 1
    autoPlayRightWait = false
    autoPlayRightWaitStart = 0
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then
        local walkOri = h:FindFirstChild("AutoWalkOri")
        if not walkOri then
            local walkAtt = Instance.new("Attachment", h)
            walkAtt.Name = "AutoWalkAtt"
            walkOri = Instance.new("AlignOrientation", h)
            walkOri.Name = "AutoWalkOri"
            walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            walkOri.Attachment0 = walkAtt
            walkOri.MaxTorque = math.huge
            walkOri.Responsiveness = 200
        end
    end

    local sequence = {GET_POS_R1_OUT, POSITION_R1, POSITION_R2, POSITION_R1, GET_POS_R1_OUT, GET_POS_1_OUT, POSITION_1, POSITION_2}

    autoPlayRightConnection = RunService.Heartbeat:Connect(function()
        if not AutoPlayRightEnabled then return end
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local wo = hrp:FindFirstChild("AutoWalkOri")
        
        if autoPlayRightWait then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            if tick() - autoPlayRightWaitStart >= Values.AutoPlayWaitTime then
                autoPlayRightWait = false
                autoPlayRightPhase = autoPlayRightPhase + 1
            end
            return
        end
        
        if autoPlayRightPhase <= #sequence then
            local targetPos = sequence[autoPlayRightPhase]
            if type(targetPos) == "function" then targetPos = targetPos() end
            
            local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
            
            if dist < 1 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if autoPlayRightPhase == 3 then
                    autoPlayRightWait = true
                    autoPlayRightWaitStart = tick()
                else
                    autoPlayRightPhase = autoPlayRightPhase + 1
                end
            else
                local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                
                local speedToUse = (autoPlayRightPhase >= 4) and Values.AutoPlayReturnSpeed or Values.AutoRightSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * speedToUse, hrp.AssemblyLinearVelocity.Y, moveDir.Z * speedToUse)
            end
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            AutoPlayRightEnabled, Enabled.AutoPlayRightEnabled = false, false
            if VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(false) end
            if autoPlayRightConnection then autoPlayRightConnection:Disconnect() autoPlayRightConnection = nil end
            local wa = hrp:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
            faceCam(math.rad(180))
        end
    end)
end

local function stopAutoPlayRight()
    if autoPlayRightConnection then autoPlayRightConnection:Disconnect() autoPlayRightConnection = nil end
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
        local wo = h:FindFirstChild("AutoWalkOri")
        local wa = h:FindFirstChild("AutoWalkAtt")
        if wo then wo:Destroy() end
        if wa then wa:Destroy() end
    end
end

local function startAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect() end
    autoWalkPhase = 1
    local waitStartTime = 0
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then
        local walkOri = h:FindFirstChild("AutoWalkOri")
        if not walkOri then
            local walkAtt = Instance.new("Attachment", h)
            walkAtt.Name = "AutoWalkAtt"
            walkOri = Instance.new("AlignOrientation", h)
            walkOri.Name = "AutoWalkOri"
            walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            walkOri.Attachment0 = walkAtt
            walkOri.MaxTorque = math.huge
            walkOri.Responsiveness = 200
        end
    end

    autoWalkConnection = RunService.Heartbeat:Connect(function()
        if not AutoWalkEnabled then return end
        local c = Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        
        local wo = h:FindFirstChild("AutoWalkOri")
        local pos1 = POSITION_1
        local pos2 = POSITION_2
        
        if autoWalkPhase == 1 then
            local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
            if dist < 1 then
                autoWalkPhase = 2
            else
                local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoLeftSpeed)
            end
            
        elseif autoWalkPhase == 2 then
            local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
            if dist < 1 then
                autoWalkPhase = 3
                waitStartTime = tick()
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            else
                local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoLeftSpeed)
            end
            
        elseif autoWalkPhase == 3 then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            if tick() - waitStartTime >= Values.AutoWalkWaitTime then
                autoWalkPhase = 4
            end
            
        elseif autoWalkPhase == 4 then
            local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
            if dist < 1 then
                autoWalkPhase = 5
            else
                local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoWalkReturnSpeed)
            end
            
        elseif autoWalkPhase == 5 then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            AutoWalkEnabled, Enabled.AutoWalkEnabled = false, false
            if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(false) end
            if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection = nil end
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
            faceCam(0)
        end
    end)
end

local function stopAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection = nil end
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
        local wo = h:FindFirstChild("AutoWalkOri")
        local wa = h:FindFirstChild("AutoWalkAtt")
        if wo then wo:Destroy() end
        if wa then wa:Destroy() end
    end
end

local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase = 1
    local waitStartTime = 0
    
    local c = Player.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then
        local walkOri = h:FindFirstChild("AutoWalkOri")
        if not walkOri then
            local walkAtt = Instance.new("Attachment", h)
            walkAtt.Name = "AutoWalkAtt"
            walkOri = Instance.new("AlignOrientation", h)
            walkOri.Name = "AutoWalkOri"
            walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            walkOri.Attachment0 = walkAtt
            walkOri.MaxTorque = math.huge
            walkOri.Responsiveness = 200
        end
    end

    autoRightConnection = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c = Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        
        local wo = h:FindFirstChild("AutoWalkOri")
        local pos1 = POSITION_R1
        local pos2 = POSITION_R2
        
        if autoRightPhase == 1 then
            local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
            if dist < 1 then
                autoRightPhase = 2
            else
                local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoRightSpeed)
            end
            
        elseif autoRightPhase == 2 then
            local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
            if dist < 1 then
                autoRightPhase = 3
                waitStartTime = tick()
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            else
                local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoRightSpeed)
            end
            
        elseif autoRightPhase == 3 then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            if tick() - waitStartTime >= Values.AutoWalkWaitTime then
                autoRightPhase = 4
            end
            
        elseif autoRightPhase == 4 then
            local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
            if dist < 1 then
                autoRightPhase = 5
            else
                local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                local moveDir = flatDir.Unit
                if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.AutoWalkReturnSpeed)
            end
            
        elseif autoRightPhase == 5 then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            AutoRightEnabled, Enabled.AutoRightEnabled = false, false
            if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false) end
            if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection = nil end
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
            faceCam(math.rad(180))
        end
    end)
end

local function stopAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection = nil end
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
        local wo = h:FindFirstChild("AutoWalkOri")
        local wa = h:FindFirstChild("AutoWalkAtt")
        if wo then wo:Destroy() end
        if wa then wa:Destroy() end
    end
end

local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if Player.Character then
                        local PlayerModule = Player.PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                            Controls:Enable()
                        end
                    end
                end)
                if root then
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end
local function stopAntiRagdoll() if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect() Connections.antiRagdoll = nil end end

local function startSpeedWhileStealing()
    if Connections.speedWhileStealing then return end
    Connections.speedWhileStealing = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedWhileStealing or not Player:GetAttribute("Stealing") then return end
        local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local md = getMovementDirection()
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(md.X * Values.StealingSpeedValue, h.AssemblyLinearVelocity.Y, md.Z * Values.StealingSpeedValue)
        end
    end)
end
local function stopSpeedWhileStealing() if Connections.speedWhileStealing then Connections.speedWhileStealing:Disconnect() end end

local radiusVisualizer = Instance.new("Part")
radiusVisualizer.Name = "ZyphrotRadiusVisualizer"
radiusVisualizer.Shape = Enum.PartType.Cylinder
radiusVisualizer.CanCollide = false
radiusVisualizer.Anchored = true
radiusVisualizer.CastShadow = false
radiusVisualizer.Material = Enum.Material.ForceField
radiusVisualizer.Color = Color3.fromRGB(220, 20, 60)
radiusVisualizer.Transparency = 0.5

RunService.Heartbeat:Connect(function()
    if Enabled.AutoSteal and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        if radiusVisualizer.Parent ~= workspace then radiusVisualizer.Parent = workspace end
        radiusVisualizer.Size = Vector3.new(0.05, Values.STEAL_RADIUS * 2, Values.STEAL_RADIUS * 2)
        radiusVisualizer.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, 0) * CFrame.Angles(0, 0, math.rad(90))
    else
        if radiusVisualizer.Parent then radiusVisualizer.Parent = nil end
    end
end)

local StealData = {}
local isStealing = false
local StealProgress = 0
local autoStealGui = nil
local barFill = nil

local function createAutoStealUI()
    if autoStealGui then return end
    autoStealGui = Instance.new("ScreenGui", Player.PlayerGui)
    autoStealGui.Name = "ZyphrotAutoStealUI"
    autoStealGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame", autoStealGui)
    mainFrame.Size = UDim2.new(0, 240, 0, 45) 
    mainFrame.Position = UDim2.fromScale(0.5, 0.4)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    mainFrame.Active = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    MakeDraggable(mainFrame) 
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(220, 20, 60)
    
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0.15, 0)
    title.BackgroundTransparency = 1
    title.Text = "7XXHQ HUB"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local barBg = Instance.new("Frame", mainFrame)
    barBg.Size = UDim2.new(0.9, 0, 0, 1) 
    barBg.Position = UDim2.new(0.05, 0, 0.75, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    
    barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
end

local function removeAutoStealUI()
    if autoStealGui then
        autoStealGui:Destroy()
        autoStealGui = nil
        barFill = nil
    end
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    local sign = plots and plots:FindFirstChild(pn) and plots[pn]:FindFirstChild("PlotSign")
    return sign and sign:FindFirstChild("YourBase") and sign.YourBase:IsA("BillboardGui") and sign.YourBase.Enabled
end

local function findNearestPrompt()
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("Plots")
    if not h or not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local spawn = pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(StealData[prompt].hold, c.Function) end end
                for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(StealData[prompt].trigger, c.Function) end end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false isStealing = true
    
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        
        local startTime = tick()
        local duration = Values.STEAL_DURATION
        if duration > 0 then
            while tick() - startTime < duration do
                if not isStealing then break end
                StealProgress = math.clamp((tick() - startTime) / duration, 0, 1)
                if barFill then barFill.Size = UDim2.new(StealProgress, 0, 1, 0) end
                task.wait()
            end
        end
        
        StealProgress = 1
        if barFill then barFill.Size = UDim2.new(1, 0, 1, 0) end
        
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        
        task.wait(0.2)
        StealProgress = 0
        if barFill then barFill.Size = UDim2.new(0, 0, 1, 0) end
        
        data.ready = true 
        isStealing = false
    end)
end

local function startAutoSteal()
    if Connections.autoSteal then return end
    createAutoStealUI()
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal() 
    if Connections.autoSteal then Connections.autoSteal:Disconnect() Connections.autoSteal = nil end 
    isStealing = false 
    removeAutoStealUI()
end

local savedAnimations = {}
local function startUnwalk()
    local c = Player.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c and c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate = anim:Clone() anim:Destroy() end
end
local function stopUnwalk()
    local c = Player.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent = c savedAnimations.Animate = nil end
end

local originalTransparency, xrayEnabled = {}, false
local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false Lighting.Brightness = 3 Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                elseif obj:IsA("BasePart") then obj.CastShadow = false obj.Material = Enum.Material.Plastic end
            end)
        end
    end)
    xrayEnabled = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
end
local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do if part then part.LocalTransparencyModifier = value end end
        originalTransparency, xrayEnabled = {}, false
    end
end

local originalSkybox, galaxySkyBright, galaxySkyBrightConn, galaxyPlanets, galaxyBloom, galaxyCC = nil, nil, nil, {}, nil, nil
local function enableGalaxySkyBright()
    if galaxySkyBright then return end
    originalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if originalSkybox then originalSkybox.Parent = nil end
    
    galaxySkyBright = Instance.new("Sky", Lighting)
    galaxySkyBright.SkyboxBk, galaxySkyBright.SkyboxDn, galaxySkyBright.SkyboxFt = "rbxassetid://1534951537", "rbxassetid://1534951537", "rbxassetid://1534951537"
    galaxySkyBright.SkyboxLf, galaxySkyBright.SkyboxRt, galaxySkyBright.SkyboxUp = "rbxassetid://1534951537", "rbxassetid://1534951537", "rbxassetid://1534951537"
    galaxySkyBright.StarCount = 10000 galaxySkyBright.CelestialBodiesShown = false
    
    galaxyBloom = Instance.new("BloomEffect", Lighting) galaxyBloom.Intensity, galaxyBloom.Size, galaxyBloom.Threshold = 1.5, 40, 0.8
    galaxyCC = Instance.new("ColorCorrectionEffect", Lighting) galaxyCC.Saturation, galaxyCC.Contrast, galaxyCC.TintColor = Color3.fromRGB(200, 150, 255)
    
    Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime = Color3.fromRGB(120, 60, 180), 3, 0
    
    galaxySkyBrightConn = RunService.Heartbeat:Connect(function()
        if not Enabled.GalaxySkyBright then return end
        local t = tick() * 0.5
        Lighting.Ambient = Color3.fromRGB(120 + math.sin(t) * 60, 50 + math.sin(t * 0.8) * 40, 180 + math.sin(t * 1.2) * 50)
        if galaxyBloom then galaxyBloom.Intensity = 1.2 + math.sin(t * 2) * 0.4 end
    end)
end

local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect() galaxySkyBrightConn = nil end
    if galaxySkyBright then galaxySkyBright:Destroy() galaxySkyBright = nil end
    if originalSkybox then originalSkybox.Parent = Lighting end
    if galaxyBloom then galaxyBloom:Destroy() galaxyBloom = nil end
    if galaxyCC then galaxyCC:Destroy() galaxyCC = nil end
    Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime = Color3.fromRGB(127, 127, 127), 2, 14
end

local fovConnection = nil
local function updateFOV()
    local cam = workspace.CurrentCamera
    if cam and cam.FieldOfView ~= Values.FOV then
        cam.FieldOfView = Values.FOV
    end
end
local function hookFOV()
    if fovConnection then fovConnection:Disconnect() end
    local cam = workspace.CurrentCamera
    if cam then
        fovConnection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(updateFOV)
        updateFOV()
    end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookFOV)
hookFOV()

UserInputService.JumpRequest:Connect(function()
    if Enabled.InfJump then
        local c = Player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

local espConnections = {}
local function createESP(plr)
    if plr == Player or not plr.Character then return end
    local char = plr.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or char:FindFirstChild("ZyphrotHitbox") then return end
    
    local h = Instance.new("BoxHandleAdornment", char)
    h.Name = "ZyphrotHitbox"
    h.Adornee = hrp
    h.Size = Vector3.new(4, 6, 2)
    h.Color3 = Color3.fromRGB(128, 0, 128)
    h.Transparency = 0.6
    h.ZIndex = 10
    h.AlwaysOnTop = true
    
    local b = Instance.new("BillboardGui", char)
    b.Name = "ZyphrotName"
    b.Adornee = char:FindFirstChild("Head") or hrp
    b.Size = UDim2.new(0, 200, 0, 50)
    b.StudsOffset = Vector3.new(0, 3, 0)
    b.AlwaysOnTop = true
    
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = plr.DisplayName
    l.TextColor3 = Color3.fromRGB(255,0,255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
end

local function toggleESP(state)
    if not state then
        for _, p in ipairs(Players:GetPlayers()) do 
            if p.Character then 
                local hb = p.Character:FindFirstChild("ZyphrotHitbox")
                local nm = p.Character:FindFirstChild("ZyphrotName")
                if hb then hb:Destroy() end 
                if nm then nm:Destroy() end 
            end 
        end
        for _, c in ipairs(espConnections) do c:Disconnect() end
        espConnections = {}
    else
        for _, p in ipairs(Players:GetPlayers()) do 
            createESP(p)
            table.insert(espConnections, p.CharacterAdded:Connect(function() 
                task.wait(0.5) 
                if Enabled.ESP then createESP(p) end 
            end)) 
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(function(p) 
            table.insert(espConnections, p.CharacterAdded:Connect(function() 
                task.wait(0.5) 
                if Enabled.ESP then createESP(p) end 
            end)) 
        end))
    end
end

local Themes = {
    ["Crimson Red"] = { P = Color3.fromRGB(220, 20, 60), L = Color3.fromRGB(255, 60, 90), D = Color3.fromRGB(150, 15, 40) },
    ["Cyberpunk Yellow"] = { P = Color3.fromRGB(255, 215, 0), L = Color3.fromRGB(255, 235, 100), D = Color3.fromRGB(180, 150, 0) },
    ["Neon Green"] = { P = Color3.fromRGB(50, 255, 50), L = Color3.fromRGB(100, 255, 100), D = Color3.fromRGB(20, 180, 20) },
    ["Royal Purple"] = { P = Color3.fromRGB(138, 43, 226), L = Color3.fromRGB(170, 80, 255), D = Color3.fromRGB(90, 20, 150) }
}
local ThemeNames = {"Crimson Red", "Cyberpunk Yellow", "Neon Green", "Royal Purple", "Rainbow Mode"}

local C = {
    bg = Color3.fromRGB(12, 12, 15),
    sidebar = Color3.fromRGB(18, 18, 22),
    primary = Themes["Crimson Red"].P, 
    primaryLight = Themes["Crimson Red"].L,
    primaryDark = Themes["Crimson Red"].D,
    text = Color3.fromRGB(245, 245, 245),
    textMuted = Color3.fromRGB(130, 130, 140),
    elementBg = Color3.fromRGB(24, 24, 28),
    border = Color3.fromRGB(40, 40, 48),
    success = Color3.fromRGB(40, 200, 100)
}

local ThemeUpdateFuncs = {}

local function UpdateThemeColors(p, l, d)
    C.primary = p
    C.primaryLight = l
    C.primaryDark = d
    for _, func in ipairs(ThemeUpdateFuncs) do
        func(p, l, d)
    end
end

RunService.RenderStepped:Connect(function()
    if isRainbow then
        local hue = tick() % 5 / 5
        local rgb = Color3.fromHSV(hue, 1, 1)
        local light = Color3.fromHSV(hue, 0.6, 1)
        local dark = Color3.fromHSV(hue, 1, 0.5)
        UpdateThemeColors(rgb, light, dark)
    end
end)

local bgEffects = {"Stars", "Matrix", "Grid", "Pulse", "Snow", "Circles", "None"}

local sg = Instance.new("ScreenGui", Player.PlayerGui)
sg.Name = "7XXHQHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true 

local function playSound(id, vol)
    pcall(function()
        local sound = Instance.new("Sound", SoundService)
        sound.SoundId = id sound.Volume = vol or 0.3 sound:Play()
        game:GetService("Debris"):AddItem(sound, 1)
    end)
end

local guiVisible = true

local function attachRipple(btn, targetFrame)
    targetFrame = targetFrame or btn
    targetFrame.ClipsDescendants = true
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            task.spawn(function()
                local ripple = Instance.new("Frame", targetFrame)
                ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                
                local x = input.Position.X - targetFrame.AbsolutePosition.X
                local y = input.Position.Y - targetFrame.AbsolutePosition.Y
                ripple.Position = UDim2.new(0, x, 0, y)
                ripple.ZIndex = targetFrame.ZIndex + 1
                ripple.BackgroundTransparency = 0.6
                Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
                
                local maxSize = math.max(targetFrame.AbsoluteSize.X, targetFrame.AbsoluteSize.Y) * 2
                local t = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, maxSize, 0, maxSize),
                    BackgroundTransparency = 1
                })
                t:Play()
                task.wait(0.4)
                ripple:Destroy()
            end)
        end
    end)
end

local toggleMenuBtn = Instance.new("TextButton", sg)
toggleMenuBtn.Size = UDim2.new(0, 45, 0, 45)
toggleMenuBtn.Position = UDim2.new(1, -65, 0, 15) 
toggleMenuBtn.BackgroundColor3 = C.elementBg
toggleMenuBtn.Text = "7X"
toggleMenuBtn.TextColor3 = C.primary
toggleMenuBtn.Font = Enum.Font.GothamBlack
toggleMenuBtn.TextSize = 18
toggleMenuBtn.BackgroundTransparency = 0.1
toggleMenuBtn.ZIndex = 10 
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 8)
attachRipple(toggleMenuBtn)

local toggleStroke = Instance.new("UIStroke", toggleMenuBtn)
toggleStroke.Thickness = 2
local toggleGradient = Instance.new("UIGradient", toggleStroke)
toggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.primaryLight),
    ColorSequenceKeypoint.new(0.5, C.border),
    ColorSequenceKeypoint.new(1, C.primaryDark)
})

table.insert(ThemeUpdateFuncs, function(p, l, d)
    if toggleMenuBtn.Parent then
        toggleMenuBtn.TextColor3 = p
        toggleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, l),
            ColorSequenceKeypoint.new(0.5, C.border),
            ColorSequenceKeypoint.new(1, d)
        })
    end
end)

local mobileShortcuts = {}
if isMobile then
    local baseY = 0.58 
    
    local hoverBtn = Instance.new("TextButton", sg)
    hoverBtn.Size = UDim2.new(0, 50, 0, 50)
    hoverBtn.Position = UDim2.new(1, -125, baseY, -120) 
    hoverBtn.BackgroundColor3 = C.elementBg
    hoverBtn.Text = "Hover"
    hoverBtn.TextColor3 = C.primaryLight
    hoverBtn.Font = Enum.Font.GothamBold
    hoverBtn.TextSize = 11
    hoverBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", hoverBtn).CornerRadius = UDim.new(0, 10)
    local hoverStroke = Instance.new("UIStroke", hoverBtn)
    hoverStroke.Color = C.border
    hoverStroke.Thickness = 1.5
    attachRipple(hoverBtn)

    local batBtn = Instance.new("TextButton", sg)
    batBtn.Size = UDim2.new(0, 50, 0, 50)
    batBtn.Position = UDim2.new(1, -65, baseY, -120) 
    batBtn.BackgroundColor3 = C.elementBg
    batBtn.Text = "Auto Bat"
    batBtn.TextColor3 = C.primaryLight
    batBtn.Font = Enum.Font.GothamBold
    batBtn.TextSize = 11
    batBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", batBtn).CornerRadius = UDim.new(0, 10)
    local batStroke = Instance.new("UIStroke", batBtn)
    batStroke.Color = C.border
    batStroke.Thickness = 1.5
    attachRipple(batBtn)

    local playLeftBtn = Instance.new("TextButton", sg)
    playLeftBtn.Size = UDim2.new(0, 50, 0, 50)
    playLeftBtn.Position = UDim2.new(1, -125, baseY, -60) 
    playLeftBtn.BackgroundColor3 = C.elementBg
    playLeftBtn.Text = "Play L"
    playLeftBtn.TextColor3 = C.text
    playLeftBtn.Font = Enum.Font.GothamBold
    playLeftBtn.TextSize = 12
    playLeftBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", playLeftBtn).CornerRadius = UDim.new(0, 10)
    local playLeftStroke = Instance.new("UIStroke", playLeftBtn)
    playLeftStroke.Color = C.border
    playLeftStroke.Thickness = 1.5
    attachRipple(playLeftBtn)
    
    local playRightBtn = Instance.new("TextButton", sg)
    playRightBtn.Size = UDim2.new(0, 50, 0, 50)
    playRightBtn.Position = UDim2.new(1, -65, baseY, -60) 
    playRightBtn.BackgroundColor3 = C.elementBg
    playRightBtn.Text = "Play R"
    playRightBtn.TextColor3 = C.text
    playRightBtn.Font = Enum.Font.GothamBold
    playRightBtn.TextSize = 12
    playRightBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", playRightBtn).CornerRadius = UDim.new(0, 10)
    local playRightStroke = Instance.new("UIStroke", playRightBtn)
    playRightStroke.Color = C.border
    playRightStroke.Thickness = 1.5
    attachRipple(playRightBtn)

    local leftBtn = Instance.new("TextButton", sg)
    leftBtn.Size = UDim2.new(0, 50, 0, 50)
    leftBtn.Position = UDim2.new(1, -125, baseY, 0) 
    leftBtn.BackgroundColor3 = C.elementBg
    leftBtn.Text = "Auto L"
    leftBtn.TextColor3 = C.text
    leftBtn.Font = Enum.Font.GothamBold
    leftBtn.TextSize = 12
    leftBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 10)
    local leftStroke = Instance.new("UIStroke", leftBtn)
    leftStroke.Color = C.border
    leftStroke.Thickness = 1.5
    attachRipple(leftBtn)
    
    local rightBtn = Instance.new("TextButton", sg)
    rightBtn.Size = UDim2.new(0, 50, 0, 50)
    rightBtn.Position = UDim2.new(1, -65, baseY, 0) 
    rightBtn.BackgroundColor3 = C.elementBg
    rightBtn.Text = "Auto R"
    rightBtn.TextColor3 = C.text
    rightBtn.Font = Enum.Font.GothamBold
    rightBtn.TextSize = 12
    rightBtn.BackgroundTransparency = 0.2
    Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 10)
    local rightStroke = Instance.new("UIStroke", rightBtn)
    rightStroke.Color = C.border
    rightStroke.Thickness = 1.5
    attachRipple(rightBtn)
    
    local hoverGrad = Instance.new("UIGradient", hoverStroke)
    local batGrad = Instance.new("UIGradient", batStroke)
    local leftGrad = Instance.new("UIGradient", leftStroke)
    local rightGrad = Instance.new("UIGradient", rightStroke)
    local pLeftGrad = Instance.new("UIGradient", playLeftStroke)
    local pRightGrad = Instance.new("UIGradient", playRightStroke)
    
    table.insert(ThemeUpdateFuncs, function(p, l, d)
        local cs = ColorSequence.new({ColorSequenceKeypoint.new(0, l), ColorSequenceKeypoint.new(0.5, C.border), ColorSequenceKeypoint.new(1, d)})
        if hoverGrad.Parent then hoverGrad.Color = cs end
        if batGrad.Parent then batGrad.Color = cs end
        if leftGrad.Parent then leftGrad.Color = cs end
        if rightGrad.Parent then rightGrad.Color = cs end
        if pLeftGrad.Parent then pLeftGrad.Color = cs end
        if pRightGrad.Parent then pRightGrad.Color = cs end
    end)
    
    task.spawn(function()
        local r = 0
        while sg.Parent do
            r = (r + 1.5) % 360
            hoverGrad.Rotation = r; batGrad.Rotation = r; 
            leftGrad.Rotation = r; rightGrad.Rotation = r;
            pLeftGrad.Rotation = r; pRightGrad.Rotation = r;
            task.wait(0.02)
        end
    end)

    mobileShortcuts.hover = hoverBtn
    mobileShortcuts.bat = batBtn
    mobileShortcuts.left = leftBtn
    mobileShortcuts.right = rightBtn
    mobileShortcuts.playLeft = playLeftBtn
    mobileShortcuts.playRight = playRightBtn
end

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 650 * s, 0, 420 * s)
main.Position = UDim2.new(0.5, -325 * s, 0.5, -210 * s)
main.BackgroundColor3 = C.bg
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8 * s)

MakeDraggable(main)

local bgContainer = Instance.new("Frame", main)
bgContainer.Name = "BgContainer"
bgContainer.Size = UDim2.new(1, 0, 1, 0)
bgContainer.BackgroundTransparency = 1
bgContainer.ZIndex = 1
bgContainer.ClipsDescendants = true

local currentBgLoopId = 0

local function StartBackgroundEffect()
    currentBgLoopId = currentBgLoopId + 1
    local loopId = currentBgLoopId
    bgContainer:ClearAllChildren()
    
    if CurrentBgEffect == "Stars" then
        task.spawn(function()
            while loopId == currentBgLoopId and bgContainer.Parent do
                local size = math.random(2, 6) * s 
                local star = Instance.new("Frame", bgContainer)
                star.Size = UDim2.new(0, size, 0, size)
                star.Position = UDim2.new(math.random(1, 1000)/1000, 0, 1.1, 0)
                star.BackgroundColor3 = math.random(1, 3) == 1 and C.primaryLight or Color3.fromRGB(255, 255, 255)
                star.BorderSizePixel = 0
                star.ZIndex = 1
                star.BackgroundTransparency = 0
                Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
                
                local glow = Instance.new("UIStroke", star)
                glow.Color = star.BackgroundColor3
                glow.Thickness = size / 1.5
                glow.Transparency = 0.6
                
                local duration = math.random(6, 14)
                local startX = star.Position.X.Scale
                local endX = startX + (math.random(-10, 10) / 100) 
                
                TweenService:Create(star, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(endX, 0, -0.2, 0)
                }):Play()
                
                task.spawn(function()
                    local elapsed = 0
                    while star and star.Parent and elapsed < duration do
                        TweenService:Create(star, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.8}):Play()
                        TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
                        task.wait(1)
                        if not star or not star.Parent then break end
                        TweenService:Create(star, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.6}):Play()
                        task.wait(1)
                        elapsed = elapsed + 2
                    end
                end)
                task.delay(duration, function() if star then star:Destroy() end end)
                task.wait(0.15) 
            end
        end)
        
    elseif CurrentBgEffect == "Matrix" then
        task.spawn(function()
            while loopId == currentBgLoopId and bgContainer.Parent do
                local char = string.char(math.random(33, 126))
                local startX = math.random(1, 1000)/1000
                local duration = math.random(3, 7)
                
                local label = Instance.new("TextLabel", bgContainer)
                label.Text = char
                label.TextColor3 = C.primaryLight
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(0, 15, 0, 15)
                label.Position = UDim2.new(startX, 0, -0.1, 0)
                label.Font = Enum.Font.Code
                label.TextSize = 14 * s
                label.ZIndex = 1
                
                TweenService:Create(label, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(startX, 0, 1.1, 0),
                    TextTransparency = 1
                }):Play()
                task.delay(duration, function() if label then label:Destroy() end end)
                task.wait(0.05)
            end
        end)
        
    elseif CurrentBgEffect == "Grid" then
        local grid = Instance.new("Frame", bgContainer)
        grid.Size = UDim2.new(1, 0, 1, 0)
        grid.BackgroundTransparency = 1
        
        for i = 1, 10 do
            local hLine = Instance.new("Frame", grid)
            hLine.Size = UDim2.new(1, 0, 0, 1)
            hLine.Position = UDim2.new(0, 0, i/10, 0)
            hLine.BackgroundColor3 = C.primary
            hLine.BackgroundTransparency = 0.8
            hLine.BorderSizePixel = 0
            table.insert(ThemeUpdateFuncs, function(p) if hLine.Parent then hLine.BackgroundColor3 = p end end)
            
            local vLine = Instance.new("Frame", grid)
            vLine.Size = UDim2.new(0, 1, 1, 0)
            vLine.Position = UDim2.new(i/10, 0, 0, 0)
            vLine.BackgroundColor3 = C.primary
            vLine.BackgroundTransparency = 0.8
            vLine.BorderSizePixel = 0
            table.insert(ThemeUpdateFuncs, function(p) if vLine.Parent then vLine.BackgroundColor3 = p end end)
        end
        
        task.spawn(function()
            local offset = 0
            while loopId == currentBgLoopId and bgContainer.Parent do
                offset = (offset + 0.001) % 0.1
                for i, child in ipairs(grid:GetChildren()) do
                    if child.Size.Y.Offset == 1 then
                        child.Position = UDim2.new(0, 0, ((math.floor((i-1)/2))/10 + offset) % 1, 0)
                    else
                        child.Position = UDim2.new(((math.floor((i-1)/2))/10 + offset) % 1, 0, 0, 0)
                    end
                end
                task.wait(0.02)
            end
        end)
        
    elseif CurrentBgEffect == "Pulse" then
        task.spawn(function()
            while loopId == currentBgLoopId and bgContainer.Parent do
                local pulse = Instance.new("Frame", bgContainer)
                pulse.AnchorPoint = Vector2.new(0.5, 0.5)
                pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
                pulse.Size = UDim2.new(0, 0, 0, 0)
                pulse.BackgroundColor3 = Color3.new(1,1,1)
                pulse.BackgroundTransparency = 1
                Instance.new("UICorner", pulse).CornerRadius = UDim.new(1, 0)
                
                local stroke = Instance.new("UIStroke", pulse)
                stroke.Color = C.primary
                stroke.Thickness = 2
                table.insert(ThemeUpdateFuncs, function(p) if stroke.Parent then stroke.Color = p end end)
                
                TweenService:Create(pulse, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1.5, 0, 1.5, 0)
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Transparency = 1
                }):Play()
                
                task.delay(3, function() if pulse then pulse:Destroy() end end)
                task.wait(1)
            end
        end)

    elseif CurrentBgEffect == "Snow" then
        task.spawn(function()
            while loopId == currentBgLoopId and bgContainer.Parent do
                local size = math.random(3, 7) * s
                local startX = math.random(1, 1000)/1000
                local endX = startX + (math.random(-20, 20) / 100)
                local duration = math.random(5, 12)
                
                local flake = Instance.new("Frame", bgContainer)
                flake.Size = UDim2.new(0, size, 0, size)
                flake.Position = UDim2.new(startX, 0, -0.1, 0)
                flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                flake.BorderSizePixel = 0
                flake.BackgroundTransparency = 0.2
                flake.ZIndex = 1
                Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)

                TweenService:Create(flake, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(endX, 0, 1.1, 0),
                    BackgroundTransparency = 1
                }):Play()

                task.delay(duration, function() if flake then flake:Destroy() end end)
                task.wait(0.1)
            end
        end)

    elseif CurrentBgEffect == "Circles" then
        task.spawn(function()
            while loopId == currentBgLoopId and bgContainer.Parent do
                local posX = math.random(10, 90)/100
                local posY = math.random(10, 90)/100
                local targetSize = math.random(50, 150) * s
                local duration = math.random(2, 4)
                
                local circle = Instance.new("Frame", bgContainer)
                circle.AnchorPoint = Vector2.new(0.5, 0.5)
                circle.Position = UDim2.new(posX, 0, posY, 0)
                circle.Size = UDim2.new(0, 0, 0, 0)
                circle.BackgroundColor3 = C.primary
                circle.BackgroundTransparency = 1
                circle.ZIndex = 1
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

                local stroke = Instance.new("UIStroke", circle)
                stroke.Color = C.primary
                stroke.Thickness = 2
                stroke.Transparency = 0
                table.insert(ThemeUpdateFuncs, function(p) if stroke.Parent then stroke.Color = p end end)

                TweenService:Create(circle, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, targetSize, 0, targetSize)
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Transparency = 1
                }):Play()

                task.delay(duration, function() if circle then circle:Destroy() end end)
                task.wait(0.4)
            end
        end)
    end
end

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 2
local mainGradient = Instance.new("UIGradient", mainStroke)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.primaryLight),
    ColorSequenceKeypoint.new(0.5, C.border),
    ColorSequenceKeypoint.new(1, C.primaryDark)
})

table.insert(ThemeUpdateFuncs, function(p, l, d)
    if mainGradient.Parent then
        mainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, l),
            ColorSequenceKeypoint.new(0.5, C.border),
            ColorSequenceKeypoint.new(1, d)
        })
    end
end)

toggleMenuBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    main.Visible = guiVisible
    playSound("rbxassetid://6895079813", 0.4)
end)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160 * s, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BackgroundTransparency = 0.1
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8 * s)

local sidebarFix = Instance.new("Frame", sidebar)
sidebarFix.Size = UDim2.new(0, 10 * s, 1, 0)
sidebarFix.Position = UDim2.new(1, -10 * s, 0, 0)
sidebarFix.BackgroundColor3 = C.sidebar
sidebarFix.BackgroundTransparency = 0.1
sidebarFix.BorderSizePixel = 0
sidebarFix.ZIndex = 2

local logoTitle = Instance.new("TextLabel", sidebar)
logoTitle.Size = UDim2.new(1, 0, 0, 60 * s)
logoTitle.BackgroundTransparency = 1
logoTitle.Text = "7XXHQ"
logoTitle.TextColor3 = Color3.new(1, 1, 1) 
logoTitle.Font = Enum.Font.GothamBlack
logoTitle.TextSize = 22 * s
logoTitle.ZIndex = 2

local titleGrad = Instance.new("UIGradient", logoTitle)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.primaryLight),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, C.primaryDark)
})

local logoSub = Instance.new("TextLabel", logoTitle)
logoSub.Size = UDim2.new(1, 0, 1, 25 * s)
logoSub.BackgroundTransparency = 1
logoSub.Text = "HUB"
logoSub.TextColor3 = Color3.new(1, 1, 1) 
logoSub.Font = Enum.Font.GothamBold
logoSub.TextSize = 14 * s
logoSub.ZIndex = 2

local subGrad = Instance.new("UIGradient", logoSub)
subGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.primaryLight),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, C.primaryDark)
})

table.insert(ThemeUpdateFuncs, function(p, l, d)
    local cs = ColorSequence.new({ColorSequenceKeypoint.new(0, l), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, d)})
    if titleGrad.Parent then titleGrad.Color = cs end
    if subGrad.Parent then subGrad.Color = cs end
end)

task.spawn(function()
    local r = 0
    while sg.Parent do
        r = (r + 1.5) % 360
        mainGradient.Rotation = r
        toggleGradient.Rotation = -r
        if titleGrad then titleGrad.Rotation = r end
        if subGrad then subGrad.Rotation = r end
        task.wait(0.02)
    end
end)

local separatorLine = Instance.new("Frame", sidebar)
separatorLine.Size = UDim2.new(0.8, 0, 0, 2 * s)
separatorLine.Position = UDim2.new(0.1, 0, 0, 55 * s) 
separatorLine.BackgroundColor3 = C.border
separatorLine.BackgroundTransparency = 0.5
separatorLine.BorderSizePixel = 0
separatorLine.ZIndex = 2

local tabContainer = Instance.new("Frame", sidebar)
tabContainer.Size = UDim2.new(1, 0, 1, -140 * s) 
tabContainer.Position = UDim2.new(0, 0, 0, 65 * s) 
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 2

local userInfoFrame = Instance.new("Frame", sidebar)
userInfoFrame.Size = UDim2.new(1, 0, 0, 60 * s)
userInfoFrame.Position = UDim2.new(0, 0, 1, -60 * s)
userInfoFrame.BackgroundTransparency = 1
userInfoFrame.ZIndex = 2

local userAvatar = Instance.new("ImageLabel", userInfoFrame)
userAvatar.Size = UDim2.new(0, 32 * s, 0, 32 * s)
userAvatar.Position = UDim2.new(0, 12 * s, 0.5, -16 * s)
userAvatar.BackgroundColor3 = C.elementBg
userAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
userAvatar.ZIndex = 2
Instance.new("UICorner", userAvatar).CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", userAvatar)
avatarStroke.Color = C.primary
avatarStroke.Thickness = 1.5

table.insert(ThemeUpdateFuncs, function(p, l, d)
    if avatarStroke.Parent then avatarStroke.Color = p end
end)

local welcomeLabel = Instance.new("TextLabel", userInfoFrame)
welcomeLabel.Size = UDim2.new(1, -55 * s, 0, 12 * s)
welcomeLabel.Position = UDim2.new(0, 52 * s, 0.5, -20 * s)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Loading..."
welcomeLabel.TextColor3 = C.primaryLight
welcomeLabel.Font = Enum.Font.GothamMedium
welcomeLabel.TextSize = 9 * s
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.ZIndex = 2

table.insert(ThemeUpdateFuncs, function(p, l, d)
    if welcomeLabel.Parent then welcomeLabel.TextColor3 = l end
end)

task.spawn(function()
    while sg.Parent do
        local hour = tonumber(os.date("%H"))
        local newGreeting = ""
        if hour >= 5 and hour < 12 then
            newGreeting = "Good Morning,"
        elseif hour >= 12 and hour < 17 then
            newGreeting = "Good Afternoon,"
        elseif hour >= 17 and hour < 21 then
            newGreeting = "Good Evening,"
        else
            newGreeting = "Good Night,"
        end
        
        if welcomeLabel.Text ~= newGreeting then
            welcomeLabel.Text = newGreeting
        end
        task.wait(10)
    end
end)

local userName = Instance.new("TextLabel", userInfoFrame)
userName.Size = UDim2.new(1, -55 * s, 0, 15 * s)
userName.Position = UDim2.new(0, 52 * s, 0.5, -6 * s)
userName.BackgroundTransparency = 1
userName.Text = Player.Name
userName.TextColor3 = C.text
userName.Font = Enum.Font.GothamBold
userName.TextSize = 11 * s
userName.TextXAlignment = Enum.TextXAlignment.Left
userName.TextTruncate = Enum.TextTruncate.AtEnd
userName.ZIndex = 2

local userRole = Instance.new("TextLabel", userInfoFrame)
userRole.Size = UDim2.new(1, -55 * s, 0, 15 * s)
userRole.Position = UDim2.new(0, 52 * s, 0.5, 6 * s)
userRole.BackgroundTransparency = 1
userRole.Text = "Premium"
userRole.TextColor3 = C.textMuted
userRole.Font = Enum.Font.GothamMedium
userRole.TextSize = 10 * s
userRole.TextXAlignment = Enum.TextXAlignment.Left
userRole.ZIndex = 2

local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -160 * s, 1, 0)
contentArea.Position = UDim2.new(0, 160 * s, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.ZIndex = 2

local pages = {}
local tabButtons = {}
local activeTab = nil

local function switchTab(tabName)
    if activeTab == tabName then return end
    activeTab = tabName
    for name, page in pairs(pages) do 
        if name == tabName then
            page.Visible = true
            page.Position = UDim2.new(0, 40 * s, 0, 10 * s) 
            TweenService:Create(page, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 10 * s, 0, 10 * s)}):Play()
        else
            page.Visible = false
        end
    end
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.elementBg, TextColor3 = C.text}):Play()
            TweenService:Create(btn.GlowEffect, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(btn.UIStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            btn.Indicator.Visible = true
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.sidebar, TextColor3 = C.textMuted}):Play()
            TweenService:Create(btn.GlowEffect, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(btn.UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            btn.Indicator.Visible = false
        end
    end
    playSound("rbxassetid://6895079813", 0.2)
end

local function createTab(name)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(1, -20 * s, 0, 40 * s)
    btn.Position = UDim2.new(0, 10 * s, 0, #tabContainer:GetChildren() * (50 * s))
    btn.BackgroundColor3 = C.sidebar
    btn.Text = "   " .. name
    btn.TextColor3 = C.textMuted
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14 * s
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * s)
    attachRipple(btn)
    
    local glow = Instance.new("Frame", btn)
    glow.Name = "GlowEffect"
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = C.primary
    glow.BackgroundTransparency = 1
    glow.ZIndex = 1
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 6 * s)
    
    local strk = Instance.new("UIStroke", btn)
    strk.Name = "UIStroke"
    strk.Color = C.primaryLight
    strk.Thickness = 1.5
    strk.Transparency = 1
    
    local indicator = Instance.new("Frame", btn)
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 4 * s, 0, 20 * s)
    indicator.Position = UDim2.new(0, 0, 0.5, -10 * s)
    indicator.BackgroundColor3 = C.primary
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 2
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 4 * s)
    
    table.insert(ThemeUpdateFuncs, function(p, l, d)
        if glow.Parent then glow.BackgroundColor3 = p end
        if strk.Parent then strk.Color = l end
        if indicator.Parent then indicator.BackgroundColor3 = p end
    end)
    
    local page = Instance.new("ScrollingFrame", contentArea)
    page.Size = UDim2.new(1, -20 * s, 1, -20 * s)
    page.Position = UDim2.new(0, 10 * s, 0, 10 * s)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4 * s
    page.ScrollBarImageColor3 = C.border
    page.Visible = false
    page.ZIndex = 2
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8 * s)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (20 * s))
    end)
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabButtons[name] = btn
    pages[name] = page
    return page
end

VisualSetters = {}
local SliderSetters = {}
local KeyButtons = {}
local waitingForKeybind = nil

local function createToggle(page, labelText, enabledKey, keybindKey, callback)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1, -10 * s, 0, 50 * s)
    row.BackgroundColor3 = C.elementBg
    row.BackgroundTransparency = 0.55
    row.ZIndex = 2
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6 * s)
    Instance.new("UIStroke", row).Color = C.border
    
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 15 * s, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14 * s
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    
    local rightOffset = -15 * s
    local defaultOn = Enabled[enabledKey]
    
    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 44 * s, 0, 24 * s)
    toggleBg.Position = UDim2.new(1, rightOffset - (44 * s), 0.5, -12 * s)
    toggleBg.BackgroundColor3 = defaultOn and C.primary or C.sidebar
    toggleBg.ZIndex = 2
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 18 * s, 0, 18 * s)
    toggleCircle.Position = defaultOn and UDim2.new(1, -21 * s, 0.5, -9 * s) or UDim2.new(0, 3 * s, 0.5, -9 * s)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.ZIndex = 2
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)
    
    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 3
    attachRipple(clickBtn, row)
    
    local isOn = defaultOn
    
    table.insert(ThemeUpdateFuncs, function(p, l, d)
        if toggleBg.Parent and isOn then
            toggleBg.BackgroundColor3 = p
        end
    end)
    
    if keybindKey then
        local keyBtn = Instance.new("TextButton", row)
        keyBtn.Size = UDim2.new(0, 30 * s, 0, 24 * s)
        keyBtn.Position = UDim2.new(1, rightOffset - (44 * s) - (40 * s), 0.5, -12 * s)
        keyBtn.BackgroundColor3 = C.sidebar
        keyBtn.Text = KEYBINDS[keybindKey].Name
        keyBtn.TextColor3 = C.text
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 12 * s
        keyBtn.ZIndex = 3
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4 * s)
        Instance.new("UIStroke", keyBtn).Color = C.border
        KeyButtons[keybindKey] = keyBtn
        
        keyBtn.MouseButton1Click:Connect(function()
            waitingForKeybind = keybindKey
            keyBtn.Text = "..."
            playSound("rbxassetid://6895079813", 0.4)
        end)
    end
    
    local function setVisual(state, skipCallback)
        isOn = state
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = isOn and C.primary or C.sidebar}):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = isOn and UDim2.new(1, -21 * s, 0.5, -9 * s) or UDim2.new(0, 3 * s, 0.5, -9 * s)}):Play()
        if not skipCallback then callback(isOn) end
    end
    VisualSetters[enabledKey] = setVisual
    
    clickBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        Enabled[enabledKey] = isOn
        setVisual(isOn)
        playSound("rbxassetid://6895079813", 0.4)
    end)
    return setVisual
end

local function createSlider(page, labelText, minVal, maxVal, valueKey, isFloat, callback)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1, -10 * s, 0, 65 * s)
    row.BackgroundColor3 = C.elementBg
    row.BackgroundTransparency = 0.55
    row.ZIndex = 2
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6 * s)
    Instance.new("UIStroke", row).Color = C.border
    
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.5, 0, 0, 20 * s)
    label.Position = UDim2.new(0, 15 * s, 0, 10 * s)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14 * s
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    
    local defaultVal = Values[valueKey]
    
    local valueBox = Instance.new("TextBox", row)
    valueBox.Size = UDim2.new(0, 50 * s, 0, 24 * s)
    valueBox.Position = UDim2.new(1, -65 * s, 0, 8 * s)
    valueBox.BackgroundColor3 = C.sidebar
    valueBox.Text = tostring(defaultVal)
    valueBox.TextColor3 = C.primary
    valueBox.Font = Enum.Font.GothamBold
    valueBox.TextSize = 13 * s
    valueBox.ClearTextOnFocus = false
    valueBox.ZIndex = 3
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4 * s)
    Instance.new("UIStroke", valueBox).Color = C.border
    
    local sliderBg = Instance.new("Frame", row)
    sliderBg.Size = UDim2.new(1, -30 * s, 0, 6 * s)
    sliderBg.Position = UDim2.new(0, 15 * s, 0, 45 * s)
    sliderBg.BackgroundColor3 = C.sidebar
    sliderBg.ZIndex = 2
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local pct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderFill.BackgroundColor3 = C.primary
    sliderFill.ZIndex = 2
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local thumb = Instance.new("Frame", sliderBg)
    thumb.Size = UDim2.new(0, 14 * s, 0, 14 * s)
    thumb.Position = UDim2.new(pct, -7 * s, 0.5, -7 * s)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.ZIndex = 3
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    local dragBtn = Instance.new("TextButton", sliderBg)
    dragBtn.Size = UDim2.new(1, 0, 3, 0)
    dragBtn.Position = UDim2.new(0, 0, -1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.ZIndex = 4
    
    table.insert(ThemeUpdateFuncs, function(p, l, d)
        if valueBox.Parent then valueBox.TextColor3 = p end
        if sliderFill.Parent then sliderFill.BackgroundColor3 = p end
    end)
    
    local dragging = false
    local function update(rel, skipCall)
        rel = math.clamp(rel, 0, 1)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7 * s, 0.5, -7 * s)
        local val = minVal + (maxVal - minVal) * rel
        
        if not isFloat then 
            val = math.floor(val) 
        else 
            val = math.floor(val * 100) / 100 
        end
        
        valueBox.Text = tostring(val)
        Values[valueKey] = val
        if not skipCall then callback(val) end
    end
    
    dragBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update((i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X)
        end
    end)
    
    valueBox.FocusLost:Connect(function()
        local n = tonumber(valueBox.Text)
        if n then
            n = math.clamp(n, minVal, maxVal)
            if not isFloat then 
                n = math.floor(n) 
            else 
                n = math.floor(n * 100) / 100 
            end
            valueBox.Text = tostring(n)
            local r = (n - minVal) / (maxVal - minVal)
            sliderFill.Size = UDim2.new(r, 0, 1, 0)
            thumb.Position = UDim2.new(r, -7 * s, 0.5, -7 * s)
            Values[valueKey] = n
            callback(n)
        else
            valueBox.Text = tostring(Values[valueKey])
        end
    end)
    
    local function setVisualVal(v)
        local rel = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7 * s, 0.5, -7 * s)
        valueBox.Text = tostring(v)
    end
    SliderSetters[valueKey] = setVisualVal
end

local function createButton(page, text, bgCol, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(1, -10 * s, 0, 44 * s)
    btn.BackgroundColor3 = bgCol or C.elementBg
    btn.BackgroundTransparency = 0.55 
    btn.Text = text
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14 * s
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * s)
    Instance.new("UIStroke", btn).Color = C.border
    attachRipple(btn)
    
    btn.MouseButton1Click:Connect(function()
        playSound("rbxassetid://6895079813", 0.4)
        callback(btn)
    end)
    return btn
end

if isMobile then
    mobileShortcuts.hover.MouseButton1Click:Connect(function()
        local newState = not Enabled.Hover
        Enabled.Hover = newState
        if VisualSetters.Hover then VisualSetters.Hover(newState, true) end
        ToggleHover(newState)
        mobileShortcuts.hover.BackgroundColor3 = newState and C.primaryDark or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)
    
    mobileShortcuts.bat.MouseButton1Click:Connect(function()
        local newState = not Enabled.BatAimbot
        Enabled.BatAimbot = newState
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(newState, true) end
        if newState then startBatAimbot() else stopBatAimbot() end
        mobileShortcuts.bat.BackgroundColor3 = newState and C.primaryDark or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)

    mobileShortcuts.left.MouseButton1Click:Connect(function()
        local newState = not Enabled.AutoWalkEnabled
        AutoWalkEnabled, Enabled.AutoWalkEnabled = newState, newState
        if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(newState, true) end
        if newState then startAutoWalk() else stopAutoWalk() end
        mobileShortcuts.left.BackgroundColor3 = newState and C.primary or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)
    
    mobileShortcuts.right.MouseButton1Click:Connect(function()
        local newState = not Enabled.AutoRightEnabled
        AutoRightEnabled, Enabled.AutoRightEnabled = newState, newState
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(newState, true) end
        if newState then startAutoRight() else stopAutoRight() end
        mobileShortcuts.right.BackgroundColor3 = newState and C.primary or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)

    mobileShortcuts.playLeft.MouseButton1Click:Connect(function()
        local newState = not Enabled.AutoPlayLeftEnabled
        AutoPlayLeftEnabled, Enabled.AutoPlayLeftEnabled = newState, newState
        if VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(newState, true) end
        if newState then startAutoPlayLeft() else stopAutoPlayLeft() end
        mobileShortcuts.playLeft.BackgroundColor3 = newState and C.primary or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)

    mobileShortcuts.playRight.MouseButton1Click:Connect(function()
        local newState = not Enabled.AutoPlayRightEnabled
        AutoPlayRightEnabled, Enabled.AutoPlayRightEnabled = newState, newState
        if VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(newState, true) end
        if newState then startAutoPlayRight() else stopAutoPlayRight() end
        mobileShortcuts.playRight.BackgroundColor3 = newState and C.primary or C.elementBg
        playSound("rbxassetid://6895079813", 0.4)
    end)
end

local pageMovement = createTab("Movement")
local pageCombat = createTab("Combat")
local pageAuto = createTab("Automation")
local pageVisuals = createTab("World & Visuals")
local pageSettings = createTab("Settings")
switchTab("Movement")

createToggle(pageMovement, "Speed Boost", "SpeedBoost", "SPEED", function(state) if state then startSpeedBoost() else stopSpeedBoost() end end)
createSlider(pageMovement, "Boost Speed", 1, 100, "BoostSpeed", true, function(v) Values.BoostSpeed = v end)
createToggle(pageMovement, "Anti Ragdoll", "AntiRagdoll", "ANTIRAGDOLL", function(state) if state then startAntiRagdoll() else stopAntiRagdoll() end end)
createToggle(pageMovement, "Player Hover", "Hover", "HOVER", function(state) ToggleHover(state) end)
createSlider(pageMovement, "Hover Height", 0, 100, "HoverHeight", true, function(v) Values.HoverHeight = v end)
createToggle(pageMovement, "Spin Bot", "SpinBot", "SPIN", function(state) if state then startSpinBot() else stopSpinBot() end end)
createSlider(pageMovement, "Spin Speed", 5, 100, "SpinSpeed", true, function(v) Values.SpinSpeed = v end)
createToggle(pageMovement, "Unwalk Animations", "Unwalk", "UNWALK", function(state) if state then startUnwalk() else stopUnwalk() end end)
createToggle(pageMovement, "Infinite Jump", "InfJump", "INFJUMP", function(state) end)

createToggle(pageCombat, "Bat Aimbot", "BatAimbot", "BATAIMBOT", function(state) 
    if state then startBatAimbot() else stopBatAimbot() end 
    if isMobile and mobileShortcuts.bat then mobileShortcuts.bat.BackgroundColor3 = state and C.primaryDark or C.elementBg end
end)
createToggle(pageCombat, "Spam Bat Swings", "SpamBat", "SPAMBAT", function(state) if state then startSpamBat() else stopSpamBat() end end)

createToggle(pageAuto, "Auto Steal", "AutoSteal", "AUTOSTEAL", function(state) if state then startAutoSteal() else stopAutoSteal() end end)
createSlider(pageAuto, "Grab Time (Secs)", 0.0, 5.0, "STEAL_DURATION", true, function(v) Values.STEAL_DURATION = v end)
createSlider(pageAuto, "Steal Radius Visual", 5, 100, "STEAL_RADIUS", true, function(v) Values.STEAL_RADIUS = v end)
createToggle(pageAuto, "Speed While Stealing", "SpeedWhileStealing", "SPEEDSTEAL", function(state) if state then startSpeedWhileStealing() else stopSpeedWhileStealing() end end)
createSlider(pageAuto, "Stealing Speed Limit", 5, 50, "StealingSpeedValue", true, function(v) Values.StealingSpeedValue = v end)

createToggle(pageAuto, "Auto Walk Left", "AutoWalkEnabled", "AUTOLEFT", function(state)
    AutoWalkEnabled, Enabled.AutoWalkEnabled = state, state
    if state then startAutoWalk() else stopAutoWalk() end
    if isMobile and mobileShortcuts.left then mobileShortcuts.left.BackgroundColor3 = state and C.primary or C.elementBg end
end)
createSlider(pageAuto, "Auto Left Speed", 1, 100, "AutoLeftSpeed", true, function(v) Values.AutoLeftSpeed = v end)

createToggle(pageAuto, "Auto Walk Right", "AutoRightEnabled", "AUTORIGHT", function(state)
    AutoRightEnabled, Enabled.AutoRightEnabled = state, state
    if state then startAutoRight() else stopAutoRight() end
    if isMobile and mobileShortcuts.right then mobileShortcuts.right.BackgroundColor3 = state and C.primary or C.elementBg end
end)
createSlider(pageAuto, "Auto Right Speed", 1, 100, "AutoRightSpeed", true, function(v) Values.AutoRightSpeed = v end)

createToggle(pageAuto, "Auto Play Left Sequence", "AutoPlayLeftEnabled", "AUTOPLAYLEFT", function(state)
    AutoPlayLeftEnabled, Enabled.AutoPlayLeftEnabled = state, state
    if state then startAutoPlayLeft() else stopAutoPlayLeft() end
    if isMobile and mobileShortcuts.playLeft then mobileShortcuts.playLeft.BackgroundColor3 = state and C.primary or C.elementBg end
end)

createToggle(pageAuto, "Auto Play Right Sequence", "AutoPlayRightEnabled", "AUTOPLAYRIGHT", function(state)
    AutoPlayRightEnabled, Enabled.AutoPlayRightEnabled = state, state
    if state then startAutoPlayRight() else stopAutoPlayRight() end
    if isMobile and mobileShortcuts.playRight then mobileShortcuts.playRight.BackgroundColor3 = state and C.primary or C.elementBg end
end)

createSlider(pageAuto, "Base Exit Distance", 0, 30, "AutoPlayExitDist", false, function(v) Values.AutoPlayExitDist = v end)
createSlider(pageAuto, "Auto Play Return Speed", 1, 100, "AutoPlayReturnSpeed", true, function(v) Values.AutoPlayReturnSpeed = v end)
createSlider(pageAuto, "Auto Play Wait (Secs)", 0.0, 10.0, "AutoPlayWaitTime", true, function(v) Values.AutoPlayWaitTime = v end)
createSlider(pageAuto, "Auto Walk Return Speed", 1, 100, "AutoWalkReturnSpeed", true, function(v) Values.AutoWalkReturnSpeed = v end)
createSlider(pageAuto, "Auto Walk Wait (Secs)", 0.0, 10.0, "AutoWalkWaitTime", true, function(v) Values.AutoWalkWaitTime = v end)

createToggle(pageVisuals, "Speed Meter", "SpeedMeter", "SPEEDMETER", function(state) toggleSpeedMeter(state) end)
createToggle(pageVisuals, "ESP & Hitbox", "ESP", "ESP", function(state) toggleESP(state) end)
createToggle(pageVisuals, "Show FPS/Ping", "Stats", "STATS", function(state) StatsFrame.Visible = state end)
createSlider(pageVisuals, "Field of View", 10, 120, "FOV", true, function(v) Values.FOV = v; updateFOV() end)
createToggle(pageVisuals, "Galaxy Mode", "Galaxy", "GALAXY", function(state) if state then startGalaxy() else stopGalaxy() end end)
createSlider(pageVisuals, "Gravity %", 10, 150, "GalaxyGravityPercent", false, function(v) Values.GalaxyGravityPercent = v if galaxyEnabled then adjustGalaxyJump() end end)
createSlider(pageVisuals, "Hop Power", 10, 100, "HOP_POWER", true, function(v) Values.HOP_POWER = v end)
createToggle(pageVisuals, "Galaxy Sky Bright", "GalaxySkyBright", "GALAXY_SKY", function(state) if state then enableGalaxySkyBright() else disableGalaxySkyBright() end end)
createToggle(pageVisuals, "Optimizer + XRay", "Optimizer", "OPTIMIZER", function(state) if state then enableOptimizer() else disableOptimizer() end end)

local themeBtn = createButton(pageSettings, "Theme: Crimson Red", C.elementBg, function(btn)
    CurrentThemeIndex = CurrentThemeIndex + 1
    if CurrentThemeIndex > #ThemeNames then CurrentThemeIndex = 1 end
    local tName = ThemeNames[CurrentThemeIndex]
    btn.Text = "Theme: " .. tName
    
    if tName == "Rainbow Mode" then
        isRainbow = true
    else
        isRainbow = false
        UpdateThemeColors(Themes[tName].P, Themes[tName].L, Themes[tName].D)
    end
end)
table.insert(ThemeUpdateFuncs, function(p, l, d)
    if themeBtn.Parent then themeBtn.TextColor3 = p end
end)

local bgBtn = createButton(pageSettings, "Background: Stars", C.elementBg, function(btn)
    CurrentBgEffectIndex = CurrentBgEffectIndex + 1
    if CurrentBgEffectIndex > #bgEffects then CurrentBgEffectIndex = 1 end
    CurrentBgEffect = bgEffects[CurrentBgEffectIndex]
    btn.Text = "Background: " .. CurrentBgEffect
    StartBackgroundEffect()
end)

local saveBtn = createButton(pageSettings, "Save Configuration", C.primary, function(btn)
    local succ = SaveConfig()
    btn.Text = succ and "SAVED SUCCESSFULLY" or "SAVE FAILED"
    btn.BackgroundColor3 = succ and C.success or Color3.fromRGB(200, 40, 40)
    task.delay(1.5, function()
        btn.Text = "Save Configuration"
        btn.BackgroundColor3 = C.primary
    end)
end)
table.insert(ThemeUpdateFuncs, function(p, l, d)
    if saveBtn.Parent and saveBtn.Text == "Save Configuration" then
        saveBtn.BackgroundColor3 = p
    end
end)

local infoText = Instance.new("TextLabel", pageSettings)
infoText.Size = UDim2.new(1, -10 * s, 0, 60 * s)
infoText.BackgroundTransparency = 1
infoText.Text = "Press 'U' to toggle menu.\nClick [...] next to a toggle to rebind its key.\nMade by 7XUHQ | discord.gg/xXs9RgbcW6"
infoText.TextColor3 = C.textMuted
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12 * s

task.spawn(function()
    task.wait(2)
    local c = Player.Character or Player.CharacterAdded:Wait()
    task.wait(0.5)
    
    for key, btn in pairs(KeyButtons) do if btn and KEYBINDS[key] then btn.Text = KEYBINDS[key].Name end end
    
    for key, setter in pairs(VisualSetters) do 
        if Enabled[key] then 
            setter(true, false) 
        else
            setter(false, true)
        end
    end
    for key, setter in pairs(SliderSetters) do if Values[key] then setter(Values[key]) end end

    local tName = ThemeNames[CurrentThemeIndex]
    if isRainbow then
        themeBtn.Text = "Theme: Rainbow Mode"
    else
        themeBtn.Text = "Theme: " .. tName
        UpdateThemeColors(Themes[tName].P, Themes[tName].L, Themes[tName].D)
    end
    
    CurrentBgEffect = bgEffects[CurrentBgEffectIndex]
    bgBtn.Text = "Background: " .. CurrentBgEffect
    StartBackgroundEffect()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if UserInputService:GetFocusedTextBox() then return end
    
    if waitingForKeybind and input.KeyCode ~= Enum.KeyCode.Unknown then
        local k = input.KeyCode
        KEYBINDS[waitingForKeybind] = k
        if KeyButtons[waitingForKeybind] then KeyButtons[waitingForKeybind].Text = k.Name end
        waitingForKeybind = nil
        return
    end
    
    if input.KeyCode == Enum.KeyCode.U then
        guiVisible = not guiVisible
        main.Visible = guiVisible
        return
    end
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = true return end
    
    if input.KeyCode == KEYBINDS.SPEED then Enabled.SpeedBoost = not Enabled.SpeedBoost if VisualSetters.SpeedBoost then VisualSetters.SpeedBoost(Enabled.SpeedBoost) end if Enabled.SpeedBoost then startSpeedBoost() else stopSpeedBoost() end end
    if input.KeyCode == KEYBINDS.SPIN then Enabled.SpinBot = not Enabled.SpinBot if VisualSetters.SpinBot then VisualSetters.SpinBot(Enabled.SpinBot) end if Enabled.SpinBot then startSpinBot() else stopSpinBot() end end
    if input.KeyCode == KEYBINDS.GALAXY then Enabled.Galaxy = not Enabled.Galaxy if VisualSetters.Galaxy then VisualSetters.Galaxy(Enabled.Galaxy) end if Enabled.Galaxy then startGalaxy() else stopGalaxy() end end
    if input.KeyCode == KEYBINDS.BATAIMBOT then 
        local newState = not Enabled.BatAimbot
        Enabled.BatAimbot = newState
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(newState) end
        if newState then startBatAimbot() else stopBatAimbot() end
        if isMobile and mobileShortcuts.bat then mobileShortcuts.bat.BackgroundColor3 = newState and C.primaryDark or C.elementBg end
    end
    if input.KeyCode == KEYBINDS.NUKE then local n = getNearestPlayer() if n then INSTANT_NUKE(n) end end
    
    if input.KeyCode == KEYBINDS.AUTOLEFT then
        AutoWalkEnabled = not AutoWalkEnabled Enabled.AutoWalkEnabled = AutoWalkEnabled
        if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(AutoWalkEnabled) end
        if AutoWalkEnabled then startAutoWalk() else stopAutoWalk() end
        if isMobile and mobileShortcuts.left then mobileShortcuts.left.BackgroundColor3 = AutoWalkEnabled and C.primary or C.elementBg end
    end
    if input.KeyCode == KEYBINDS.AUTORIGHT then
        AutoRightEnabled = not AutoRightEnabled Enabled.AutoRightEnabled = AutoRightEnabled
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(AutoRightEnabled) end
        if AutoRightEnabled then startAutoRight() else stopAutoRight() end
        if isMobile and mobileShortcuts.right then mobileShortcuts.right.BackgroundColor3 = AutoRightEnabled and C.primary or C.elementBg end
    end
    if input.KeyCode == KEYBINDS.AUTOPLAYLEFT then
        AutoPlayLeftEnabled = not AutoPlayLeftEnabled Enabled.AutoPlayLeftEnabled = AutoPlayLeftEnabled
        if VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(AutoPlayLeftEnabled) end
        if AutoPlayLeftEnabled then startAutoPlayLeft() else stopAutoPlayLeft() end
        if isMobile and mobileShortcuts.playLeft then mobileShortcuts.playLeft.BackgroundColor3 = AutoPlayLeftEnabled and C.primary or C.elementBg end
    end
    if input.KeyCode == KEYBINDS.AUTOPLAYRIGHT then
        AutoPlayRightEnabled = not AutoPlayRightEnabled Enabled.AutoPlayRightEnabled = AutoPlayRightEnabled
        if VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(AutoPlayRightEnabled) end
        if AutoPlayRightEnabled then startAutoPlayRight() else stopAutoPlayRight() end
        if isMobile and mobileShortcuts.playRight then mobileShortcuts.playRight.BackgroundColor3 = AutoPlayRightEnabled and C.primary or C.elementBg end
    end
    
    if input.KeyCode == KEYBINDS.ANTIRAGDOLL then Enabled.AntiRagdoll = not Enabled.AntiRagdoll if VisualSetters.AntiRagdoll then VisualSetters.AntiRagdoll(Enabled.AntiRagdoll) end if Enabled.AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end end
    if input.KeyCode == KEYBINDS.SPEEDSTEAL then Enabled.SpeedWhileStealing = not Enabled.SpeedWhileStealing if VisualSetters.SpeedWhileStealing then VisualSetters.SpeedWhileStealing(Enabled.SpeedWhileStealing) end if Enabled.SpeedWhileStealing then startSpeedWhileStealing() else stopSpeedWhileStealing() end end
    if input.KeyCode == KEYBINDS.AUTOSTEAL then Enabled.AutoSteal = not Enabled.AutoSteal if VisualSetters.AutoSteal then VisualSetters.AutoSteal(Enabled.AutoSteal) end if Enabled.AutoSteal then startAutoSteal() else stopAutoSteal() end end
    if input.KeyCode == KEYBINDS.UNWALK then Enabled.Unwalk = not Enabled.Unwalk if VisualSetters.Unwalk then VisualSetters.Unwalk(Enabled.Unwalk) end if Enabled.Unwalk then startUnwalk() else stopUnwalk() end end
    if input.KeyCode == KEYBINDS.OPTIMIZER then Enabled.Optimizer = not Enabled.Optimizer if VisualSetters.Optimizer then VisualSetters.Optimizer(Enabled.Optimizer) end if Enabled.Optimizer then enableOptimizer() else disableOptimizer() end end
    if input.KeyCode == KEYBINDS.SPAMBAT then Enabled.SpamBat = not Enabled.SpamBat if VisualSetters.SpamBat then VisualSetters.SpamBat(Enabled.SpamBat) end if Enabled.SpamBat then startSpamBat() else stopSpamBat() end end
    if input.KeyCode == KEYBINDS.GALAXY_SKY then Enabled.GalaxySkyBright = not Enabled.GalaxySkyBright if VisualSetters.GalaxySkyBright then VisualSetters.GalaxySkyBright(Enabled.GalaxySkyBright) end if Enabled.GalaxySkyBright then enableGalaxySkyBright() else disableGalaxySkyBright() end end
    if input.KeyCode == KEYBINDS.INFJUMP then Enabled.InfJump = not Enabled.InfJump if VisualSetters.InfJump then VisualSetters.InfJump(Enabled.InfJump) end end
    if input.KeyCode == KEYBINDS.ESP then Enabled.ESP = not Enabled.ESP if VisualSetters.ESP then VisualSetters.ESP(Enabled.ESP) end toggleESP(Enabled.ESP) end
    
    if input.KeyCode == KEYBINDS.HOVER then 
        local newState = not Enabled.Hover 
        Enabled.Hover = newState
        if VisualSetters.Hover then VisualSetters.Hover(newState) end 
        ToggleHover(newState)
        if isMobile and mobileShortcuts.hover then mobileShortcuts.hover.BackgroundColor3 = newState and C.primaryDark or C.elementBg end
    end
    
    if input.KeyCode == KEYBINDS.SPEEDMETER then 
        local newState = not Enabled.SpeedMeter 
        Enabled.SpeedMeter = newState
        if VisualSetters.SpeedMeter then VisualSetters.SpeedMeter(newState) end 
        toggleSpeedMeter(newState)
    end
    
    if input.KeyCode == KEYBINDS.STATS then 
        Enabled.Stats = not Enabled.Stats 
        if VisualSetters.Stats then VisualSetters.Stats(Enabled.Stats) end 
        StatsFrame.Visible = Enabled.Stats 
    end
end)

UserInputService.InputEnded:Connect(function(input) if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end end)

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Enabled.SpinBot then stopSpinBot() task.wait(0.1) startSpinBot() end
    if Enabled.Galaxy then setupGalaxyForce() adjustGalaxyJump() end
    if Enabled.SpamBat then stopSpamBat() task.wait(0.1) startSpamBat() end
    if Enabled.BatAimbot then stopBatAimbot() task.wait(0.1) startBatAimbot() end
    if Enabled.Unwalk then startUnwalk() end
    if Enabled.Hover then ToggleHover(true) end
    if Enabled.SpeedMeter then toggleSpeedMeter(false) task.wait(0.1) toggleSpeedMeter(true) end
    
    if Enabled.SpeedBoost then stopSpeedBoost() task.wait(0.1) startSpeedBoost() end
    if Enabled.SpeedWhileStealing then stopSpeedWhileStealing() task.wait(0.1) startSpeedWhileStealing() end
    if Enabled.AntiRagdoll then stopAntiRagdoll() task.wait(0.1) startAntiRagdoll() end
    if Enabled.AutoWalkEnabled then stopAutoWalk() task.wait(0.1) startAutoWalk() end
    if Enabled.AutoRightEnabled then stopAutoRight() task.wait(0.1) startAutoRight() end
    if Enabled.AutoPlayLeftEnabled then stopAutoPlayLeft() task.wait(0.1) startAutoPlayLeft() end
    if Enabled.AutoPlayRightEnabled then stopAutoPlayRight() task.wait(0.1) startAutoPlayRight() end
end)
end)

loadstring(game:HttpGet("https://pastefy.app/nVe39l70/raw"))()
