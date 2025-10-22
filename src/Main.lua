local Main = {}
Main.Version = "1.3"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

Main.Flying = false
Main.NoClip = false
Main.Spectating = nil
Main.FlyBV = nil
Main.FlyGyro = nil
Main.FlyButton = nil
Main.WASDFrame = nil
Main.ESPEnabled = false
Main.ESPHandles = {}
Main.NPCESPEnabled = false
Main.Waypoints = {}
Main.AntiAFK = false
Main.AutoClicker = false
Main.Speed = 16
Main.JumpPower = 50
Main.GodMode = false
Main.InfiniteJump = false
Main.XRay = false
Main.Fullbright = false
Main.FlySpeed = 50
Main.AntiFling = false
Main.AntiKick = false

Main.MobileFlyControls = {
    W = false,
    A = false,
    S = false,
    D = false
}

Main.Connections = {}

function Main:Init()
    getgenv().Syntax = self
    self:LoadUI()
    self:SetupConnections()
    self:CreateQuickAccessPanel()
    self:SetupAntiKick()
    self.UI:Notify("Syntax Commands " .. self.Version .. " Loaded!", "success")
end

function Main:LoadUI()
    self.UI = UI
    self.UI:CreateMainWindow()
end

function Main:SetupAntiKick()
    if self.AntiKick then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if self == LocalPlayer and method == "Kick" and self.AntiKick then
                self.UI:Notify("Blocked kick attempt!", "warning")
                return nil
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end
end

function Main:CreateFlyButton()
    if self.FlyButton then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.FlyButton = Instance.new("TextButton")
    self.FlyButton.TextWrapped = true
    self.FlyButton.BorderSizePixel = 0
    self.FlyButton.TextScaled = true
    self.FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.FlyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.FlyButton.Size = UDim2.new(0, 80, 0, 40)
    self.FlyButton.Text = "Fly"
    self.FlyButton.Position = UDim2.new(0.8, 0, 0.1, 0)
    self.FlyButton.Visible = false
    self.FlyButton.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = self.FlyButton

    local dragging = false
    local dragInput, dragStart, startPos

    self.FlyButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.FlyButton.Position
        end
    end)

    self.FlyButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            self.FlyButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.FlyButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    self.FlyButton.MouseButton1Click:Connect(function()
        self:FlyToggle()
    end)
end

