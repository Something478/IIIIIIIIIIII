local UI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

UI.MainColor = Color3.fromRGB(25, 25, 35)
UI.AccentColor = Color3.fromRGB(0, 170, 255)
UI.TextColor = Color3.fromRGB(255, 255, 255)
UI.SecondaryColor = Color3.fromRGB(40, 40, 50)
UI.HoverColor = Color3.fromRGB(35, 35, 45)
UI.SuccessColor = Color3.fromRGB(85, 255, 85)
UI.ErrorColor = Color3.fromRGB(255, 80, 80)
UI.WarningColor = Color3.fromRGB(255, 200, 0)

UI.CommandHistory = {}
UI.CurrentHistoryIndex = 0
UI.CommandSuggestions = {
    "fly - Toggle flight mode",
    "unfly - Disable flight", 
    "noclip (nc) - Toggle noclip",
    "clip - Disable noclip",
    "godmode - Toggle invincibility",
    "speed [num] - Set walk speed",
    "jump [num] - Set jump power",
    "esp [player] - ESP player",
    "espall - ESP all players",
    "espnpc - ESP NPCs",
    "removeesp - Remove all ESP",
    "watch [player] - Spectate player",
    "unwatch - Stop spectating",
    "tp [player] - Teleport to player",
    "reset (re) - Reset character",
    "infinitejump (ij) - Toggle infinite jump",
    "antiafk (aafk) - Toggle anti-afk",
    "autoclick (ac) - Toggle auto-clicker",
    "time [num] - Set game time",
    "fov [num] - Set camera FOV",
    "xray - Toggle xray vision",
    "fullbright (fb) - Toggle fullbright",
    "flyspeed [num] - Set flight speed",
    "rejoin (rj) - Rejoin game",
    "rejoinrefresh (rjre) - Rejoin same position",
    "exit - Leave game",
    "serverhop (shop) - Hop to random server",
    "pingserverhop (pshop) - Hop to best ping server",
    "antifling (af) - Toggle anti-fling",
    "unantifling (uaf) - Disable anti-fling",
    "antikick (ak) - Toggle anti-kick",
    "commands (cmds) - Show commands list"
}

function UI:CreateMainWindow()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SyntaxCommands"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    self.MainButton = Instance.new("TextButton")
    self.MainButton.Size = UDim2.new(0, 50, 0, 50)
    self.MainButton.Position = UDim2.new(0.5, -25, 0, 20)
    self.MainButton.BackgroundColor3 = self.MainColor
    self.MainButton.Text = "𝐒𝐂"
    self.MainButton.TextColor3 = self.AccentColor
    self.MainButton.Font = Enum.Font.GothamBold
    self.MainButton.TextSize = 18
    self.MainButton.Parent = self.ScreenGui

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = self.MainButton

    local dragging = false
    local dragInput, dragStart, startPos

    self.MainButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainButton.Position
        end
    end)

    self.MainButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            self.MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.MainButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    self.MainButton.MouseEnter:Connect(function()
        self.MainButton.BackgroundColor3 = self.HoverColor
    end)

    self.MainButton.MouseLeave:Connect(function()
        self.MainButton.BackgroundColor3 = self.MainColor
    end)

    self.CommandBar = Instance.new("TextBox")
    self.CommandBar.Size = UDim2.new(0, 450, 0, 50)
    self.CommandBar.Position = UDim2.new(0.5, -225, 0, -70)
    self.CommandBar.PlaceholderText = "Enter command... (Press ↑↓ for history)"
    self.CommandBar.Text = ""
    self.CommandBar.ClearTextOnFocus = false
    self.CommandBar.TextColor3 = self.TextColor
    self.CommandBar.BackgroundColor3 = self.MainColor
    self.CommandBar.Font = Enum.Font.Gotham
    self.CommandBar.TextSize = 16
    self.CommandBar.Visible = false
    self.CommandBar.Parent = self.ScreenGui

    local commandCorner = Instance.new("UICorner")
    commandCorner.CornerRadius = UDim.new(0, 12)
    commandCorner.Parent = self.CommandBar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = self.CommandBar

    self.MainButton.MouseButton1Click:Connect(function()
        self:ToggleCommandBar()
    end)

    self.CommandBar.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = self.CommandBar.Text
            if command ~= "" then
                table.insert(self.CommandHistory, 1, command)
                if #self.CommandHistory > 50 then
                    table.remove(self.CommandHistory, 51)
                end
                self.CurrentHistoryIndex = 0
            end
            self:HideCommandBar()
        end
    end)

    self.CommandBar:GetPropertyChangedSignal("Text"):Connect(function()
        self.CommandBar.Text = self.CommandBar.Text:sub(1, 100)
        self:UpdateAutoComplete()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.CommandBar.Visible then
            if input.KeyCode == Enum.KeyCode.Escape then
                self:HideCommandBar()
            elseif input.KeyCode == Enum.KeyCode.Up then
                self:NavigateHistory(1)
            elseif input.KeyCode == Enum.KeyCode.Down then
                self:NavigateHistory(-1)
            end
        elseif input.KeyCode == Enum.KeyCode.Semicolon then
            self:ShowCommandBar()
        end
    end)

    self:CreateNotificationFrame()
    self:CreateAutoComplete()
