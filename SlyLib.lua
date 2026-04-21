-- SLY X V17 (SOURCE CLAIRE - ANIMATION FIX PRINCEHUB)
-- OPTIMISÉ POUR MADIUM & MOBILE
print("Chargement SLY X V17...")

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")

-- CONFIGURATION
local Config = {
    AutoParry = true,
    ManualSpam = false,
    AutoSpam = false,
    AnimFix = true,
    CPS = 120 -- Vitesse de spam
}

local AnimCache = {}
local lastAnim = 0

-- MOTEUR D'ANIMATION PRINCEHUB (FLUIDE)
local function playPrinceAnim()
    if not Config.AnimFix then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local now = os.clock()
    if (now - lastAnim) < (1/15) then return end -- Limite pour éviter le glitch
    lastAnim = now

    local sword = char:GetAttribute("CurrentlyEquippedSword") or "Default"
    if not AnimCache[sword] then
        pcall(function()
            local style = Rep.Shared.SwordAPI.Collection.Default
            AnimCache[sword] = style:FindFirstChild("GrabParry") or style:FindFirstChild("Grab")
        end)
    end
    
    if AnimCache[sword] then
        local track = hum.Animator:LoadAnimation(AnimCache[sword])
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0, 1, 2.5) -- Vitesse d'animation PrinceHub
        task.delay(0.1, function() track:Stop(0) end)
    end
end

-- UI PREMIUM LITE (SANS CRASH)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 140)
main.Position = UDim2.new(0.5, -110, 0.5, -70)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(204, 0, 0)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "SLY X V17"
title.TextColor3 = Color3.fromRGB(204, 0, 0)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, 0, 1, -30)
status.Position = UDim2.new(0, 0, 0, 30)
status.Text = "X: Auto Parry (ON)\nE: Manual Spam (OFF)\nV: Smart Spam (OFF)\nCTRL: Hide"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.Font = Enum.Font.GothamMedium
status.BackgroundTransparency = 1

-- COMBAT ENGINE
local remote = nil
pcall(function() remote = Rep:WaitForChild("Remotes"):WaitForChild("Parry") end)

UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.X then Config.AutoParry = not Config.AutoParry
    elseif i.KeyCode == Enum.KeyCode.E then Config.ManualSpam = not Config.ManualSpam
    elseif i.KeyCode == Enum.KeyCode.V then Config.AutoSpam = not Config.AutoSpam
    elseif i.KeyCode == Enum.KeyCode.LeftControl then sg.Enabled = not sg.Enabled end
    status.Text = string.format("X: Auto Parry (%s)\nE: Manual Spam (%s)\nV: Smart Spam (%s)\nCTRL: Hide",
        Config.AutoParry and "ON" or "OFF", Config.ManualSpam and "ON" or "OFF", Config.AutoSpam and "ON" or "OFF")
end)

RS.Heartbeat:Connect(function()
    local ball = nil
    for _, b in pairs(workspace.Balls:GetChildren()) do if b:GetAttribute("realBall") then ball = b break end end
    if not ball or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart.Position
    local dist = (hrp - ball.Position).Magnitude
    local isTarget = ball:GetAttribute("target") == LP.Name
    
    if (isTarget and Config.AutoParry and dist < 15) or 
       (isTarget and Config.AutoSpam and dist < 20) or 
       (Config.ManualSpam) then
        if remote then 
            remote:FireServer() 
            playPrinceAnim()
        end
    end
end)

print("SLY X V17 CHARGÉ !")