function Main:CreateWASDController()
    if self.WASDFrame then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ControllerFrame = Instance.new("Frame")
    ControllerFrame.BorderSizePixel = 0
    ControllerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ControllerFrame.BackgroundTransparency = 0.3
    ControllerFrame.Size = UDim2.new(0, 150, 0, 150)
    ControllerFrame.Position = UDim2.new(0.1, 0, 0.6, 0)
    ControllerFrame.Visible = false
    ControllerFrame.Parent = ScreenGui

    self.WASDFrame = ControllerFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = ControllerFrame

    local BTN_S = Instance.new("TextButton")
    BTN_S.Size = UDim2.new(0, 40, 0, 40)
    BTN_S.Text = "S"
    BTN_S.Name = "BTN_S"
    BTN_S.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BTN_S.TextColor3 = Color3.fromRGB(255, 255, 255)
    BTN_S.Position = UDim2.new(0.5, -20, 0.7, -20)
    BTN_S.Parent = ControllerFrame

    local BTN_D = Instance.new("TextButton")
    BTN_D.Size = UDim2.new(0, 40, 0, 40)
    BTN_D.Text = "D"
    BTN_D.Name = "BTN_D"
    BTN_D.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BTN_D.TextColor3 = Color3.fromRGB(255, 255, 255)
    BTN_D.Position = UDim2.new(0.7, -20, 0.5, -20)
    BTN_D.Parent = ControllerFrame

    local BTN_A = Instance.new("TextButton")
    BTN_A.Size = UDim2.new(0, 40, 0, 40)
    BTN_A.Text = "A"
    BTN_A.Name = "BTN_A"
    BTN_A.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BTN_A.TextColor3 = Color3.fromRGB(255, 255, 255)
    BTN_A.Position = UDim2.new(0.3, -20, 0.5, -20)
    BTN_A.Parent = ControllerFrame

    local BTN_W = Instance.new("TextButton")
    BTN_W.Size = UDim2.new(0, 40, 0, 40)
    BTN_W.Text = "W"
    BTN_W.Name = "BTN_W"
    BTN_W.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BTN_W.TextColor3 = Color3.fromRGB(255, 255, 255)
    BTN_W.Position = UDim2.new(0.5, -20, 0.3, -20)
    BTN_W.Parent = ControllerFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = BTN_W
    buttonCorner:Clone().Parent = BTN_A
    buttonCorner:Clone().Parent = BTN_S
    buttonCorner:Clone().Parent = BTN_D

    local dragging = false
    local dragInput, dragStart, startPos

    ControllerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ControllerFrame.Position
        end
    end)

    ControllerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            ControllerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    ControllerFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    BTN_W.MouseButton1Down:Connect(function()
        self.MobileFlyControls.W = true
        BTN_W.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)

    BTN_W.MouseButton1Up:Connect(function()
        self.MobileFlyControls.W = false
        BTN_W.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)

    BTN_A.MouseButton1Down:Connect(function()
        self.MobileFlyControls.A = true
        BTN_A.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)

    BTN_A.MouseButton1Up:Connect(function()
        self.MobileFlyControls.A = false
        BTN_A.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)

    BTN_S.MouseButton1Down:Connect(function()
        self.MobileFlyControls.S = true
        BTN_S.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)

    BTN_S.MouseButton1Up:Connect(function()
        self.MobileFlyControls.S = false
        BTN_S.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)

    BTN_D.MouseButton1Down:Connect(function()
        self.MobileFlyControls.D = true
        BTN_D.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)

    BTN_D.MouseButton1Up:Connect(function()
        self.MobileFlyControls.D = false
        BTN_D.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
end

function Main:FlyToggle()
    self.Flying = not self.Flying

    if self.Flying then
        self:CreateFlyButton()
        self:CreateWASDController()
        
        self.FlyButton.Visible = true
        self.WASDFrame.Visible = true
        
        self.FlyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        self.FlyButton.Text = "Unfly"
        
        self:StartFlying()
        self.UI:Notify("Flight Enabled", "success")
    else
        self.FlyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        self.FlyButton.Text = "Fly"
        
        if self.FlyButton then
            self.FlyButton.Visible = false
        end
        if self.WASDFrame then
            self.WASDFrame.Visible = false
        end
        
        self:StopFlying()
        for control, _ in pairs(self.MobileFlyControls) do
            self.MobileFlyControls[control] = false
        end
        self.UI:Notify("Flight Disabled", "info")
    end
end

function Main:SetFlySpeed(speed)
    self.FlySpeed = tonumber(speed) or 50
    self.UI:Notify("Fly Speed: " .. self.FlySpeed, "success")
end

function Main:StartFlying()
    if self.FlyBV then
        self.FlyBV:Destroy()
        self.FlyBV = nil
    end
    if self.FlyGyro then
        self.FlyGyro:Destroy()
        self.FlyGyro = nil
    end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        self.FlyBV = Instance.new("BodyVelocity")
        self.FlyBV.Velocity = Vector3.new(0, 0, 0)
        self.FlyBV.MaxForce = Vector3.new(40000, 40000, 40000)
        self.FlyBV.P = 1250
        self.FlyBV.Parent = character.HumanoidRootPart
        
        self.FlyGyro = Instance.new("BodyGyro")
        self.FlyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        self.FlyGyro.P = 1000
        self.FlyGyro.D = 50
        self.FlyGyro.Parent = character.HumanoidRootPart
    end
end

function Main:StopFlying()
    if self.FlyBV then
        self.FlyBV:Destroy()
        self.FlyBV = nil
    end
    if self.FlyGyro then
        self.FlyGyro:Destroy()
        self.FlyGyro = nil
    end
end

function Main:CreateQuickAccessPanel()
    self.QuickAccess = Instance.new("Frame")
    self.QuickAccess.Size = UDim2.new(0, 300, 0, 200)
    self.QuickAccess.Position = UDim2.new(0, 20, 0.5, -100)
    self.QuickAccess.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    self.QuickAccess.BackgroundTransparency = 0.1
    self.QuickAccess.Visible = false
    self.QuickAccess.Parent = self.UI.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.QuickAccess

    local stroke = Instance.new("UIStroke")
    stroke.Color = self.UI.AccentColor
    stroke.Thickness = 2
    stroke.Parent = self.QuickAccess

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Quick Access"
    title.TextColor3 = self.UI.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = self.QuickAccess

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 1, -50)
    buttonContainer.Position = UDim2.new(0, 10, 0, 40)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = self.QuickAccess

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 85, 0, 30)
    grid.CellPadding = UDim2.new(0, 5, 0, 5)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.Parent = buttonContainer

    local quickButtons = {
        {"Fly", function() self:FlyToggle() end},
        {"Noclip", function() self:NoClipToggle() end},
        {"ESP All", function() self:ESPAllPlayers() end},
        {"God Mode", function() self:ToggleGodMode() end},
        {"Speed+", function() self:SetWalkSpeed(50) end},
        {"Reset", function() self:ResetCharacter() end},
        {"XRay", function() self:ToggleXRay() end},
        {"Fullbright", function() self:ToggleFullbright() end}
    }

    for i, buttonData in ipairs(quickButtons) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 85, 0, 30)
        button.BackgroundColor3 = self.UI.SecondaryColor
        button.Text = buttonData[1]
        button.TextColor3 = self.UI.TextColor
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = buttonContainer

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button

        button.MouseButton1Click:Connect(buttonData[2])
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = self.UI.HoverColor
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = self.UI.SecondaryColor
        end)
    end

    self.QuickAccessToggle = Instance.new("TextButton")
    self.QuickAccessToggle.Size = UDim2.new(0, 40, 0, 40)
    self.QuickAccessToggle.Position = UDim2.new(0, 20, 0, 80)
    self.QuickAccessToggle.BackgroundColor3 = self.UI.MainColor
    self.QuickAccessToggle.Text = "⚡"
    self.QuickAccessToggle.TextColor3 = self.UI.AccentColor
    self.QuickAccessToggle.Font = Enum.Font.GothamBlack
    self.QuickAccessToggle.TextSize = 18
    self.QuickAccessToggle.Parent = self.UI.ScreenGui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = self.QuickAccessToggle

    self.QuickAccessToggle.MouseButton1Click:Connect(function()
        self.QuickAccess.Visible = not self.QuickAccess.Visible
    end)
