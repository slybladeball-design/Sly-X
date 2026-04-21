-- SLY X (FINAL V4 - AUTONOMOUS)
-- FULL INTEGRATION: UI PREMIUM + ACHAOTIC ENGINE + PRINCEHUB SPAM
-- FEATURE: HYBRID AIM (CURSOR PC / CAMERA MOBILE)
-- FEATURE: SMART CLASH AUTO SPAM (NEVERZEN STYLE CLASH DETECTION)
-- FEATURE: MINIMIZE BUTTON (-) IN TOP RIGHT
-- FIX: AUTO SPAM ANIMATION FIX INTEGRATED

local GameServices = {
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    Camera = workspace.CurrentCamera,
    NetworkStats = game:GetService("Stats").Network.ServerStatsItem,
    SwordCollection = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("SwordAPI"),
    GuiService = game:GetService("GuiService")
}

local LocalPlayerData = {
    Player = GameServices.Players.LocalPlayer,
    Character = nil,
    Humanoid = nil
}

-- ═══════════════════════════════════════════════
-- SYSTÈME D'INTERFACE PREMIUM (INTÉGRÉ)
-- ═══════════════════════════════════════════════
local SlyUI_Theme = {
    Accent = Color3.fromRGB(204, 0, 0),
    Main = Color3.fromRGB(10, 10, 10),
    Secondary = Color3.fromRGB(18, 18, 18),
    Tertiary = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    Dim = Color3.fromRGB(160, 160, 160),
    Stroke = Color3.fromRGB(45, 45, 45)
}

local function SmoothTween(obj, info, goal)
    local tween = GameServices.TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    tween:Play()
    return tween
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SLY_X_GUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    if gethui then ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = game:GetService("CoreGui")
    else ScreenGui.Parent = game:GetService("CoreGui") end
end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = SlyUI_Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = SlyUI_Theme.Accent
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.2

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Active = true

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
GameServices.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "  SLY X"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = SlyUI_Theme.Accent
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE BUTTON (-) IN TOP RIGHT
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -40, 0.5, -15)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = SlyUI_Theme.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 24

local isMinimized = false
local originalSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        SmoothTween(MainFrame, {0.3}, {Size = UDim2.new(0, 580, 0, 45)})
    else
        MinimizeBtn.Text = "-"
        SmoothTween(MainFrame, {0.3}, {Size = originalSize})
    end
end)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 140, 1, -60)
TabContainer.Position = UDim2.new(0, 15, 0, 50)
TabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 6)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -180, 1, -60)
ContentContainer.Position = UDim2.new(0, 165, 0, 50)
ContentContainer.BackgroundTransparency = 1

