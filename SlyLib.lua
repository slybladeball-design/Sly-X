-- SLY X V15.1 (LIBRARY SAFE)
print("Initialisation SLY X...")

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

-- CONFIGURATION SIMPLE
local Config = {
    AutoParry = true,
    ManualSpam = false,
    AutoSpam = false,
    AnimFix = true
}

-- UI SIMPLE ET ROBUSTE
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "SlyX_Lib"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 250, 0, 150)
main.Position = UDim2.new(0.5, -125, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.Active = true
main.Draggable = true -- Méthode simple pour Madium

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SLY X - PREMIUM"
title.TextColor3 = Color3.fromRGB(204, 0, 0)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, 0, 1, -30)
status.Position = UDim2.new(0, 0, 0, 30)
status.Text = "X: Auto Parry (ON)\nE: Manual Spam (OFF)\nV: Smart Spam (OFF)\nCTRL: Hide"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.BackgroundTransparency = 1

-- LOGIQUE DE COMBAT
local remote = nil
pcall(function()
    remote = Rep:WaitForChild("Remotes"):WaitForChild("Parry")
end)

UIS.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.X then
        Config.AutoParry = not Config.AutoParry
    elseif input.KeyCode == Enum.KeyCode.E then
        Config.ManualSpam = not Config.ManualSpam
    elseif input.KeyCode == Enum.KeyCode.V then
        Config.AutoSpam = not Config.AutoSpam
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        sg.Enabled = not sg.Enabled
    end
    status.Text = string.format("X: Auto Parry (%s)\nE: Manual Spam (%s)\nV: Smart Spam (%s)\nCTRL: Hide",
        Config.AutoParry and "ON" or "OFF", Config.ManualSpam and "ON" or "OFF", Config.AutoSpam and "ON" or "OFF")
end)

RS.Heartbeat:Connect(function()
    local ball = nil
    for _, b in pairs(workspace.Balls:GetChildren()) do
        if b:GetAttribute("realBall") then ball = b break end
    end
    
    if ball and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LP.Character.HumanoidRootPart.Position - ball.Position).Magnitude
        local isTarget = ball:GetAttribute("target") == LP.Name
        
        if (isTarget and Config.AutoParry and dist < 15) or 
           (isTarget and Config.AutoSpam and dist < 20) or 
           (Config.ManualSpam) then
            if remote then remote:FireServer() end
        end
    end
end)

print("SLY X V15.1 CHARGE AVEC SUCCES")