end

function Main:SetupConnections()
    self.Connections.commandBar = self.UI.CommandBar.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = self.UI.CommandBar.Text
            if command ~= "" then
                self:ExecuteCommand(command)
                self.UI.CommandBar.Text = ""
            end
        end
    end)

    self.Connections.stepped = RunService.Stepped:Connect(function()
        if self.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    self.Connections.heartbeat = RunService.Heartbeat:Connect(function()
        if self.Flying and self.FlyBV and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local cam = workspace.CurrentCamera
            self.FlyBV.Velocity = Vector3.new()

            if UserInputService:GetFocusedTextBox() then return end

            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or self.MobileFlyControls.W then 
                moveDir = moveDir + cam.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or self.MobileFlyControls.S then 
                moveDir = moveDir - cam.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or self.MobileFlyControls.D then 
                moveDir = moveDir + cam.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or self.MobileFlyControls.A then 
                moveDir = moveDir - cam.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                moveDir = moveDir + Vector3.new(0, 1, 0) 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                moveDir = moveDir - Vector3.new(0, 1, 0) 
            end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end

            self.FlyBV.Velocity = moveDir * self.FlySpeed
            
            if self.FlyGyro then
                self.FlyGyro.CFrame = cam.CFrame
            end
        end
    end)

    self.Connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        if self.Flying then
            task.wait(1)
            self:StartFlying()
        end
        if self.NoClip then
            self.UI:Notify("Noclip Re-enabled", "info")
        end
        if self.GodMode then
            self:ToggleGodMode(true)
        end
    end)

    self.Connections.jump = UserInputService.JumpRequest:Connect(function()
        if self.InfiniteJump and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function Main:ExecuteCommand(cmd)
    local args = {}
    for arg in cmd:gmatch("%S+") do
        table.insert(args, arg:lower())
    end

    if #args == 0 then return end

    local commandName = args[1]
    table.remove(args, 1)

    if commandName == "fly" then
        self:FlyToggle()
    elseif commandName == "unfly" then
        if self.Flying then
            self:FlyToggle()
        end
    elseif commandName == "flyspeed" then
        self:SetFlySpeed(args[1])
    elseif commandName == "noclip" or commandName == "nc" then
        self:NoClipToggle()
    elseif commandName == "clip" then
        self.NoClip = false
        self.UI:Notify("Noclip Disabled", "info")
    elseif commandName == "godmode" then
        self:ToggleGodMode()
    elseif commandName == "speed" then
        self:SetWalkSpeed(args[1])
    elseif commandName == "jump" then
        self:SetJumpPower(args[1])
    elseif commandName == "esp" then
        self:ESPPlayer(args[1])
    elseif commandName == "espall" then
        self:ESPAllPlayers()
    elseif commandName == "espnpc" then
        self:ESPAllNPCs()
    elseif commandName == "removeesp" then
        self:RemoveESP()
    elseif commandName == "watch" then
        self:WatchPlayer(args[1])
    elseif commandName == "unwatch" then
        self:WatchPlayer(nil)
    elseif commandName == "tp" then
        self:TeleportToPlayer(args[1])
    elseif commandName == "reset" or commandName == "re" then
        self:ResetCharacter()
    elseif commandName == "infinitejump" or commandName == "ij" then
        self:ToggleInfiniteJump()
    elseif commandName == "antiafk" or commandName == "aafk" then
        self:ToggleAntiAFK()
    elseif commandName == "autoclick" or commandName == "ac" then
        self:ToggleAutoClicker()
    elseif commandName == "time" then
        self:SetTime(args[1])
    elseif commandName == "fov" then
        self:SetFOV(args[1])
    elseif commandName == "xray" then
        self:ToggleXRay()
    elseif commandName == "fullbright" or commandName == "fb" then
        self:ToggleFullbright()
    elseif commandName == "rejoin" or commandName == "rj" then
        self:Rejoin()
    elseif commandName == "rejoinrefresh" or commandName == "rjre" then
        self:RejoinRefresh()
    elseif commandName == "exit" then
        self:ExitGame()
    elseif commandName == "serverhop" or commandName == "shop" then
        self:ServerHop()
    elseif commandName == "pingserverhop" or commandName == "pshop" then
        self:PingServerHop()
    elseif commandName == "antifling" or commandName == "af" then
        self:ToggleAntiFling()
    elseif commandName == "unantifling" or commandName == "uaf" then
        self.AntiFling = false
        self.UI:Notify("Anti-Fling Disabled", "info")
    elseif commandName == "antikick" or commandName == "ak" then
        self:ToggleAntiKick()
    elseif commandName == "commands" or commandName == "cmds" or commandName == "help" then
        self:ShowCommandsList()
    else
        self.UI:Notify("Unknown command: " .. commandName, "error")
    end
end

function Main:SetWalkSpeed(speed)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        self.Speed = tonumber(speed) or 16
        humanoid.WalkSpeed = self.Speed
        self.UI:Notify("Speed: " .. humanoid.WalkSpeed, "success")
    end
end

function Main:SetJumpPower(power)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        self.JumpPower = tonumber(power) or 50
        humanoid.JumpPower = self.JumpPower
        self.UI:Notify("Jump: " .. humanoid.JumpPower, "success")
    end
end

function Main:NoClipToggle()
    self.NoClip = not self.NoClip
    self.UI:Notify("Noclip " .. (self.NoClip and "Enabled" or "Disabled"), self.NoClip and "success" or "info")
end

function Main:WatchPlayer(playerName)
    if playerName then
        local target = self:FindPlayer(playerName)
        if target and target.Character then
            self.Spectating = target
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            self.UI:Notify("Watching: " .. target.Name, "success")
        end
    else
        self.Spectating = nil
        if LocalPlayer.Character then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
        self.UI:Notify("Stopped Watching", "info")
    end
end

function Main:TeleportToPlayer(playerName)
    local target = self:FindPlayer(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
        self.UI:Notify("Teleported To: " .. target.Name, "success")
    end
end

function Main:ResetCharacter()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        self.UI:Notify("Character Reset", "success")
    end
end

function Main:ESPPlayer(playerName)
    local target = self:FindPlayer(playerName)
    if target and target.Character then
        self:CreateESP(target.Character, target.Name)
        self.UI:Notify("ESP: " .. target.Name, "success")
    else
        self.UI:Notify("Player Not Found", "error")
    end
end

function Main:ESPAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:CreateESP(player.Character, player.Name)
        end
    end
    self.ESPEnabled = true
    self.UI:Notify("ESP All Players", "success")
end

function Main:ESPAllNPCs()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            self:CreateESP(obj, "NPC: " .. obj.Name)
        end
    end
    self.NPCESPEnabled = true
    self.UI:Notify("ESP All NPCs", "success")
end

function Main:CreateESP(target, name)
    if self.ESPHandles[target] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SyntaxESP"
    highlight.Adornee = target
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = target

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SyntaxESPLabel"
    billboard.Adornee = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    self.ESPHandles[target] = {highlight, billboard}
end

function Main:RemoveESP()
    for target, handles in pairs(self.ESPHandles) do
        for _, handle in ipairs(handles) do
            if handle then
                handle:Destroy()
            end
        end
    end
    self.ESPHandles = {}
    self.ESPEnabled = false
    self.NPCESPEnabled = false
    self.UI:Notify("ESP Removed", "success")
end

function Main:FindPlayer(name)
    if not name then return nil end
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name, 1, true) or player.DisplayName:lower():find(name, 1, true) then
            return player
        end
    end
    return nil
end

function Main:ToggleGodMode(enable)
    self.GodMode = enable or not self.GodMode
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if self.GodMode then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end
    
    self.UI:Notify("God Mode " .. (self.GodMode and "Enabled" or "Disabled"), self.GodMode and "success" or "info")
end

function Main:ToggleXRay()
    self.XRay = not self.XRay
    
    if self.XRay then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                part.LocalTransparencyModifier = 0.5
            end
        end
        self.UI:Notify("XRay Enabled", "success")
    else
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
        self.UI:Notify("XRay Disabled", "info")
    end
end

function Main:ToggleFullbright()
    self.Fullbright = not self.Fullbright
    
    if self.Fullbright then
        game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").GlobalShadows = false
        self.UI:Notify("Fullbright Enabled", "success")
    else
        game:GetService("Lighting").Ambient = Color3.new(0, 0, 0)
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
        self.UI:Notify("Fullbright Disabled", "info")
    end
end

function Main:ToggleInfiniteJump()
    self.InfiniteJump = not self.InfiniteJump
    self.UI:Notify("Infinite Jump " .. (self.InfiniteJump and "Enabled" or "Disabled"), self.InfiniteJump and "success" or "info")
end

function Main:ToggleAntiAFK()
    self.AntiAFK = not self.AntiAFK
    self.UI:Notify("Anti-AFK " .. (self.AntiAFK and "Enabled" or "Disabled"), self.AntiAFK and "success" or "info")
end

function Main:ToggleAutoClicker()
    self.AutoClicker = not self.AutoClicker
    self.UI:Notify("Auto-Clicker " .. (self.AutoClicker and "Enabled" or "Disabled"), self.AutoClicker and "success" or "info")
end

function Main:SetTime(time)
    game:GetService("Lighting").ClockTime = tonumber(time) or 12
    self.UI:Notify("Time Set: " .. game:GetService("Lighting").ClockTime, "success")
end

function Main:SetFOV(fov)
    workspace.CurrentCamera.FieldOfView = tonumber(fov) or 70
    self.UI:Notify("FOV Set: " .. workspace.CurrentCamera.FieldOfView, "success")
end

function Main:Rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

function Main:RejoinRefresh()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

function Main:ExitGame()
    game:Shutdown()
end

function Main:ServerHop()
    local gameId = tostring(game.PlaceId)
    local servers = {}
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, LocalPlayer)
        else
            self.UI:Notify("No servers found!", "error")
        end
    else
        self.UI:Notify("Failed to find servers", "error")
    end
end

function Main:PingServerHop()
    local gameId = tostring(game.PlaceId)
    local servers = {}
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            local bestServer = servers[1]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, LocalPlayer)
        else
            self.UI:Notify("No servers found!", "error")
        end
    else
        self.UI:Notify("Failed to find servers", "error")
    end
end

function Main:ToggleAntiFling()
    self.AntiFling = not self.AntiFling
    
    if self.AntiFling then
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                    part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                end
            end
        end
        self.UI:Notify("Anti-Fling Enabled", "success")
    else
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = false
                    part.CustomPhysicalProperties = nil
                end
            end
        end
        self.UI:Notify("Anti-Fling Disabled", "info")
    end
end

function Main:ToggleAntiKick()
    self.AntiKick = not self.AntiKick
    self:SetupAntiKick()
    self.UI:Notify("Anti-Kick " .. (self.AntiKick and "Enabled" or "Disabled"), self.AntiKick and "success" or "info")
end

function Main:ShowCommandsList()
    self.UI:Notify("Use ';' to open command bar and see suggestions", "info")
end

Main:Init()
return Main