local CurrentTab = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(1, 0, 0, 38)
    TabButton.BackgroundColor3 = SlyUI_Theme.Secondary
    TabButton.Text = name
    TabButton.TextColor3 = SlyUI_Theme.Dim
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.AutoButtonColor = false
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    local TabStroke = Instance.new("UIStroke", TabButton)
    TabStroke.Color = SlyUI_Theme.Stroke
    TabStroke.Thickness = 1
    TabStroke.Transparency = 0.5

    local TabPage = Instance.new("ScrollingFrame", ContentContainer)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 2
    TabPage.ScrollBarImageColor3 = SlyUI_Theme.Accent
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)

    TabButton.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Page.Visible = false
            SmoothTween(CurrentTab.Button, {0.2}, {TextColor3 = SlyUI_Theme.Dim, BackgroundColor3 = SlyUI_Theme.Secondary})
            SmoothTween(CurrentTab.Stroke, {0.2}, {Color = SlyUI_Theme.Stroke})
        end
        TabPage.Visible = true
        SmoothTween(TabButton, {0.2}, {TextColor3 = SlyUI_Theme.Accent, BackgroundColor3 = Color3.fromRGB(25, 12, 12)})
        SmoothTween(TabStroke, {0.2}, {Color = SlyUI_Theme.Accent})
        CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
    end)

    if not CurrentTab then
        TabPage.Visible = true
        TabButton.TextColor3 = SlyUI_Theme.Accent
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 12, 12)
        TabStroke.Color = SlyUI_Theme.Accent
        CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
    end

    local tab = {}
    function tab:AddToggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame", TabPage)
        ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
        ToggleFrame.BackgroundColor3 = SlyUI_Theme.Secondary
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", ToggleFrame).Color = SlyUI_Theme.Stroke
        
        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Text = "  " .. name
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = SlyUI_Theme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Button = Instance.new("TextButton", ToggleFrame)
        Button.Size = UDim2.new(0, 44, 0, 22)
        Button.Position = UDim2.new(1, -54, 0.5, -11)
        Button.BackgroundColor3 = default and SlyUI_Theme.Accent or Color3.fromRGB(40, 40, 40)
        Button.Text = ""
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 11)

        local Circle = Instance.new("Frame", Button)
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local state = default
        local function toggle(v)
            state = v
            SmoothTween(Button, {0.2}, {BackgroundColor3 = state and SlyUI_Theme.Accent or Color3.fromRGB(40, 40, 40)})
            SmoothTween(Circle, {0.2}, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
            callback(state)
        end
        Button.MouseButton1Click:Connect(function() toggle(not state) end)
        return {SetValue = function(_, v) toggle(v) end}
    end

    function tab:AddSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame", TabPage)
        SliderFrame.Size = UDim2.new(1, -10, 0, 58)
        SliderFrame.BackgroundColor3 = SlyUI_Theme.Secondary
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", SliderFrame).Color = SlyUI_Theme.Stroke
        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Text = "  " .. name .. ": " .. default
        Label.Size = UDim2.new(1, 0, 0, 32)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = SlyUI_Theme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local Bar = Instance.new("Frame", SliderFrame)
        Bar.Size = UDim2.new(1, -30, 0, 6)
        Bar.Position = UDim2.new(0, 15, 0, 40)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Instance.new("UICorner", Bar)
        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = SlyUI_Theme.Accent
        Instance.new("UICorner", Fill)
        local dragging = false
        local function update()
            local pos = math.clamp((GameServices.UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos)
            Label.Text = "  " .. name .. ": " .. val
            callback(val)
        end
        Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        GameServices.UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        GameServices.UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
        return {SetValue = function(_, v)
            local pos = math.clamp((v - min) / (max - min), 0, 1)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = "  " .. name .. ": " .. v
        end}
    end

    function tab:AddKeybind(name, default, callback)
        local BindFrame = Instance.new("Frame", TabPage)
        BindFrame.Size = UDim2.new(1, -10, 0, 42)
        BindFrame.BackgroundColor3 = SlyUI_Theme.Secondary
        Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", BindFrame).Color = SlyUI_Theme.Stroke
        local Label = Instance.new("TextLabel", BindFrame)
        Label.Text = "  " .. name
        Label.Size = UDim2.new(1, -100, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = SlyUI_Theme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local Button = Instance.new("TextButton", BindFrame)
        Button.Size = UDim2.new(0, 85, 0, 28)
        Button.Position = UDim2.new(1, -95, 0.5, -14)
        Button.BackgroundColor3 = SlyUI_Theme.Tertiary
        Button.Text = default.Name
        Button.TextColor3 = SlyUI_Theme.Accent
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 12
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", Button).Color = SlyUI_Theme.Stroke
        
        local isBinding = false
        Button.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            Button.Text = "..."
            local connection
            connection = GameServices.UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Button.Text = input.KeyCode.Name
                    callback(input.KeyCode)
                    connection:Disconnect()
                    task.wait(0.2)
                    isBinding = false
                end
            end)
        end)
    end

    function tab:AddInput(name, default, callback)
        local InputFrame = Instance.new("Frame", TabPage)
        InputFrame.Size = UDim2.new(1, -10, 0, 42)
        InputFrame.BackgroundColor3 = SlyUI_Theme.Secondary
        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", InputFrame).Color = SlyUI_Theme.Stroke
        local Label = Instance.new("TextLabel", InputFrame)
        Label.Text = "  " .. name
        Label.Size = UDim2.new(1, -100, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = SlyUI_Theme.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        local TextBox = Instance.new("TextBox", InputFrame)
        TextBox.Size = UDim2.new(0, 85, 0, 28)
        TextBox.Position = UDim2.new(1, -95, 0.5, -14)
        TextBox.BackgroundColor3 = SlyUI_Theme.Tertiary
        TextBox.Text = tostring(default)
        TextBox.TextColor3 = SlyUI_Theme.Accent
        TextBox.Font = Enum.Font.GothamBold
        TextBox.TextSize = 12
        TextBox.ClearTextOnFocus = false
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", TextBox).Color = SlyUI_Theme.Stroke
        TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
        return {SetValue = function(_, v) TextBox.Text = tostring(v) end}
    end

    return tab
end

-- ═══════════════════════════════════════════════
-- LOGIQUE DE COMBAT & SPAM (PRINCEHUB + ACHAOTIC)
-- ═══════════════════════════════════════════════
local AnimCache = {}
local lastSpamAnimPlayTime = 0

local function getAchaoticParryAnim()
    local char = LocalPlayerData.Player.Character
    if not char then return nil end
    local sword = char:GetAttribute("CurrentlyEquippedSword")
    local key = tostring(sword or "__nil")
    if AnimCache[key] then return AnimCache[key] end
    local anim
    pcall(function()
        local weaponData = GameServices.ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword)
        if weaponData and weaponData.AnimationType then
            local style = GameServices.SwordCollection.Collection:FindFirstChild(weaponData.AnimationType)
            if style then anim = style:FindFirstChild("GrabParry") or style:FindFirstChild("Grab") end
        end
    end)
    if not anim then anim = GameServices.SwordCollection.Collection.Default:FindFirstChild("GrabParry") end
    AnimCache[key] = anim
    return anim
end

local function playAchaoticAnim()
    local char = LocalPlayerData.Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = getAchaoticParryAnim()
    if not anim then return end
    for _, t in pairs(hum.Animator:GetPlayingAnimationTracks()) do
        if t.Name == "GrabParry" or t.Name == "Grab" or t.Name == "SuccessParry" then t:Stop(0.05) end
    end
    local track = hum.Animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play(0.05, 1, 1.5)
end

local function playPrinceHubSpamAnim()
    local char = LocalPlayerData.Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = getAchaoticParryAnim()
    if not anim then return end
    local now = os.clock()
    if (now - lastSpamAnimPlayTime) >= 0.08 then
        lastSpamAnimPlayTime = now
        local track = hum.Animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0, 1, 2.5)
        task.delay(0.1, function() track:Stop(0) end)
    end
