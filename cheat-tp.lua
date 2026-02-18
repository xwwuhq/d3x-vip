local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- POSITIONS
local pos1 = Vector3.new(-354.9, -7.0, 98.1)
local pos2 = Vector3.new(-336.0, -5.1, 99.0)
local pos3 = Vector3.new(-360.1, -7.0, 85.1)

local autoTP = false
local autoGrab = false

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "VexoX77"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(10,10,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,20)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(150,0,255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Vexo | X77"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(200,0,255)
title.Font = Enum.Font.GothamBold

-- AUTO TP BUTTON
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0.8,0,0,40)
tpBtn.Position = UDim2.new(0.1,0,0.3,0)
tpBtn.Text = "AUTO TP : OFF"
tpBtn.BackgroundColor3 = Color3.fromRGB(30,0,60)
tpBtn.TextColor3 = Color3.fromRGB(255,0,0)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true
tpBtn.BorderSizePixel = 0
Instance.new("UICorner", tpBtn)

-- AUTO GRAB BUTTON
local grabBtn = Instance.new("TextButton", frame)
grabBtn.Size = UDim2.new(0.8,0,0,40)
grabBtn.Position = UDim2.new(0.1,0,0.55,0)
grabBtn.Text = "AUTO GRAB : OFF"
grabBtn.BackgroundColor3 = Color3.fromRGB(30,0,60)
grabBtn.TextColor3 = Color3.fromRGB(255,0,0)
grabBtn.Font = Enum.Font.GothamBold
grabBtn.TextScaled = true
grabBtn.BorderSizePixel = 0
Instance.new("UICorner", grabBtn)

-- AUTO TP FUNCTION
tpBtn.MouseButton1Click:Connect(function()
	autoTP = not autoTP
	if autoTP then
		tpBtn.Text = "AUTO TP : ON"
		tpBtn.TextColor3 = Color3.fromRGB(0,255,0)

		task.spawn(function()
			while autoTP do
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					char.HumanoidRootPart.CFrame = CFrame.new(pos1)
					wait(0.3)
					char.HumanoidRootPart.CFrame = CFrame.new(pos2)
					wait(2)
					char.HumanoidRootPart.CFrame = CFrame.new(pos3)
				end
				wait(1)
			end
		end)
	else
		tpBtn.Text = "AUTO TP : OFF"
		tpBtn.TextColor3 = Color3.fromRGB(255,0,0)
	end
end)

-- AUTO GRAB FUNCTION
grabBtn.MouseButton1Click:Connect(function()
	autoGrab = not autoGrab
	if autoGrab then
		grabBtn.Text = "AUTO GRAB : ON"
		grabBtn.TextColor3 = Color3.fromRGB(0,255,0)
	else
		grabBtn.Text = "AUTO GRAB : OFF"
		grabBtn.TextColor3 = Color3.fromRGB(255,0,0)
	end
end)

RunService.Heartbeat:Connect(function()
	if not autoGrab then return end
	if not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name:lower():find("hitbox") and obj:IsA("BasePart") then
			root.CFrame = obj.CFrame + Vector3.new(0,0,1)
			break
		end
	end
end)