--[[
    ✨ D3X SUPREME - EDITION V4 PREMIUM (v1.8 - FIXED)
    Owner: X77
    Status: Functions Active / UI Locked / Instant Steal Added
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- // THEME //
local THEME = {
    Bg = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(10, 10, 15),
    Accent = Color3.fromRGB(170, 0, 255),
    Secondary = Color3.fromRGB(0, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 160),
    ItemBg = Color3.fromRGB(25, 25, 30),
    MacRed = Color3.fromRGB(255, 95, 87),
    MacYellow = Color3.fromRGB(255, 189, 46),
    MacGreen = Color3.fromRGB(39, 201, 63)
}

local State = { NoAnim = false, FpsKiller = false, IsMinimized = false, ItemEspActive = false, FpsBoostActive = false, PlayerEspActive = false }
local SIZES = { Full = UDim2.new(0, 550, 0, 320), Mini = UDim2.new(0, 140, 0, 320) }

-- // 1. FONCTIONS RÉELLES //

-- Fonction ESP PLAYER (HIGHLIGHT)
local function executePlayerEsp()
    if State.PlayerEspActive then return end
    State.PlayerEspActive = true

    local function applyESP(character)
        if not character then return end
        if character:FindFirstChild("ESP_HIGHLIGHT") then return end
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_HIGHLIGHT"
        hl.Adornee = character
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = character
    end

    local function onPlayer(player)
        if player == Player then return end
        if player.Character then applyESP(player.Character) end
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            applyESP(char)
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do onPlayer(p) end
    Players.PlayerAdded:Connect(onPlayer)
    warn("[ESP PLAYER] Silhouette rouge activée")
end

-- Fonction FPS BOOST
local function executeFpsBoost()
    if State.FpsBoostActive then return end
    State.FpsBoostActive = true

    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        task.wait()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end)
    warn("[FPS BOOST] Activé")
end

-- Fonction ESP ITEM IMAGE
local function executeItemEsp()
    if State.ItemEspActive then return end
    State.ItemEspActive = true

    local ESPs = {}
    local LastTool = {}

    local function getToolImage(tool)
        if tool.TextureId and tool.TextureId ~= "" then return tool.TextureId end
        local handle = tool:FindFirstChild("Handle")
        if handle then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.TextureId ~= "" then return mesh.TextureId end
            if handle:IsA("MeshPart") and handle.TextureID ~= "" then return handle.TextureID end
            for _, d in ipairs(handle:GetDescendants()) do
                if d:IsA("Decal") or d:IsA("Texture") then return d.Texture end
            end
        end
        return nil
    end

    local function removeESP(player)
        if ESPs[player] then
            ESPs[player]:Destroy()
            ESPs[player] = nil
            LastTool[player] = nil
        end
    end

    local function createESP(player, tool)
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        local imgId = getToolImage(tool)
        if not imgId then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_ITEM_IMAGE"; bb.Adornee = head; bb.Size = UDim2.new(0, 60, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3.2, 0); bb.AlwaysOnTop = true; bb.Parent = head

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1
        img.Image = imgId; img.ScaleType = Enum.ScaleType.Fit; img.Parent = bb

        ESPs[player] = bb
        LastTool[player] = tool
    end

    RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                local char = plr.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    if LastTool[plr] ~= tool then
                        removeESP(plr)
                        createESP(plr, tool)
                    end
                else
                    removeESP(plr)
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(removeESP)
end

-- Fonction DYSCN
local function executeDyscn()
    local FFlags = {
        GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
        LargeReplicatorWrite5 = true,
        LargeReplicatorEnabled9 = true,
        AngularVelociryLimit = 360,
        TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
        S2PhysicsSenderRate = 15000,
        DisableDPIScale = true,
        MaxDataPacketPerSend = 2147483647,
        PhysicsSenderMaxBandwidthBps = 20000,
        TimestepArbiterHumanoidLinearVelThreshold = 21,
        MaxMissedWorldStepsRemembered = -2147483648,
        PlayerHumanoidPropertyUpdateRestrict = true,
        SimDefaultHumanoidTimestepMultiplier = 0,
        StreamJobNOUVolumeLengthCap = 2147483647,
        DebugSendDistInSteps = -2147483648,
        GameNetDontSendRedundantNumTimes = 1,
        CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
        CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
        LargeReplicatorSerializeRead3 = true,
        ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
        CheckPVCachedVelThresholdPercent = 10,
        CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
        GameNetDontSendRedundantDeltaPositionMillionth = 1,
        InterpolationFrameVelocityThresholdMillionth = 5,
        StreamJobNOUVolumeCap = 2147483647,
        InterpolationFrameRotVelocityThresholdMillionth = 5,
        CheckPVCachedRotVelThresholdPercent = 10,
        WorldStepMax = 30,
        InterpolationFramePositionThresholdMillionth = 5,
        TimestepArbiterHumanoidTurningVelThreshold = 1,
        SimOwnedNOUCountThresholdMillionth = 2147483647,
        GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
        NextGenReplicatorEnabledWrite4 = true,
        TimestepArbiterOmegaThou = 1073741823,
        MaxAcceptableUpdateDelay = 1,
        LargeReplicatorSerializeWrite4 = true
    }

    local function respawnar(plr)
        local rcdEnabled = false
        if gethidden then
            rcdEnabled = gethidden(workspace, 'RejectCharacterDeletions') ~= Enum.RejectCharacterDeletions.Disabled
        end
        if rcdEnabled and replicatesignal then
            replicatesignal(plr.ConnectDiedSignalBackend)
            task.wait(Players.RespawnTime - 0.1)
            replicatesignal(plr.Kill)
        else
            local char = plr.Character
            local hum = char:FindFirstChildWhichIsA('Humanoid')
            if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
            char:ClearAllChildren()
            local newChar = Instance.new('Model')
            newChar.Parent = workspace
            plr.Character = newChar
            task.wait()
            plr.Character = char
            newChar:Destroy()
        end
    end

    for name, value in pairs(FFlags) do
        pcall(function() setfflag(tostring(name), tostring(value)) end)
    end
    respawnar(Player)
end

-- Boucle FPS KILLER
task.spawn(function()
    while true do
        if State.FpsKiller then
            local char = Player.Character
            local backpack = Player:FindFirstChild("Backpack")
            if char and backpack then
                local tool = char:FindFirstChild("Bat") or backpack:FindFirstChild("Bat")
                if tool then
                    tool.Parent = char
                    task.wait()
                    tool.Parent = backpack
                end
            end
        end
        task.wait(0.01)
    end
end)

-- Fonction NO ANIM
local function applyNoAnim()
    local char = Player.Character
    if char then
        local animate = char:FindFirstChild("Animate")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if animate then animate.Disabled = State.NoAnim end
        if State.NoAnim and hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
            end
        end
    end
end

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.NoAnim then applyNoAnim() end
end)