end

local remote, f_raw = nil, nil
local c = table.create(7)
local spamEnabled = false
local TargetCPS = 120
local CurrentRate = 1 / TargetCPS

do
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if key == "FireServer" or key == "InvokeServer" then
            return function(_, ...)
                local a = {...}
                if #a == 7 and typeof(a[4]) == "CFrame" then
                    remote = self
                    f_raw = self.FireServer
                    for i = 1, 7 do c[i] = a[i] end
                end
                return old(self, key)(self, ...)
            end
        end
        return old(self, key)
    end)
    setreadonly(mt, true)
end

local ParrySystem = {
    SpeedMultiplier = 1.1,
    AutoEnabled = false,
    AutoAnimationFixEnabled = true,
    AutoSpamEnabled = false,
    AutoSpamming = false,
    ManualSpamming = false,
    ManualSpamKeybind = Enum.KeyCode.E,
    AutoParryKeybind = Enum.KeyCode.X,
    AutoSpamKeybind = Enum.KeyCode.V,
    ManualSpamAnimationFixEnabled = true,
    AutoSpamAnimationFixEnabled = true,
    ParriedLastBall = false,
    TornadoActiveTime = 0,
    LastKeybindChange = 0,
    MobileButtonEnabled = false,
    ParryHistory = {},
    LastParryTime = 0
}

