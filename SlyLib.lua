-- SLY X V27 FULL EDITION
-- TOUT-EN-UN (PAS BESOIN DE CHARGEMENT EXTERNE SI GITHUB BUG)

local success, UiLibrary = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/slybladeball-design/Sly-X/refs/heads/main/SlyLib.lua"))()
end)

if not success or not UiLibrary then
    warn("SLY X: Erreur de chargement GitHub, utilisation de la version de secours...")
    -- Version de secours simplifiée si GitHub échoue
    UiLibrary = {
        new = function() 
            print("SLY X: UI de secours activée")
            return {AddTab = function() return {AddSection = function() return {AddToggle = function() return {SetValue = function() end} end, AddSlider = function() end, AddKeybind = function() end} end end end, AddLabel = function() end}
        end,
        CreateNotifier = function() return {new = function() end} end
    }
end

-- Forcer le thème Rouge & Noir
pcall(function()
    if UiLibrary.Themes then
        UiLibrary.Themes.Default = {
            Main = Color3.fromRGB(0, 0, 0),
            Secondary = Color3.fromRGB(8, 8, 8),
            Card = Color3.fromRGB(14, 14, 14),
            Accent = Color3.fromRGB(204, 0, 0),
            AccentGlow = Color3.fromRGB(255, 51, 51),
            Text = Color3.fromRGB(208, 208, 208),
            TextSecondary = Color3.fromRGB(170, 170, 170),
            Dim = Color3.fromRGB(96, 96, 96),
            Stroke = Color3.fromRGB(30, 30, 30),
            Line = Color3.fromRGB(30, 30, 30)
        }
    end
end)

local GameServices = {
    Notifier = UiLibrary:CreateNotifier(),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TweenService = game:GetService("TweenService"),
    Camera = workspace.CurrentCamera,
    NetworkStats = game:GetService("Stats").Network.ServerStatsItem,
    SwordCollection = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("SwordAPI")
}

local LocalPlayerData = {
    Player = GameServices.Players.LocalPlayer,
    Character = nil,
    Humanoid = nil
}

-- Stream Proof Permanent
local function ApplyStreamProof(gui)
    if not gui then return end
    pcall(function()
        if gethui then gui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = GameServices.Players.LocalPlayer:WaitForChild("PlayerGui")
        else gui.Parent = GameServices.Players.LocalPlayer:WaitForChild("PlayerGui") end
    end)
end

local UserInterface = {
    MainWindow = UiLibrary.new({
        Name = "SLY X",
        Keybind = Enum.KeyCode.LeftControl,
        Scale = UDim2.new(0, 611, 0, 396),
        Resizable = true,
        Shadow = true,
        Acrylic = false
    }),
    ManualSpamToggleReference = nil,
    AutoParryToggleReference = nil,
    AutoSpamToggleReference = nil
}

local MainGui = UserInterface.MainWindow.ScreenGui
if MainGui then ApplyStreamProof(MainGui) end

-- ═══════════════════════════════════════════════
-- VARIABLES & CAPTURE DE REMOTES
-- ═══════════════════════════════════════════════
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
    AnimationRegistry = {},
    LastExecutionTime = 0,
    LastAnimTime = 0,
    ParriedLastBall = false
}

-- ═══════════════════════════════════════════════
-- FORCE ANIMATION ENGINE
-- ═══════════════════════════════════════════════
local function GetPlayerCharacter() return LocalPlayerData.Player.Character end
local function GetPlayerHumanoid() local c = GetPlayerCharacter() return c and c:FindFirstChildOfClass("Humanoid") end

