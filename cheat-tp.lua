-- // ====================================================== //
-- // D3X PREMIUM LOADER (LONG LOADING - 5 MIN)
-- // ====================================================== //

local function StartPremiumLoader()
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserGameSettings = UserSettings():GetService("UserGameSettings")

    -- 1. MUTE LE SON
    local oldVolume = UserGameSettings.MasterVolume
    UserGameSettings.MasterVolume = 0

    -- 2. CRÉATION DU GUI
    local LoaderGui = Instance.new("ScreenGui")
    LoaderGui.Name = "D3X_LONG_LOADER"
    LoaderGui.IgnoreGuiInset = true
    LoaderGui.DisplayOrder = 10000
    LoaderGui.Parent = CoreGui

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.Active = true -- Bloque les clics
    Background.Parent = LoaderGui

    -- 3. TITRE (POSITIONNÉ PLUS HAUT)
    local Title = Instance.new("TextLabel")
    Title.Text = "D3X HUB PREMIUM LOADING..."
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 28
    Title.TextColor3 = Color3.fromRGB(170, 0, 255)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0.35, 0) -- Remonté
    Title.BackgroundTransparency = 1
    Title.Parent = Background

    -- 4. COMMANDES EN HAUT À DROITE (STATUS)
    local StatusContainer = Instance.new("Frame")
    StatusContainer.Size = UDim2.new(0, 200, 0, 150)
    StatusContainer.Position = UDim2.new(1, -210, 0, 20)
    StatusContainer.BackgroundTransparency = 1
    StatusContainer.Parent = Background

    local UIList = Instance.new("UIListLayout")
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIList.Padding = UDim.new(0, 5)
    UIList.Parent = StatusContainer

    local function addStatus(text)
        local lbl = Instance.new("TextLabel")
        lbl.Text = "[✔] " .. text
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(0, 255, 120) -- Vert succès
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.Parent = StatusContainer
    end

    -- Liste de tes commandes
    addStatus("SUCCESS ESP PLAYER")
    addStatus("SUCCESS INSTANT STEAL")
    addStatus("SUCCESS ITEM ESP")
    addStatus("SUCCESS FPS BOOST")
    addStatus("SUCCESS DYSCN INJECT")

    -- 5. BARRE DE PROGRESSION
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(0, 500, 0, 12)
    BarContainer.Position = UDim2.new(0.5, -250, 0.5, 0)
    BarContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BarContainer.Parent = Background
    Instance.new("UICorner", BarContainer)

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    BarFill.Parent = BarContainer
    Instance.new("UICorner", BarFill)

    local PercentLbl = Instance.new("TextLabel")
    PercentLbl.Text = "0%"
    PercentLbl.Font = Enum.Font.GothamBold
    PercentLbl.TextSize = 20
    PercentLbl.TextColor3 = Color3.new(1, 1, 1)
    PercentLbl.Position = UDim2.new(0.5, -50, 0.5, 30)
    PercentLbl.Size = UDim2.new(0, 100, 0, 30)
    PercentLbl.BackgroundTransparency = 1
    PercentLbl.Parent = Background

    -- ======================================================
    -- LOGIQUE DE CHARGEMENT (5 MINUTES)
    -- ======================================================
    
    local duration = 300 -- 5 minutes en secondes
    local startTime = tick()

    task.spawn(function()
        while true do
            local elapsed = tick() - startTime
            local progress = math.min(elapsed / duration, 1) -- Calcul du %
            
            -- Mise à jour visuelle
            PercentLbl.Text = math.floor(progress * 100) .. "%"
            BarFill.Size = UDim2.new(progress, 0, 1, 0)

            if progress >= 1 then break end
            task.wait(0.5) -- Rafraîchissement léger
        end

        -- Finalisation
        Title.Text = "D3X HUB LOADED SUCCESSFULLY"
        Title.TextColor3 = Color3.fromRGB(0, 255, 100)
        wait(2)
        
        -- Fermeture
        LoaderGui:Destroy()
        UserGameSettings.MasterVolume = oldVolume
    end)
end

-- Lancement
StartPremiumLoader()