-- HYBRID AIM LOGIC (CURSOR FOR PC / CAMERA FOR MOBILE)
local function getAimDirection()
    local isMobile = GameServices.UserInputService.TouchEnabled and not GameServices.UserInputService.MouseEnabled
    if isMobile then
        return GameServices.Camera.CFrame
    else
        local mousePos = GameServices.UserInputService:GetMouseLocation()
        local ray = GameServices.Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        return CFrame.new(ray.Origin, ray.Origin + ray.Direction)
    end
end

local threadGeneration = 0
local bgThreadActive = false

local function spawnSpamThread(idx, total, gen)
    task.spawn(function()
        local phaseOffset = (idx / total) * CurrentRate
        task.wait(phaseOffset)
        local nextClick = os.clock()
        while spamEnabled and threadGeneration == gen do
            local now = os.clock()
            if now > nextClick + 0.05 then nextClick = now end
            while now >= nextClick do
                if remote and f_raw then 
                    c[4] = getAimDirection()
                    pcall(f_raw, remote, table.unpack(c)) 
                end
                local mp = GameServices.UserInputService:GetMouseLocation()
                GameServices.VirtualInputManager:SendMouseButtonEvent(mp.X, mp.Y, 0, true, game, 1)
                GameServices.VirtualInputManager:SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 1)
                
                -- ANIMATION FIX INTEGRATION (FOR BOTH MANUAL AND AUTO SPAM)
                if (ParrySystem.ManualSpamming and ParrySystem.ManualSpamAnimationFixEnabled) or (ParrySystem.AutoSpamming and ParrySystem.AutoSpamAnimationFixEnabled) then
                    playPrinceHubSpamAnim()
                end
                
                nextClick = nextClick + CurrentRate
            end
            GameServices.RunService.Heartbeat:Wait()
        end
    end)
end

local function startSpam()
    if bgThreadActive then return end
    bgThreadActive = true
    threadGeneration = threadGeneration + 1
    local gen = threadGeneration
    local n = TargetCPS <= 120 and 1 or (TargetCPS <= 600 and 4 or 8)
    for i = 0, n - 1 do spawnSpamThread(i, n, gen) end
end

local function stopSpam()
    threadGeneration = threadGeneration + 1
    bgThreadActive = false
end

local function ToggleManualSpam(state)
    ParrySystem.ManualSpamming = state
    spamEnabled = ParrySystem.ManualSpamming or ParrySystem.AutoSpamming
    if state then startSpam() else stopSpam() end
end

-- ═══════════════════════════════════════════════
-- MOBILE SPAM BUTTON SYSTEM
-- ═══════════════════════════════════════════════
local MobileSpamButton = Instance.new("TextButton")
MobileSpamButton.Name = "SlyX_MobileSpam"
MobileSpamButton.Size = UDim2.new(0, 50, 0, 50)
MobileSpamButton.Position = UDim2.new(0.8, 0, 0.5, 0)
MobileSpamButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MobileSpamButton.Text = "SPAM"
MobileSpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileSpamButton.Font = Enum.Font.GothamBold
MobileSpamButton.TextSize = 12
MobileSpamButton.Visible = false
MobileSpamButton.Parent = ScreenGui
Instance.new("UICorner", MobileSpamButton).CornerRadius = UDim.new(0, 10)
local MobileStroke = Instance.new("UIStroke", MobileSpamButton)
MobileStroke.Color = SlyUI_Theme.Accent
MobileStroke.Thickness = 2

-- Draggable Mobile Button
local mDragging, mDragStart, mStartPos
MobileSpamButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mDragging = true
        mDragStart = input.Position
        mStartPos = MobileSpamButton.Position
    end
end)
GameServices.UserInputService.InputChanged:Connect(function(input)
    if mDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - mDragStart
        MobileSpamButton.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
    end
end)
GameServices.UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mDragging = false
    end
end)