local function ResolveParryAnimation()
    local c = GetPlayerCharacter()
    if not c then return nil end
    local equipped = c:GetAttribute("CurrentlyEquippedSword") or "Default"
    if ParrySystem.AnimationRegistry[equipped] then return ParrySystem.AnimationRegistry[equipped] end
    
    local anim = nil
    pcall(function()
        local weaponData = GameServices.ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(equipped)
        if weaponData and weaponData.AnimationType then
            local style = GameServices.SwordCollection.Collection:FindFirstChild(weaponData.AnimationType)
            if style then anim = style:FindFirstChild("GrabParry") or style:FindFirstChild("Grab") end
        end
    end)
    if not anim then anim = GameServices.SwordCollection.Collection.Default:FindFirstChild("GrabParry") end
    ParrySystem.AnimationRegistry[equipped] = anim
    return anim
end

local function ExecuteForceAnimation()
    local now = tick()
    if now - ParrySystem.LastAnimTime < 0.03 then return end
    ParrySystem.LastAnimTime = now
    
    local h = GetPlayerHumanoid()
    if not h then return end
    local anim = ResolveParryAnimation()
    if not anim then return end
    
    local track = h.Animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play(0, 1, 1.5)
    task.delay(0.1, function() track:Stop() end)
end

-- ═══════════════════════════════════════════════
-- MOTEUR DE SPAM (HYBRIDE STABLE)
-- ═══════════════════════════════════════════════
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
                    pcall(f_raw, remote, table.unpack(c))
                    if (ParrySystem.ManualSpamming and ParrySystem.ManualSpamAnimationFixEnabled) or (ParrySystem.AutoSpamming and ParrySystem.AutoSpamAnimationFixEnabled) then
                        ExecuteForceAnimation()
                    end
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

-- ═══════════════════════════════════════════════
-- AUTO PARRY (LOGIQUE FICHIER 2)
-- ═══════════════════════════════════════════════
local function FetchActiveBalls()
    local ballsList = {}
    for _, ballInstance in pairs(GameServices.Workspace:WaitForChild("Balls"):GetChildren()) do
        if ballInstance:GetAttribute("realBall") then
            table.insert(ballsList, ballInstance)
        end
    end
    return ballsList
end

local function IsBallCurved(ball)
    if not ball then return false end
    local velocityTracker = ball:FindFirstChild("zoomies")
    if not velocityTracker then return false end
    local ballVelocity = velocityTracker.VectorVelocity
    local ballDirection = ballVelocity.Unit
    local playerPosition = LocalPlayerData.Player.Character.PrimaryPart.Position
    local ballPosition = ball.Position
    local directionToPlayer = (playerPosition - ballPosition).Unit
    return directionToPlayer:Dot(ballDirection) < 0.5
end

local function GetNearestOpponent()
    local minimumDistance = math.huge
    local closestOpponent = nil
    for _, opponentCharacter in pairs(GameServices.Workspace.Alive:GetChildren()) do
        if opponentCharacter ~= LocalPlayerData.Player.Character and opponentCharacter.PrimaryPart then
            local distanceToOpponent = (LocalPlayerData.Player.Character.PrimaryPart.Position - opponentCharacter.PrimaryPart.Position).Magnitude
            if distanceToOpponent < minimumDistance then
                minimumDistance = distanceToOpponent
                closestOpponent = opponentCharacter
            end
        end
    end
    return closestOpponent, minimumDistance
end

-- ═══════════════════════════════════════════════
-- BOUTON MOBILE
-- ═══════════════════════════════════════════════
local MobileSpamButton = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

MobileSpamButton.Name = "SlyXMobile"
MobileSpamButton.ResetOnSpawn = false
MobileSpamButton.Enabled = false
ApplyStreamProof(MobileSpamButton)

MainButton.Name = "SpamButton"
MainButton.Parent = MobileSpamButton
MainButton.BackgroundColor3 = Color3.fromRGB(204, 0, 0)
MainButton.Position = UDim2.new(0.85, 0, 0.5, 0)
MainButton.Size = UDim2.new(0, 60, 0, 60)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "OFF"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 14
MainButton.Draggable = true
MainButton.Active = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainButton

local function ToggleManualSpam(state)
    ParrySystem.ManualSpamming = state
    spamEnabled = ParrySystem.ManualSpamming or ParrySystem.AutoSpamming
    if state then
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 204, 0)
        MainButton.Text = "ON"
        startSpam()
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(204, 0, 0)
        MainButton.Text = "OFF"
        stopSpam()
    end
    if UserInterface.ManualSpamToggleReference then
        UserInterface.ManualSpamToggleReference:SetValue(state)
    end
end

MainButton.MouseButton1Click:Connect(function()
    ToggleManualSpam(not ParrySystem.ManualSpamming)
end)

-- ═══════════════════════════════════════════════
-- UI CONSTRUCTION
-- ═══════════════════════════════════════════════
do
    UserInterface.MainWindow:AddLabel('General')
    local combatTab = UserInterface.MainWindow:AddTab({ Name = "Combat", Icon = "swords" })
    local exclusiveTab = UserInterface.MainWindow:AddTab({ Name = "Exclusive", Icon = "layers" })
    local settingsTab = UserInterface.MainWindow:AddTab({ Name = "Settings", Icon = "settings" })

    local apSection = combatTab:AddSection({ Name = "Auto Parry", Position = "left" })
    UserInterface.AutoParryToggleReference = apSection:AddToggle({
        Name = 'Enabled', Default = false, Callback = function(v) ParrySystem.AutoEnabled = v end,
    })
    apSection:AddSlider({
        Name = "Accuracy", Min = 0, Max = 100, Default = 100, Callback = function(v) ParrySystem.SpeedMultiplier = 0.7 + (v/100)*0.35 end,
    })
    apSection:AddKeybind({
        Name = "Keybind", Default = "X", Callback = function(k) ParrySystem.AutoParryKeybind = k end,
    })
    apSection:AddToggle({
        Name = 'Animation Fix', Default = true, Callback = function(v) ParrySystem.AutoAnimationFixEnabled = v end,
    })

    local asSection = combatTab:AddSection({ Name = "Auto Spam Parry", Position = "right" })
    UserInterface.AutoSpamToggleReference = asSection:AddToggle({
        Name = 'Enabled', Default = false, Callback = function(v) 
            ParrySystem.AutoSpamEnabled = v 
            if not v then 
                ParrySystem.AutoSpamming = false
                spamEnabled = ParrySystem.ManualSpamming
                if not spamEnabled then stopSpam() end
            end
        end,
    })
    asSection:AddKeybind({
        Name = "Keybind", Default = "V", Callback = function(k) ParrySystem.AutoSpamKeybind = k end,
    })
    asSection:AddToggle({
        Name = 'Animation Fix', Default = true, Callback = function(v) ParrySystem.AutoSpamAnimationFixEnabled = v end,
    })

    local msSection = combatTab:AddSection({ Name = "Manual Spam Parry", Position = "right" })
    UserInterface.ManualSpamToggleReference = msSection:AddToggle({
        Name = 'Spam', Default = false, Callback = function(v) ToggleManualSpam(v) end,
    })
    msSection:AddKeybind({
        Name = "Keybind", Default = "E", Callback = function(k) ParrySystem.ManualSpamKeybind = k end,
    })
    msSection:AddToggle({
        Name = 'Mobile Button', Default = false, Callback = function(v) MobileSpamButton.Enabled = v end,
    })
    msSection:AddToggle({
        Name = 'Animation Fix', Default = true, Callback = function(v) ParrySystem.ManualSpamAnimationFixEnabled = v end,
    })

    local immortalitySection = exclusiveTab:AddSection({ Name = "Immortality", Position = "left" })
    immortalitySection:AddToggle({ Name = 'Enabled', Default = false, Callback = function(v) end })
    
    local spamSettings = settingsTab:AddSection({ Name = "Spamming", Position = "left" })
    spamSettings:AddSlider({
        Name = "Max Speed", Min = 50, Max = 5000, Default = 120, Callback = function(v) 
            TargetCPS = v 
            CurrentRate = 1 / TargetCPS
            if spamEnabled then stopSpam() task.wait() startSpam() end
        end,
    })