-- // 2. INTERFACE //

if PlayerGui:FindFirstChild("D3X_V4") then PlayerGui.D3X_V4:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "D3X_V4"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"; MainFrame.Size = SIZES.Full; MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = THEME.Bg
MainFrame.BackgroundTransparency = 0.15; MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- C'EST ICI QUE C'ÉTAIT CACHÉ DE BASE
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60,60,70)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = THEME.Sidebar
Sidebar.BackgroundTransparency = 0.1; Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarOverlay = Instance.new("Frame")
SidebarOverlay.Size = UDim2.new(0, 20, 1, 0); SidebarOverlay.Position = UDim2.new(1, -20, 0, 0)
SidebarOverlay.BackgroundColor3 = THEME.Sidebar; SidebarOverlay.BorderSizePixel = 0; SidebarOverlay.Parent = Sidebar

local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(0, 1, 1, 0); SideLine.Position = UDim2.new(1, 0, 0, 0)
SideLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55); SideLine.BorderSizePixel = 0; SideLine.Parent = Sidebar

-- BOUTONS MAC
local MacContainer = Instance.new("Frame")
MacContainer.Size = UDim2.new(0, 60, 0, 20); MacContainer.Position = UDim2.new(1, -70, 0, 15)
MacContainer.BackgroundTransparency = 1; MacContainer.ZIndex = 100; MacContainer.Parent = MainFrame

local function createMacDot(color, xPos, callback)
    local dot = Instance.new("TextButton")
    dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, xPos, 0, 0)
    dot.BackgroundColor3 = color; dot.Text = ""; dot.Parent = MacContainer
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    dot.MouseButton1Click:Connect(callback)
end

createMacDot(THEME.MacGreen, 0, function() 
    State.IsMinimized = false
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = SIZES.Full}):Play()
end)

createMacDot(THEME.MacYellow, 18, function() 
    State.IsMinimized = true
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = SIZES.Mini}):Play()
end)

createMacDot(THEME.MacRed, 36, function() MainFrame.Visible = false end)

-- TITRES
local AppTitle = Instance.new("TextLabel")
AppTitle.Text = "D3X BETA"; AppTitle.Font = Enum.Font.GothamBlack; AppTitle.TextSize = 20
AppTitle.TextColor3 = THEME.Secondary; AppTitle.Size = UDim2.new(1, 0, 0, 30)
AppTitle.Position = UDim2.new(0, 12, 0, 20); AppTitle.BackgroundTransparency = 1
AppTitle.TextXAlignment = Enum.TextXAlignment.Left; AppTitle.Parent = Sidebar