-- ═══════════════════════════════════════════════
-- CONSTRUCTION DE L'UI
-- ═══════════════════════════════════════════════
local CombatTab = CreateTab("Combat")
local SettingsTab = CreateTab("Settings")

local apToggle = CombatTab:AddToggle("Auto Parry", false, function(v) ParrySystem.AutoEnabled = v end)
CombatTab:AddSlider("Accuracy", 0, 100, 100, function(v) ParrySystem.SpeedMultiplier = 0.7 + (v/100)*0.35 end)
CombatTab:AddKeybind("Parry Key", Enum.KeyCode.X, function(k) 
    ParrySystem.AutoParryKeybind = k 
    ParrySystem.LastKeybindChange = tick()
end)
CombatTab:AddToggle("AP Anim Fix", true, function(v) ParrySystem.AutoAnimationFixEnabled = v end)

local asToggle = CombatTab:AddToggle("Auto Spam", false, function(v) 
    ParrySystem.AutoSpamEnabled = v 
    -- Logic is handled in Heartbeat for Smart Clash Detection
end)
CombatTab:AddKeybind("Auto Spam Key", Enum.KeyCode.V, function(k) 
    ParrySystem.AutoSpamKeybind = k 
    ParrySystem.LastKeybindChange = tick()
end)

local msToggle = CombatTab:AddToggle("Manual Spam", false, function(v) ToggleManualSpam(v) end)
CombatTab:AddKeybind("Manual Spam Key", Enum.KeyCode.E, function(k) 
    ParrySystem.ManualSpamKeybind = k 
    ParrySystem.LastKeybindChange = tick()
end)

local speedSlider = SettingsTab:AddSlider("Spam Speed", 50, 5000, 120, function(v) 
    TargetCPS = v 
    CurrentRate = 1 / TargetCPS
    if spamEnabled then stopSpam() task.wait() startSpam() end
end)

SettingsTab:AddInput("Custom CPS", 120, function(v)
    local val = tonumber(v)
    if val and val >= 1 and val <= 10000 then
        TargetCPS = val
        CurrentRate = 1 / TargetCPS
        speedSlider:SetValue(math.clamp(val, 50, 5000))
        if spamEnabled then stopSpam() task.wait() startSpam() end
    end
end)

SettingsTab:AddToggle("Mobile Button", false, function(v)
    ParrySystem.MobileButtonEnabled = v
    MobileSpamButton.Visible = v
end)

MobileSpamButton.MouseButton1Click:Connect(function()
    ToggleManualSpam(not ParrySystem.ManualSpamming)
    msToggle:SetValue(ParrySystem.ManualSpamming)
    MobileSpamButton.BackgroundColor3 = ParrySystem.ManualSpamming and SlyUI_Theme.Accent or Color3.fromRGB(40, 40, 40)
end)

-- ═══════════════════════════════════════════════
-- AUTHENTIC BB ACHAOTIC ENGINE & SMART CLASH AUTO SPAM
-- ═══════════════════════════════════════════════
local function getBall()
    for _, ball in pairs(GameServices.Workspace:WaitForChild("Balls"):GetChildren()) do
        if ball:GetAttribute("realBall") == true then return ball end
    end
end

local function isTargetingMe(ball)
    return ball:GetAttribute("target") == tostring(LocalPlayerData.Player)
end

local function getAchaoticHitbox(ball, playerPos, ballPos, ballSpeed, ping)
    local baseHitbox = 12
    local latencyFactor = (ping * ballSpeed) * 1.6
    local speedFactor = (ballSpeed / 22)
    return (baseHitbox + latencyFactor + speedFactor) * ParrySystem.SpeedMultiplier
end