end

function UI:UpdateAutoComplete()
    local searchText = self.CommandBar.Text:lower()
    if searchText == "" then
        self:HideAutoComplete()
        return
    end

    local matches = {}
    for _, suggestion in ipairs(self.CommandSuggestions) do
        if suggestion:lower():find(searchText, 1, true) then
            table.insert(matches, suggestion)
        end
    end

    self:ShowAutoComplete(matches)
end

function UI:NavigateHistory(direction)
    if #self.CommandHistory == 0 then return end
    
    self.CurrentHistoryIndex = math.clamp(self.CurrentHistoryIndex + direction, 0, #self.CommandHistory)
    
    if self.CurrentHistoryIndex == 0 then
        self.CommandBar.Text = ""
    else
        self.CommandBar.Text = self.CommandHistory[self.CurrentHistoryIndex]
        self.CommandBar.CursorPosition = #self.CommandBar.Text + 1
    end
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
    self.CommandBar.Position = UDim2.new(0.5, -225, 0, -70)
    self.CommandBar.Text = ""

    local slideIn = TweenService:Create(self.CommandBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -225, 0, 80)
    })
    slideIn:Play()

    slideIn.Completed:Connect(function()
        self.CommandBar:CaptureFocus()
    end)
end

function UI:HideCommandBar()
    local slideOut = TweenService:Create(self.CommandBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -225, 0, -70)
    })
    slideOut:Play()

    slideOut.Completed:Connect(function()
        self.CommandBar.Visible = false
        self.CommandBar.Text = ""
        self.CurrentHistoryIndex = 0
        self:HideAutoComplete()
    end)
end

function UI:CreateAutoComplete()
    self.AutoCompleteFrame = Instance.new("Frame")
    self.AutoCompleteFrame.Size = UDim2.new(0, 450, 0, 0)
    self.AutoCompleteFrame.Position = UDim2.new(0.5, -225, 0, 135)
    self.AutoCompleteFrame.BackgroundColor3 = self.SecondaryColor
    self.AutoCompleteFrame.BackgroundTransparency = 0.1
    self.AutoCompleteFrame.Visible = false
    self.AutoCompleteFrame.Parent = self.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.AutoCompleteFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = self.AccentColor
    stroke.Thickness = 1
    stroke.Parent = self.AutoCompleteFrame

    self.AutoCompleteList = Instance.new("UIListLayout")
    self.AutoCompleteList.Padding = UDim.new(0, 2)
    self.AutoCompleteList.Parent = self.AutoCompleteFrame
end