local VerLabel = Instance.new("TextLabel")
VerLabel.Text = "v1.1 | PREMIUM"; VerLabel.Font = Enum.Font.GothamBold; VerLabel.TextSize = 9
VerLabel.TextColor3 = THEME.SubText; VerLabel.Position = UDim2.new(0, 12, 0, 43)
VerLabel.Size = UDim2.new(0, 100, 0, 15); VerLabel.BackgroundTransparency = 1
VerLabel.TextXAlignment = Enum.TextXAlignment.Left; VerLabel.Parent = Sidebar

-- PAGE SYSTEM
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"; PageContainer.Size = UDim2.new(1, -160, 1, -60)
PageContainer.Position = UDim2.new(0, 150, 0, 50); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

local Pages = { 
    Home = Instance.new("ScrollingFrame"), 
    Esp = Instance.new("ScrollingFrame"),
    Boost = Instance.new("ScrollingFrame")
}

for name, frame in pairs(Pages) do
    frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.ScrollBarThickness = 0
    frame.Visible = (name == "Home"); frame.Parent = PageContainer
end

-- TABS
local function createTab(text, target, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 35); btn.Position = UDim2.new(0.07, 0, 0, yPos)
    btn.BackgroundTransparency = 1; btn.Text = "   " .. text; btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12; btn.TextColor3 = THEME.SubText; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = Sidebar

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0.5, 0); ind.Position = UDim2.new(0, 0, 0.25, 0); ind.BackgroundColor3 = THEME.Accent
    ind.Visible = (target == "Home"); ind.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = THEME.SubText if v:FindFirstChild("Frame") then v.Frame.Visible = false end end end
        btn.TextColor3 = Color3.new(1,1,1); ind.Visible = true
        for n, f in pairs(Pages) do f.Visible = (n == target) end
    end)
    return btn
end

createTab("HOME", "Home", 90).TextColor3 = Color3.new(1,1,1)
createTab("ESP", "Esp", 130)
createTab("BOOST", "Boost", 170)

-- DISCORD
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(0.8, 0, 0, 28); DiscordBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); DiscordBtn.Text = "COPY DISCORD"
DiscordBtn.Font = Enum.Font.GothamBold; DiscordBtn.TextSize = 10; DiscordBtn.TextColor3 = Color3.new(1,1,1); DiscordBtn.Parent = Sidebar
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 6)
DiscordBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/DzQBME7BjJ") DiscordBtn.Text = "COPIED!" task.wait(2) DiscordBtn.Text = "COPY DISCORD" end)

-- PROFIL
local Profile = Instance.new("Frame")
Profile.Size = UDim2.new(1, 0, 0, 65); Profile.Position = UDim2.new(0, 0, 1, -65); Profile.BackgroundColor3 = Color3.new(0,0,0)
Profile.BackgroundTransparency = 0.6; Profile.Parent = Sidebar; Instance.new("UICorner", Profile).CornerRadius = UDim.new(0, 12)

local NameLbl = Instance.new("TextLabel")
NameLbl.Text = Player.DisplayName; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 11
NameLbl.TextColor3 = Color3.new(1,1,1); NameLbl.Position = UDim2.new(0, 12, 0, 15)
NameLbl.BackgroundTransparency = 1; NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.Parent = Profile

local OwnerLbl = Instance.new("TextLabel")
OwnerLbl.Text = "Owner by X77"; OwnerLbl.Font = Enum.Font.Gotham; OwnerLbl.TextSize = 9
OwnerLbl.TextColor3 = THEME.SubText; OwnerLbl.Position = UDim2.new(0, 12, 0, 32); OwnerLbl.BackgroundTransparency = 1; OwnerLbl.TextXAlignment = Enum.TextXAlignment.Left; OwnerLbl.Parent = Profile

-- FEATURES GENERATOR
local function createFeatureBtn(text, desc, yOrder, parentPage, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 55); btn.Position = UDim2.new(0, 0, 0, 0 + (yOrder-1)*62)
    btn.BackgroundColor3 = THEME.ItemBg; btn.BackgroundTransparency = 0.4; btn.Text = ""; btn.Parent = parentPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel")
    t.Text = text; t.Font = Enum.Font.GothamBold; t.TextColor3 = Color3.new(1,1,1); t.TextSize = 14
    t.Position = UDim2.new(0, 15, 0.25, 0); t.BackgroundTransparency = 1; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = btn

    local d = Instance.new("TextLabel")
    d.Text = desc; d.Font = Enum.Font.Gotham; d.TextColor3 = THEME.SubText; d.TextSize = 10
    d.Position = UDim2.new(0, 15, 0.6, 0); d.BackgroundTransparency = 1; d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = btn

    btn.MouseButton1Click:Connect(function() callback(t) end)