end

-- ═══════════════════════════════════════════════
-- BOUCLE PRINCIPALE
-- ═══════════════════════════════════════════════
GameServices.UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        local gui = UserInterface.MainWindow.ScreenGui
        if gui then gui.Enabled = not gui.Enabled end
    elseif not processed then
        if input.KeyCode == ParrySystem.ManualSpamKeybind then
            ToggleManualSpam(not ParrySystem.ManualSpamming)
        elseif input.KeyCode == ParrySystem.AutoParryKeybind then
            ParrySystem.AutoEnabled = not ParrySystem.AutoEnabled
            UserInterface.AutoParryToggleReference:SetValue(ParrySystem.AutoEnabled)
        elseif input.KeyCode == ParrySystem.AutoSpamKeybind then
            ParrySystem.AutoSpamEnabled = not ParrySystem.AutoSpamEnabled
            UserInterface.AutoSpamToggleReference:SetValue(ParrySystem.AutoSpamEnabled)
        end
    end
end)

GameServices.RunService.Heartbeat:Connect(function()
    if ParrySystem.AutoEnabled then
        local activeBalls = FetchActiveBalls()
        for _, ball in pairs(activeBalls) do
            if not ball then continue end
            local velocityData = ball:FindFirstChild("zoomies")
            if not velocityData then continue end
            
            ball:GetAttributeChangedSignal("target"):Once(function() ParrySystem.ParriedLastBall = false end)
            if ParrySystem.ParriedLastBall then continue end
            
            local targetPlayer = ball:GetAttribute("target")
            local ballVelocity = velocityData.VectorVelocity
            local distanceSafe = (LocalPlayerData.Player.Character.PrimaryPart.Position - ball.Position).Magnitude - 5
            local networkLatency = GameServices.NetworkStats["Data Ping"]:GetValue() / 10
            local latencyThreshold = math.clamp(networkLatency / 10, 5, 17)
            local ballSpeed = ballVelocity.Magnitude * 1.5
            local cappedSpeedDifference = math.min(math.max(ballSpeed - 9.5, 0), 650)
            local baseSpeedDivisor = 2.4 + cappedSpeedDifference * 0.002
            local adjustedSpeedDivisor = baseSpeedDivisor * ParrySystem.SpeedMultiplier
            local requiredAccuracy = latencyThreshold + math.max(ballSpeed / adjustedSpeedDivisor, 9.5) + (distanceSafe / 75)
            
            if targetPlayer == tostring(LocalPlayerData.Player) and distanceSafe <= requiredAccuracy and not IsBallCurved(ball) then
                local executionTime = os.clock()
                if executionTime - ParrySystem.LastExecutionTime > 0.1 then
                    if ParrySystem.AutoAnimationFixEnabled then ExecuteForceAnimation() end
                    if remote and f_raw then pcall(f_raw, remote, table.unpack(c)) end
                    ParrySystem.LastExecutionTime = executionTime
                    ParrySystem.ParriedLastBall = true
                end
            end
        end
    end

    if ParrySystem.AutoSpamEnabled then
        local activeBalls = FetchActiveBalls()
        local shouldSpam = false
        for _, ball in pairs(activeBalls) do
            local nearest, distToTarget = GetNearestOpponent()
            local playerRoot = LocalPlayerData.Player.Character and LocalPlayerData.Player.Character.PrimaryPart
            if not playerRoot or not nearest then continue end
            if (playerRoot.Position - ball.Position).Magnitude <= 45 and distToTarget <= 30 then
                shouldSpam = true
                break
            end
        end
        if shouldSpam ~= ParrySystem.AutoSpamming then
            ParrySystem.AutoSpamming = shouldSpam
            spamEnabled = ParrySystem.ManualSpamming or ParrySystem.AutoSpamming
            if spamEnabled then startSpam() else stopSpam() end
        end
    end
end)

GameServices.Notifier.new('SLY X', 'SLY X v27 FULL Loaded', 10)
