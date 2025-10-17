local UI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

UI.MainColor = Color3.fromRGB(30, 30, 40)
UI.AccentColor = Color3.fromRGB(0, 170, 255)
UI.TextColor = Color3.fromRGB(255, 255, 255)

local IconManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/IconManager.lua"))()
IconManager:Load()

function UI:CreateMainWindow()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SyntaxCommands"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.CommandBar = Instance.new("TextBox")
    self.CommandBar.Size = UDim2.new(0, 400, 0, 40)
    self.CommandBar.Position = UDim2.new(0.5, -200, 0, 20)
    self.CommandBar.PlaceholderText = "Enter command... (prefix: ;)"
    self.CommandBar.Text = ""
    self.CommandBar.ClearTextOnFocus = false
    self.CommandBar.TextColor3 = self.TextColor
    self.CommandBar.BackgroundColor3 = self.MainColor
    self.CommandBar.Font = Enum.Font.Gotham
    self.CommandBar.TextSize = 16
    self.CommandBar.Parent = self.ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.CommandBar
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.AccentColor
    UIStroke.Thickness = 2
    UIStroke.Parent = self.CommandBar
    
    self:CreateNotificationFrame()
end

function UI:CreateNotificationFrame()
    self.NotifFrame = Instance.new("Frame")
    self.NotifFrame.Size = UDim2.new(0, 300, 0, 60)
    self.NotifFrame.Position = UDim2.new(0.5, -150, 0, 80)
    self.NotifFrame.BackgroundColor3 = self.MainColor
    self.NotifFrame.BackgroundTransparency = 0.1
    self.NotifFrame.Visible = false
    self.NotifFrame.Parent = self.ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.NotifFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.AccentColor
    UIStroke.Thickness = 1
    UIStroke.Parent = self.NotifFrame
    
    self.NotifIcon = Instance.new("ImageLabel")
    self.NotifIcon.Size = UDim2.new(0, 30, 0, 30)
    self.NotifIcon.Position = UDim2.new(0, 15, 0.5, -15)
    self.NotifIcon.BackgroundTransparency = 1
    self.NotifIcon.Image = IconManager:GetIcon("main")
    self.NotifIcon.Parent = self.NotifFrame
    
    self.NotifText = Instance.new("TextLabel")
    self.NotifText.Size = UDim2.new(1, -60, 1, -20)
    self.NotifText.Position = UDim2.new(0, 60, 0, 10)
    self.NotifText.BackgroundTransparency = 1
    self.NotifText.TextColor3 = self.TextColor
    self.NotifText.Font = Enum.Font.Gotham
    self.NotifText.TextSize = 14
    self.NotifText.TextWrapped = true
    self.NotifText.TextXAlignment = Enum.TextXAlignment.Left
    self.NotifText.Parent = self.NotifFrame
end

function UI:Notify(message, type)
    self.NotifText.Text = message
    
    if type == "error" then
        self.NotifIcon.Image = IconManager:GetIcon("error")
    else
        self.NotifIcon.Image = IconManager:GetIcon("main")
    end
    
    self.NotifFrame.Visible = true
    
    self.NotifFrame.Position = UDim2.new(0.5, -150, 0, 60)
    local tweenIn = TweenService:Create(self.NotifFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -150, 0, 80)
    })
    tweenIn:Play()
    
    task.delay(3, function()
        if self.NotifFrame.Visible then
            local tweenOut = TweenService:Create(self.NotifFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -150, 0, 60)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                self.NotifFrame.Visible = false
            end)
        end
    end)
end

return UI