end

-- // ASSIGNATION DES BOUTONS //

-- PAGE HOME
createFeatureBtn("DYSCN", "Inject Physics FFlags", 1, Pages.Home, function(t) 
    t.TextColor3 = THEME.Secondary; t.Text = "DYSCN : ACTIVE"; executeDyscn() 
end)

createFeatureBtn("FPS KILLER", "Lag Switch Mode (Need Bat)", 2, Pages.Home, function(t) 
    State.FpsKiller = not State.FpsKiller; t.TextColor3 = State.FpsKiller and THEME.MacRed or Color3.new(1,1,1); t.Text = State.FpsKiller and "FPS KILLER : ON" or "FPS KILLER"
end)

createFeatureBtn("NO ANIM", "Disable Character Animations", 3, Pages.Home, function(t) 
    State.NoAnim = not State.NoAnim; t.TextColor3 = State.NoAnim and THEME.MacGreen or Color3.new(1,1,1); t.Text = State.NoAnim and "NO ANIM : ON" or "NO ANIM"; applyNoAnim()
end)

-- 🟢 INSTANT STEAL 🟢
createFeatureBtn("INSTANT STEAL", "Open Galaxy UI (Save Base & TP)", 4, Pages.Home, function(t)
    t.TextColor3 = THEME.Secondary
    t.Text = "LAUNCHED"

    -- DEBUT DU SCRIPT GALAXY UI
    local GalaxyPlayers = game:GetService("Players")
    local GalaxyPlayer = GalaxyPlayers.LocalPlayer
    local BASE_CF = nil

    local function tpBase()
        local char = GalaxyPlayer.Character
        if not char or not BASE_CF then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = BASE_CF + Vector3.new(0, 3, 0) end
    end

    if game.CoreGui:FindFirstChild("D3X_GALAXY") then game.CoreGui.D3X_GALAXY:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "D3X_GALAXY"
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = THEME.Bg
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel")
    title.Text = "GALAXY UI"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = THEME.Secondary
    title.Size = UDim2.new(1,0,0,30)
    title.Position = UDim2.new(0,0,0,10)
    title.BackgroundTransparency = 1
    title.Parent = frame

    -- Bouton TP Base
    local tpBtn = Instance.new("TextButton")
    tpBtn.Text = "TP TO BASE"
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 12
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Size = UDim2.new(0.8,0,0,30)
    tpBtn.Position = UDim2.new(0.1,0,0.3,0)
    tpBtn.BackgroundColor3 = THEME.Accent
    tpBtn.Parent = frame
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,8)
    tpBtn.MouseButton1Click:Connect(tpBase)

    -- Stocker la position de base
    local storeBtn = Instance.new("TextButton")
    storeBtn.Text = "STORE BASE"
    storeBtn.Font = Enum.Font.GothamBold
    storeBtn.TextSize = 12
    storeBtn.TextColor3 = Color3.new(1,1,1)
    storeBtn.Size = UDim2.new(0.8,0,0,30)
    storeBtn.Position = UDim2.new(0.1,0,0.55,0)
    storeBtn.BackgroundColor3 = THEME.Secondary
    storeBtn.Parent = frame
    Instance.new("UICorner", storeBtn).CornerRadius = UDim.new(0,8)

    storeBtn.MouseButton1Click:Connect(function()
        local char = GalaxyPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                BASE_CF = hrp.CFrame
                storeBtn.Text = "BASE STORED"
                task.delay(2,function() storeBtn.Text = "STORE BASE" end)
            end
        end
    end)

    -- Ajouter un bouton pour fermer
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Size = UDim2.new(0,25,0,25)
    closeBtn.Position = UDim2.new(1,-30,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    -- FIN GALAXY UI
end)

-- PAGE ESP
createFeatureBtn("PLAYER ESP", "Silhouette Rouge", 1, Pages.Esp, function(t)
    t.TextColor3 = THEME.Secondary; t.Text = "PLAYER ESP : ON"
    executePlayerEsp()
end)

createFeatureBtn("ITEM ESP", "Affiche l'image de l'objet", 2, Pages.Esp, function(t)
    t.TextColor3 = THEME.Secondary; t.Text = "ITEM ESP : ON"
    executeItemEsp()
end)

-- PAGE BOOST
createFeatureBtn("FPS BOOST", "Optimisation maximale", 1, Pages.Boost, function(t)
    t.TextColor3 = THEME.Secondary; t.Text = "FPS BOOST : ON"
    executeFpsBoost()
end)

-- // IMPORTANT: ON AFFICHE LE GUI À LA FIN //
MainFrame.Visible = true
