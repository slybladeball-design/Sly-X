-- SLY X UI LIBRARY V8 (FINAL & ROBUST)
local SlyUI = {
    Themes = {
        Default = {
            Main = Color3.fromRGB(0, 0, 0),
            Secondary = Color3.fromRGB(10, 10, 10),
            Accent = Color3.fromRGB(204, 0, 0),
            Text = Color3.fromRGB(255, 255, 255),
            Stroke = Color3.fromRGB(40, 40, 40)
        }
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

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
        end
    }
end

function SlyUI.new(config)
    local self = setmetatable({}, {__index = SlyUI})
    self.Name = config.Name or "SLY X"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)
    SlyUI.ProtectGui(ScreenGui)
    self.ScreenGui = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = SlyUI.Themes.Default.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -305, 0.5, -198)
    MainFrame.Size = config.Scale or UDim2.new(0, 611, 0, 396)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = SlyUI.Themes.Default.Accent
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = self.Name
    Title.TextColor3 = SlyUI.Themes.Default.Accent
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    function self:AddTab(tabConfig)
        local tab = {Sections = {}}
        function tab:AddSection(secConfig)
            local section = {}
            function section:AddToggle(togConfig)
                return {SetValue = function() end}
            end
            function section:AddSlider(slidConfig) return {} end
            function section:AddKeybind(keyConfig) return {} end
            return section
        end
        return tab
    end
    
    function self:AddLabel(text) end

    return self
end

return SlyUI
