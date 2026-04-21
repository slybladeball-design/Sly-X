-- SLY X V14.5 (MADIUM OPTIMIZED)
local success, err = pcall(function()
    -- SERVICES & VARIABLES
    local LP = game:GetService("Players").LocalPlayer
    local RS = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Rep = game:GetService("ReplicatedStorage")
    local AnimCache = {}
    local lastSpam = 0
    local spamming = false
    local autoSpam = false
    local autoParry = true

    -- UI PREMIUM LITE
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 220, 0, 130)
    main.Position = UDim2.new(0.5, -110, 0.5, -65)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", main)
    st.Color = Color3.fromRGB(204, 0, 0)
    st.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "SLY X - MADIUM EDITION"
    title.TextColor3 = Color3.fromRGB(204, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14

    local info = Instance.new("TextLabel", main)
    info.Position = UDim2.new(0, 0, 0, 35)
    info.Size = UDim2.new(1, 0, 0, 80)
    info.Text = "[X] Auto Parry: ON\n[E] Manual Spam: OFF\n[V] Smart Spam: OFF\n[CTRL] Hide Menu"
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.Font = Enum.Font.GothamMedium
    info.TextSize = 12

    -- ANIMATION FIX (PRINCEHUB STYLE)
    local function playAnim()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local sword = char:GetAttribute("CurrentlyEquippedSword") or "Default"
        if not AnimCache[sword] then
            pcall(function()
                local style = Rep.Shared.SwordAPI.Collection.Default
                AnimCache[sword] = style:FindFirstChild("GrabParry") or style:FindFirstChild("Grab")
            end)
        end
        if AnimCache[sword] and os.clock() - lastSpam > 0.08 then
            lastSpam = os.clock()
            local t = hum.Animator:LoadAnimation(AnimCache[sword])
            t.Priority = Enum.AnimationPriority.Action
            t:Play(0, 1, 2)
            task.delay(0.1, function() t:Stop(0) end)
        end
    end

    -- COMBAT ENGINE
    local remote = nil
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(s, k)
        if k == "FireServer" and tostring(s) == "Parry" then remote = s end
        return old(s, k)
    end)
    setreadonly(mt, true)

    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.X then autoParry = not autoParry
        elseif i.KeyCode == Enum.KeyCode.E then spamming = not spamming
        elseif i.KeyCode == Enum.KeyCode.V then autoSpam = not autoSpam
        elseif i.KeyCode == Enum.KeyCode.LeftControl then sg.Enabled = not sg.Enabled end
        info.Text = string.format("[X] Auto Parry: %s\n[E] Manual Spam: %s\n[V] Smart Spam: %s\n[CTRL] Hide Menu", 
            autoParry and "ON" or "OFF", spamming and "ON" or "OFF", autoSpam and "ON" or "OFF")
    end)

    RS.Heartbeat:Connect(function()
        local ball = nil
        for _, b in pairs(workspace.Balls:GetChildren()) do if b:GetAttribute("realBall") then ball = b break end end
        if not ball or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local dist = (LP.Character.HumanoidRootPart.Position - ball.Position).Magnitude
        local target = ball:GetAttribute("target") == LP.Name
        
        -- AUTO PARRY & SMART SPAM
        if target then
            if autoParry and dist < 15 then
                if remote then remote:FireServer() playAnim() end
            end
            if autoSpam and dist < 20 then
                if remote then remote:FireServer() playAnim() end
            end
        end
        
        -- MANUAL SPAM
        if spamming then
            if remote then remote:FireServer() playAnim() end
        end
    end)
end)

if not success then warn("SLY X ERROR: "..err) end