function UI:ShowAutoComplete(suggestions)
    if not suggestions or #suggestions == 0 then
        self:HideAutoComplete()
        return
    end

    for _, child in ipairs(self.AutoCompleteFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for i, suggestion in ipairs(suggestions) do
        if i > 3 then break end
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = self.SecondaryColor
        button.BackgroundTransparency = 0.1
        button.Text = suggestion
        button.TextColor3 = self.TextColor
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = self.AutoCompleteFrame

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = self.HoverColor
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = self.SecondaryColor
        end)

        button.MouseButton1Click:Connect(function()
            local command = suggestion:match("^([^%s]+)")
            self.CommandBar.Text = command or suggestion
            self.CommandBar:CaptureFocus()
        end)
    end

    self.AutoCompleteFrame.Size = UDim2.new(0, 450, 0, math.min(#suggestions, 3) * 37 - 2)
    self.AutoCompleteFrame.Visible = true
end

function UI:HideAutoComplete()
    self.AutoCompleteFrame.Visible = false
end

function UI:CreateNotificationFrame()
    self.NotifFrame = Instance.new("Frame")
    self.NotifFrame.Size = UDim2.new(0, 350, 0, 80)
    self.NotifFrame.Position = UDim2.new(1, 400, 1, -120)
    self.NotifFrame.BackgroundColor3 = self.MainColor
    self.NotifFrame.BackgroundTransparency = 0.1
    self.NotifFrame.Visible = false
    self.NotifFrame.Parent = self.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = self.NotifFrame

    self.NotifIcon = Instance.new("TextLabel")
    self.NotifIcon.Size = UDim2.new(0, 40, 0, 40)
    self.NotifIcon.Position = UDim2.new(0, 15, 0.5, -20)
    self.NotifIcon.BackgroundTransparency = 1
    self.NotifIcon.Text = "𝐒𝐂"
    self.NotifIcon.TextColor3 = self.AccentColor
    self.NotifIcon.Font = Enum.Font.GothamBold
    self.NotifIcon.TextSize = 18
    self.NotifIcon.Parent = self.NotifFrame

    self.NotifText = Instance.new("TextLabel")
    self.NotifText.Size = UDim2.new(1, -70, 1, -20)
    self.NotifText.Position = UDim2.new(0, 70, 0, 10)
    self.NotifText.BackgroundTransparency = 1
    self.NotifText.TextColor3 = self.TextColor
    self.NotifText.Font = Enum.Font.Gotham
    self.NotifText.TextSize = 14
    self.NotifText.TextWrapped = true
    self.NotifText.TextXAlignment = Enum.TextXAlignment.Left
    self.NotifText.Parent = self.NotifFrame

    local notifPadding = Instance.new("UIPadding")
    notifPadding.PaddingRight = UDim.new(0, 10)
    notifPadding.Parent = self.NotifText
end

function UI:Notify(message, type)
    self.NotifText.Text = message

    if type == "error" then
        self.NotifIcon.Text = "❌"
        self.NotifIcon.TextColor3 = self.ErrorColor
    elseif type == "success" then
        self.NotifIcon.Text = "✓"
        self.NotifIcon.TextColor3 = self.SuccessColor
    elseif type == "warning" then
        self.NotifIcon.Text = "⚠"
        self.NotifIcon.TextColor3 = self.WarningColor
    else
        self.NotifIcon.Text = "𝐒𝐂"
        self.NotifIcon.TextColor3 = self.AccentColor
    end

    self.NotifFrame.Visible = true

    self.NotifFrame.Position = UDim2.new(1, 400, 1, -120)
    local tweenIn = TweenService:Create(self.NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -370, 1, -120)
    })
    tweenIn:Play()

    task.delay(4, function()
        if self.NotifFrame.Visible then
            local tweenOut = TweenService:Create(self.NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 400, 1, -120)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                self.NotifFrame.Visible = false
            end)
        end
    end)
end

return UI