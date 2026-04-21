-- SLY X PREMIUM V18 (FINAL STABLE - NO OBFUSCATION)
-- FEATURES: PREMIUM UI, PRINCEHUB ANIM FIX, SMART SPAM, MINIMIZE
print("Initialisation SLY X PREMIUM...")

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- CONFIGURATION
local Config = {
    AutoParry = true,
    ManualSpam = false,
    AutoSpam = false,
    AnimFix = true,
    Accent = Color3.fromRGB(204, 0, 0)
}

local AnimCache = {}
local lastAnim = 0
local remote = nil

-- MOTEUR D'ANIMATION PRINCEHUB (FLUIDE)
local function playPrinceAnim()
    if not Config.AnimFix then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local now = os.clock()
    if (now - lastAnim) < (1/15) then return end
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
        track:Play(0, 1, 2.5)
        task.delay(0.1, function() track:Stop(0) end)
    end
end

-- UI PREMIUM SYSTEM
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SlyX_Premium_V18"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 220)
Main.Position = UDim2.new(0.5, -175, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Config.Accent
Stroke.Thickness = 2

-- DRAGGABLE
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- TITLE & MINIMIZE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Text = "  SLY X PREMIUM"
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TS:Create(Main, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 150, 0, 40) or UDim2.new(0, 350, 0, 220)}):Play()
    MinBtn.Text = minimized and "+" or "-"
end)

-- BUTTONS
local function CreateToggle(name, pos, default, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 330, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, pos)
    Btn.BackgroundColor3 = default and Color3.fromRGB(30, 10, 10) or Color3.fromRGB(20, 20, 20)
    Btn.Text = name .. ": " .. (default and "ON" or "OFF")
    Btn.TextColor3 = default and Config.Accent or Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 14
    Instance.new("UICorner", Btn)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. ": " .. (state and "ON" or "OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(30, 10, 10) or Color3.fromRGB(20, 20, 20)
        Btn.TextColor3 = state and Config.Accent or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

CreateToggle("Auto Parry [X]", 50, Config.AutoParry, function(v) Config.AutoParry = v end)
CreateToggle("Manual Spam [E]", 90, Config.ManualSpam, function(v) Config.ManualSpam = v end)
CreateToggle("Smart Auto Spam [V]", 130, Config.AutoSpam, function(v) Config.AutoSpam = v end)
CreateToggle("Animation Fix", 170, Config.AnimFix, function(v) Config.AnimFix = v end)

-- COMBAT ENGINE
pcall(function() remote = Rep:WaitForChild("Remotes"):WaitForChild("Parry") end)

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

UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.LeftControl then ScreenGui.Enabled = not ScreenGui.Enabled end
end)

print("SLY X PREMIUM V18 CHARGÉ !")