GameServices.UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif not processed then
        if (tick() - ParrySystem.LastKeybindChange) < 0.3 then return end
        if input.KeyCode == ParrySystem.AutoParryKeybind then
            ParrySystem.AutoEnabled = not ParrySystem.AutoEnabled
            apToggle:SetValue(ParrySystem.AutoEnabled)
        elseif input.KeyCode == ParrySystem.ManualSpamKeybind then
            ToggleManualSpam(not ParrySystem.ManualSpamming)
            msToggle:SetValue(ParrySystem.ManualSpamming)
            MobileSpamButton.BackgroundColor3 = ParrySystem.ManualSpamming and SlyUI_Theme.Accent or Color3.fromRGB(40, 40, 40)
        elseif input.KeyCode == ParrySystem.AutoSpamKeybind then
            ParrySystem.AutoSpamEnabled = not ParrySystem.AutoSpamEnabled
            asToggle:SetValue(ParrySystem.AutoSpamEnabled)
        end
    end
end)

GameServices.RunService.Heartbeat:Connect(function()
    local ball = getBall()
    local char = LocalPlayerData.Player.Character
    if not char or not char.PrimaryPart then return end
    local playerPos = char.PrimaryPart.Position

    -- SMART CLASH AUTO SPAM LOGIC
    if ParrySystem.AutoSpamEnabled then
        local now = tick()
        -- Clean old parries from history (older than 1.5s)
        for i = #ParrySystem.ParryHistory, 1, -1 do
            if now - ParrySystem.ParryHistory[i] > 1.5 then
                table.remove(ParrySystem.ParryHistory, i)
            end
        end

        -- Activation: 3 parries in 1.5s = CLASH
        if #ParrySystem.ParryHistory >= 3 then
            if not ParrySystem.AutoSpamming then
                ParrySystem.AutoSpamming = true
                spamEnabled = true
                startSpam()
            end
        else
            -- Deactivation: No parry for 1s
            if ParrySystem.AutoSpamming and (now - ParrySystem.LastParryTime > 1.0) then
                ParrySystem.AutoSpamming = false
                spamEnabled = ParrySystem.ManualSpamming
                if not spamEnabled then stopSpam() end
            end
        end
    end

    if ball and isTargetingMe(ball) then
        local ballPos = ball.Position
        local velocityData = ball:FindFirstChild("zoomies")
        if not velocityData then return end
        local ballVelocity = velocityData.VectorVelocity
        local ballSpeed = ballVelocity.Magnitude
        local ping = GameServices.NetworkStats["Data Ping"]:GetValue() / 1000
        local distance = (playerPos - ballPos).Magnitude

        -- AUTO PARRY LOGIC (ACHAOTIC ENGINE)
        if ParrySystem.AutoEnabled then
            local directionToPlayer = (playerPos - ballPos).Unit
            local ballDirection = ballVelocity.Unit
            local dotProduct = ballDirection:Dot(directionToPlayer)
            if dotProduct > 0.25 then
                local hitboxSize = getAchaoticHitbox(ball, playerPos, ballPos, ballSpeed, ping)
                if ball:FindFirstChild("AeroDynamicSlashVFX") then ParrySystem.TornadoActiveTime = tick() end
                local tornado = GameServices.Workspace.Runtime:FindFirstChild("Tornado")
                if tornado then
                    local tTime = tornado:GetAttribute("TornadoTime") or 1
                    if (tick() - ParrySystem.TornadoActiveTime) < tTime + 0.3 then return end
                end
                if distance <= hitboxSize and not ParrySystem.ParriedLastBall then
                    if remote and f_raw then
                        c[4] = getAimDirection()
                        pcall(f_raw, remote, table.unpack(c))
                        if ParrySystem.AutoAnimationFixEnabled then playAchaoticAnim() end
                        
                        -- Record Parry for Clash Detection
                        ParrySystem.LastParryTime = tick()
                        table.insert(ParrySystem.ParryHistory, ParrySystem.LastParryTime)
                        
                        ParrySystem.ParriedLastBall = true
                        task.delay(0.25, function() ParrySystem.ParriedLastBall = false end)
                    end
                end
            end
        end
    else
        ParrySystem.ParriedLastBall = false
    end
end)

print("SLY X FINAL V4 LOADED (CLASH AUTO SPAM + ANIM FIX)")
