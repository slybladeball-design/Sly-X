-- SLY X UI LIBRARY V8 (FINAL & ROBUST)
-- VERSION COMPLÈTE ET FONCTIONNELLE POUR GITHUB

local SlyUI = {
    Themes = {
        Default = {
            Main = Color3.fromRGB(5, 5, 5),
            Secondary = Color3.fromRGB(15, 15, 15),
            Accent = Color3.fromRGB(204, 0, 0),
            Text = Color3.fromRGB(255, 255, 255),
            Dim = Color3.fromRGB(140, 140, 140),
            Stroke = Color3.fromRGB(40, 40, 40)
        }
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local function SmoothTween(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    tween:Play()
    return tween
end

function SlyUI.ProtectGui(gui)
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
        gui.Parent = CoreGui
    end)
end

function SlyUI:CreateNotifier()
    return {
        new = function(_, title, text, time)
            print("[" .. title .. "]: " .. text)
            -- Possibilité d'ajouter une notification visuelle ici plus tard
        end
    }
end

function SlyUI.new(config)
    local self = setmetatable({}, {__index = SlyUI})
    self.Name = config.Name or "SLY X"
    self.Accent = SlyUI.Themes.Default.Accent
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(false)
    SlyUI.ProtectGui(ScreenGui)
    self.ScreenGui = ScreenGui

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = config.Scale or UDim2.new(0, 580, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    MainFrame.BackgroundColor3 = SlyUI.Themes.Default.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)
    
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = self.Accent
    UIStroke.Thickness = 1.8
    UIStroke.Transparency = 0.2

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Active = true

    -- Système de Dragging
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
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Text = "  " .. self.Name
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.TextColor3 = self.Accent
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 140, 1, -60)
    TabContainer.Position = UDim2.new(0, 15, 0, 50)
    TabContainer.BackgroundTransparency = 1

    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -180, 1, -60)
    ContentContainer.Position = UDim2.new(0, 165, 0, 50)
    ContentContainer.BackgroundTransparency = 1

    self.Tabs = {}
    self.CurrentTab = nil

    function self:AddTab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Name or tabConfig
        local tab = {Sections = {}}
        
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.Position = UDim2.new(0, 0, 0, #self.Tabs * 44)
        TabButton.BackgroundColor3 = SlyUI.Themes.Default.Secondary
        TabButton.Text = tabName
        TabButton.TextColor3 = SlyUI.Themes.Default.Dim
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
        
        local TabStroke = Instance.new("UIStroke", TabButton)
        TabStroke.Color = SlyUI.Themes.Default.Stroke
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.5

        local TabPage = Instance.new("ScrollingFrame", ContentContainer)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = self.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local ListLayout = Instance.new("UIListLayout", TabPage)
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        TabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Page.Visible = false
                SmoothTween(self.CurrentTab.Button, {0.2}, {TextColor3 = SlyUI.Themes.Default.Dim, BackgroundColor3 = SlyUI.Themes.Default.Secondary})
                SmoothTween(self.CurrentTab.Stroke, {0.2}, {Color = SlyUI.Themes.Default.Stroke})
            end
            TabPage.Visible = true
            SmoothTween(TabButton, {0.2}, {TextColor3 = self.Accent, BackgroundColor3 = Color3.fromRGB(20, 10, 10)})
            SmoothTween(TabStroke, {0.2}, {Color = self.Accent})
            self.CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
        end)

        if #self.Tabs == 0 then
            TabPage.Visible = true
            TabButton.TextColor3 = self.Accent
            TabButton.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
            TabStroke.Color = self.Accent
            self.CurrentTab = {Page = TabPage, Button = TabButton, Stroke = TabStroke}
        end

        table.insert(self.Tabs, {Page = TabPage, Button = TabButton})

        -- Compatibilité avec AddSection (V8) ou ajout direct (V5)
        function tab:AddSection(secConfig)
            local section = {}
            
            function section:AddToggle(togConfig)
                local name = typeof(togConfig) == "table" and togConfig.Name or togConfig
                local default = typeof(togConfig) == "table" and togConfig.Default or false
                local callback = typeof(togConfig) == "table" and togConfig.Callback or function() end
                
                local ToggleFrame = Instance.new("Frame", TabPage)
                ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
                ToggleFrame.BackgroundColor3 = SlyUI.Themes.Default.Secondary
                Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", ToggleFrame).Color = SlyUI.Themes.Default.Stroke
                
                local Label = Instance.new("TextLabel", ToggleFrame)
                Label.Text = "  " .. name
                Label.Size = UDim2.new(1, -60, 1, 0)
                Label.BackgroundTransparency = 1
                Label.TextColor3 = SlyUI.Themes.Default.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Button = Instance.new("TextButton", ToggleFrame)
                Button.Size = UDim2.new(0, 44, 0, 22)
                Button.Position = UDim2.new(1, -54, 0.5, -11)
                Button.BackgroundColor3 = default and SlyUI.Themes.Default.Accent or Color3.fromRGB(40, 40, 40)
                Button.Text = ""
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 11)

                local Circle = Instance.new("Frame", Button)
                Circle.Size = UDim2.new(0, 18, 0, 18)
                Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                local state = default
                Button.MouseButton1Click:Connect(function()
                    state = not state
                    SmoothTween(Button, {0.2}, {BackgroundColor3 = state and SlyUI.Themes.Default.Accent or Color3.fromRGB(40, 40, 40)})
                    SmoothTween(Circle, {0.2}, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                    callback(state)
                end)
                
                return {SetValue = function(_, v) 
                    state = v
                    SmoothTween(Button, {0.2}, {BackgroundColor3 = state and SlyUI.Themes.Default.Accent or Color3.fromRGB(40, 40, 40)})
                    SmoothTween(Circle, {0.2}, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
                    callback(state)
                end}
            end

            function section:AddSlider(slidConfig)
                local name = typeof(slidConfig) == "table" and slidConfig.Name or slidConfig
                local min = typeof(slidConfig) == "table" and slidConfig.Min or 0
                local max = typeof(slidConfig) == "table" and slidConfig.Max or 100
                local default = typeof(slidConfig) == "table" and slidConfig.Default or min
                local callback = typeof(slidConfig) == "table" and slidConfig.Callback or function() end

                local SliderFrame = Instance.new("Frame", TabPage)
                SliderFrame.Size = UDim2.new(1, -10, 0, 55)
                SliderFrame.BackgroundColor3 = SlyUI.Themes.Default.Secondary
                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", SliderFrame).Color = SlyUI.Themes.Default.Stroke

                local Label = Instance.new("TextLabel", SliderFrame)
                Label.Text = "  " .. name .. ": " .. default
                Label.Size = UDim2.new(1, 0, 0, 30)
                Label.BackgroundTransparency = 1
                Label.TextColor3 = SlyUI.Themes.Default.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Bar = Instance.new("Frame", SliderFrame)
                Bar.Size = UDim2.new(1, -30, 0, 6)
                Bar.Position = UDim2.new(0, 15, 0, 38)
                Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Instance.new("UICorner", Bar)

                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = SlyUI.Themes.Default.Accent
                Instance.new("UICorner", Fill)

                local dragging = false
                local function update()
                    local pos = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    Label.Text = "  " .. name .. ": " .. val
                    callback(val)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
                end)
                
                return {SetValue = function(_, v)
                    local pos = math.clamp((v - min) / (max - min), 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Label.Text = "  " .. name .. ": " .. v
                end}
            end

            function section:AddKeybind(keyConfig)
                local name = typeof(keyConfig) == "table" and keyConfig.Name or keyConfig
                local default = typeof(keyConfig) == "table" and keyConfig.Default or Enum.KeyCode.F
                local callback = typeof(keyConfig) == "table" and keyConfig.Callback or function() end

                local BindFrame = Instance.new("Frame", TabPage)
                BindFrame.Size = UDim2.new(1, -10, 0, 40)
                BindFrame.BackgroundColor3 = SlyUI.Themes.Default.Secondary
                Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 8)
                Instance.new("UIStroke", BindFrame).Color = SlyUI.Themes.Default.Stroke

                local Label = Instance.new("TextLabel", BindFrame)
                Label.Text = "  " .. name
                Label.Size = UDim2.new(1, -100, 1, 0)
                Label.BackgroundTransparency = 1
                Label.TextColor3 = SlyUI.Themes.Default.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Button = Instance.new("TextButton", BindFrame)
                Button.Size = UDim2.new(0, 80, 0, 26)
                Button.Position = UDim2.new(1, -90, 0.5, -13)
                Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                Button.Text = default.Name
                Button.TextColor3 = SlyUI.Themes.Default.Accent
                Button.Font = Enum.Font.GothamBold
                Button.TextSize = 12
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", Button).Color = SlyUI.Themes.Default.Stroke

                Button.MouseButton1Click:Connect(function()
                    Button.Text = "..."
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Button.Text = input.KeyCode.Name
                            callback(input.KeyCode)
                            connection:Disconnect()
                        end
                    end)
                end)
            end

            return section
        end

        -- Compatibilité avec les méthodes directes de la V5
        function tab:AddToggle(name, default, callback) return tab:AddSection():AddToggle({Name = name, Default = default, Callback = callback}) end
        function tab:AddSlider(name, min, max, default, callback) return tab:AddSection():AddSlider({Name = name, Min = min, Max = max, Default = default, Callback = callback}) end
        function tab:AddKeybind(name, default, callback) return tab:AddSection():AddKeybind({Name = name, Default = default, Callback = callback}) end

        return tab
    end
    
    function self:AddLabel(text)
        -- Implémentation simple d'un label
        local LabelFrame = Instance.new("Frame", self.CurrentTab.Page)
        LabelFrame.Size = UDim2.new(1, -10, 0, 30)
        LabelFrame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel", LabelFrame)
        Label.Text = text
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = SlyUI.Themes.Default.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Center
    end

    return self
end

return SlyUI
