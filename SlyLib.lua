-- SLY X PREMIUM UI LIBRARY (V8)
-- DESIGNED FOR SLY X ULTIMATE

local GameServices = {
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService")
}

local SlyUI = {
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

local Library = {}

function Library.new(options)
    local self = {
        Name = options.Name or "SLY X PREMIUM",
        Tabs = {},
        CurrentTab = nil
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GameServices.HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    pcall(function()
        if gethui then ScreenGui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = game:GetService("CoreGui")
        else ScreenGui.Parent = game:GetService("CoreGui") end
    end)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 580, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    MainFrame.BackgroundColor3 = SlyUI.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = SlyUI.Accent
    UIStroke.Thickness = 1.8
    UIStroke.Transparency = 0.2

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
    Title.Text = "  " .. self.Name
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.TextColor3 = SlyUI.Accent
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 140, 1, -60)
    TabContainer.Position = UDim2.new(0, 15, 0, 50)
    TabContainer.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 6)

    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -180, 1, -60)
    ContentContainer.Position = UDim2.new(0, 165, 0, 50)
    ContentContainer.BackgroundTransparency = 1

    function self:AddTab(name)
        local tab = {Name = name}
        
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.BackgroundColor3 = SlyUI.Secondary
        TabButton.Text = name
        TabButton.TextColor3 = SlyUI.Dim
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
        
        local TabStroke = Instance.new("UIStroke", TabButton)
        TabStroke.Color = SlyUI.Stroke
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.5

        local TabPage = Instance.new("ScrollingFrame", ContentContainer)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = SlyUI.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local ListLayout = Instance.new("UIListLayout", TabPage)
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        TabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Page.Visible = false
                SmoothTween(self.CurrentTab.Button, {0.2}, {TextColor3 = SlyUI.Dim, BackgroundColor3 = SlyUI.Secondary})
                SmoothTween(self.CurrentTab.Stroke, {0.2}, {Color = SlyUI.Stroke})
            end
            TabPage.Visible = true
            SmoothTween(TabButton, {0.2}, {TextColor3 = SlyUI.Accent, BackgroundColor3 = Color3.fromRGB(25, 12, 12)})
            SmoothTween(TabStroke, {0.2}, {Color = SlyUI.Accent})
            self.CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
        end)

        if not self.CurrentTab then
            TabPage.Visible = true
            TabButton.TextColor3 = SlyUI.Accent
            TabButton.BackgroundColor3 = Color3.fromRGB(25, 12, 12)
            TabStroke.Color = SlyUI.Accent
            self.CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
        end

        function tab:AddToggle(name, options)
            local callback = options.Callback or function() end
            local default = options.Default or false
            
            local ToggleFrame = Instance.new("Frame", TabPage)
            ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
            ToggleFrame.BackgroundColor3 = SlyUI.Secondary
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", ToggleFrame).Color = SlyUI.Stroke
            
            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.Text = "  " .. name
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = SlyUI.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Button = Instance.new("TextButton", ToggleFrame)
            Button.Size = UDim2.new(0, 44, 0, 22)
            Button.Position = UDim2.new(1, -54, 0.5, -11)
            Button.BackgroundColor3 = default and SlyUI.Accent or Color3.fromRGB(40, 40, 40)
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
                SmoothTween(Button, {0.2}, {BackgroundColor3 = state and SlyUI.Accent or Color3.fromRGB(40, 40, 40)})
                SmoothTween(Circle, {0.2}, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                callback(state)
            end

            Button.MouseButton1Click:Connect(function() toggle(not state) end)
            
            return {SetValue = function(_, v) toggle(v) end}
        end

        function tab:AddSlider(name, options)
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local callback = options.Callback or function() end
            
            local SliderFrame = Instance.new("Frame", TabPage)
            SliderFrame.Size = UDim2.new(1, -10, 0, 58)
            SliderFrame.BackgroundColor3 = SlyUI.Secondary
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", SliderFrame).Color = SlyUI.Stroke

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Text = "  " .. name .. ": " .. default
            Label.Size = UDim2.new(1, 0, 0, 32)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = SlyUI.Text
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
            Fill.BackgroundColor3 = SlyUI.Accent
            Instance.new("UICorner", Fill)

            local dragging = false
            local function update()
                local pos = math.clamp((GameServices.UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (max - min) * pos)
                Label.Text = "  " .. name .. ": " .. val
                callback(val)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            GameServices.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            GameServices.UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
            end)
            
            return {SetValue = function(_, v)
                local pos = math.clamp((v - min) / (max - min), 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Label.Text = "  " .. name .. ": " .. v
            end}
        end

        function tab:AddKeybind(name, options)
            local default = options.Default or Enum.KeyCode.E
            local callback = options.Callback or function() end
            
            local BindFrame = Instance.new("Frame", TabPage)
            BindFrame.Size = UDim2.new(1, -10, 0, 42)
            BindFrame.BackgroundColor3 = SlyUI.Secondary
            Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", BindFrame).Color = SlyUI.Stroke

            local Label = Instance.new("TextLabel", BindFrame)
            Label.Text = "  " .. name
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = SlyUI.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Button = Instance.new("TextButton", BindFrame)
            Button.Size = UDim2.new(0, 85, 0, 28)
            Button.Position = UDim2.new(1, -95, 0.5, -14)
            Button.BackgroundColor3 = SlyUI.Tertiary
            Button.Text = default.Name
            Button.TextColor3 = SlyUI.Accent
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 12
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Button).Color = SlyUI.Stroke

            Button.MouseButton1Click:Connect(function()
                Button.Text = "..."
                local connection
                connection = GameServices.UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Button.Text = input.KeyCode.Name
                        callback(input.KeyCode)
                        connection:Disconnect()
                    end
                end)
            end)
        end

        return tab
    end

    -- Toggle UI with Left Control
    GameServices.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    return self
end

return Library
