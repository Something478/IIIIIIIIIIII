local UI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local IconManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/IconManager.lua"))()

UI.MainColor = Color3.fromRGB(25, 25, 35)
UI.AccentColor = Color3.fromRGB(0, 170, 255)
UI.TextColor = Color3.fromRGB(255, 255, 255)
UI.SecondaryColor = Color3.fromRGB(40, 40, 50)
UI.HoverColor = Color3.fromRGB(35, 35, 45)

function UI:CreateMainWindow()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SyntaxCommands"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    self.MainButton = Instance.new("ImageButton")
    self.MainButton.Size = UDim2.new(0, 60, 0, 60)
    self.MainButton.Position = UDim2.new(0.5, -30, 0, 20)
    self.MainButton.BackgroundColor3 = self.MainColor
    self.MainButton.Image = IconManager:GetImage("MainIcon")
    self.MainButton.ScaleType = Enum.ScaleType.Fit
    self.MainButton.Parent = self.ScreenGui

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = self.MainButton

    self.MainButton.MouseEnter:Connect(function()
        self.MainButton.BackgroundColor3 = self.HoverColor
    end)

    self.MainButton.MouseLeave:Connect(function()
        self.MainButton.BackgroundColor3 = self.MainColor
    end)

    self.CommandBar = Instance.new("TextBox")
    self.CommandBar.Size = UDim2.new(0, 400, 0, 45)
    self.CommandBar.Position = UDim2.new(0.5, -200, 0, -60)
    self.CommandBar.PlaceholderText = "Enter command..."
    self.CommandBar.Text = ""
    self.CommandBar.ClearTextOnFocus = false
    self.CommandBar.TextColor3 = self.TextColor
    self.CommandBar.BackgroundColor3 = self.MainColor
    self.CommandBar.Font = Enum.Font.FredokaOne
    self.CommandBar.TextSize = 16
    self.CommandBar.Visible = false
    self.CommandBar.Parent = self.ScreenGui

    local commandCorner = Instance.new("UICorner")
    commandCorner.CornerRadius = UDim.new(0, 10)
    commandCorner.Parent = self.CommandBar

    self.CommandBar.TextStrokeTransparency = 1

    self.MainButton.MouseButton1Click:Connect(function()
        self:ToggleCommandBar()
    end)

    self.CommandBar.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:HideCommandBar()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Escape and self.CommandBar.Visible then
            self:HideCommandBar()
        end
    end)

    self:CreateNotificationFrame()
end

function UI:ToggleCommandBar()
    if not self.CommandBar.Visible then
        self:ShowCommandBar()
    else
        self:HideCommandBar()
    end
end

function UI:ShowCommandBar()
    self.CommandBar.Visible = true
    self.CommandBar.Position = UDim2.new(0.5, -200, 0, -60)

    local slideIn = TweenService:Create(self.CommandBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0, 25)
    })
    slideIn:Play()

    slideIn.Completed:Connect(function()
        self.CommandBar:CaptureFocus()
    end)
end

function UI:HideCommandBar()
    local slideOut = TweenService:Create(self.CommandBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -200, 0, -60)
    })
    slideOut:Play()

    slideOut.Completed:Connect(function()
        self.CommandBar.Visible = false
        self.CommandBar.Text = ""
    end)
end

function UI:CreateNotificationFrame()
    self.NotifFrame = Instance.new("Frame")
    self.NotifFrame.Size = UDim2.new(0, 320, 0, 70)
    self.NotifFrame.Position = UDim2.new(1, 350, 1, -100)
    self.NotifFrame.BackgroundColor3 = self.MainColor
    self.NotifFrame.BackgroundTransparency = 0.1
    self.NotifFrame.Visible = false
    self.NotifFrame.Parent = self.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.NotifFrame

    self.NotifIcon = Instance.new("ImageLabel")
    self.NotifIcon.Size = UDim2.new(0, 35, 0, 35)
    self.NotifIcon.Position = UDim2.new(0, 15, 0.5, -17.5)
    self.NotifIcon.BackgroundTransparency = 1
    self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    self.NotifIcon.ScaleType = Enum.ScaleType.Fit
    self.NotifIcon.Parent = self.NotifFrame

    self.NotifText = Instance.new("TextLabel")
    self.NotifText.Size = UDim2.new(1, -65, 1, -20)
    self.NotifText.Position = UDim2.new(0, 65, 0, 10)
    self.NotifText.BackgroundTransparency = 1
    self.NotifText.TextColor3 = self.TextColor
    self.NotifText.Font = Enum.Font.FredokaOne
    self.NotifText.TextSize = 14
    self.NotifText.TextWrapped = true
    self.NotifText.TextXAlignment = Enum.TextXAlignment.Left
    self.NotifText.TextStrokeTransparency = 1
    self.NotifText.Parent = self.NotifFrame
end

function UI:Notify(message, type)
    self.NotifText.Text = message

    -- Set appropriate icon based on notification type
    if type == "error" then
        self.NotifIcon.Image = IconManager:GetImage("ErrorIcon")
    elseif type == "fly" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "walk" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "jump" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "noclip" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "watch" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "teleport" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "reset" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    elseif type == "esp" then
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    else
        self.NotifIcon.Image = IconManager:GetImage("MainIcon")
    end

    self.NotifFrame.Visible = true

    self.NotifFrame.Position = UDim2.new(1, 350, 1, -100)
    local tweenIn = TweenService:Create(self.NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -350, 1, -100)
    })
    tweenIn:Play()

    task.delay(3, function()
        if self.NotifFrame.Visible then
            local tweenOut = TweenService:Create(self.NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 350, 1, -100)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                self.NotifFrame.Visible = false
            end)
        end
    end)
end


function UI:ShowCommandsList()
    self:Notify("Use ;commands to see available commands", "info")
end

return UI