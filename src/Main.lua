local Main = {}
Main.Version = "1.2"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

Main.Flying = false
Main.NoClip = false
Main.Spectating = nil
Main.FlyBV = nil
Main.FlyButton = nil
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

Main.MobileFlyControls = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    Shift = false
}

Main.Connections = {}

function Main:Init()
    getgenv().Syntax = self
    self:LoadUI()
    self:LoadCommands()
    self:SetupConnections()
    self:CreateMobileFlyToggle()
    self:CreateQuickAccessPanel()
    self.UI:Notify("Syntax Commands " .. self.Version .. " Loaded!", "success")
end

function Main:LoadUI()
    self.UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/UI.lua"))()
    self.UI:CreateMainWindow()
end

function Main:LoadCommands()
    self.Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/Commands.lua"))()
    self.Commands:RegisterAll()
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
        if self.Flying and self.FlyBV then
            local cam = workspace.CurrentCamera
            self.FlyBV.Velocity = Vector3.new()

            if UserInputService:GetFocusedTextBox() then return end

            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or self.MobileFlyControls.W then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or self.MobileFlyControls.S then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or self.MobileFlyControls.D then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or self.MobileFlyControls.A then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or self.MobileFlyControls.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or self.MobileFlyControls.Shift then moveDir = moveDir - Vector3.new(0, 1, 0) end

            self.FlyBV.Velocity = moveDir * self.FlySpeed
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

    self.Connections.antiAFK = RunService.Heartbeat:Connect(function()
        if self.AntiAFK then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
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

    self.Connections.autoClick = RunService.Heartbeat:Connect(function()
        if self.AutoClicker then
            mouse1click()
        end
    end)
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
        button.Font = Enum.Font.FredokaOne
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

function Main:CreateMobileFlyToggle()
    if self.FlyButton then return end

    self.FlyButton = Instance.new("TextButton")
    self.FlyButton.Size = UDim2.new(0, 80, 0, 80)
    self.FlyButton.Position = UDim2.new(0, 30, 0.5, -40)
    self.FlyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    self.FlyButton.Text = "FLY\nOFF"
    self.FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.FlyButton.Font = Enum.Font.GothamBlack
    self.FlyButton.TextSize = 16
    self.FlyButton.TextWrapped = true
    self.FlyButton.ZIndex = 100
    self.FlyButton.Parent = self.UI.ScreenGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 16)
    btnCorner.Parent = self.FlyButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = self.FlyButton

    local dragging = false
    local dragInput, dragStart, startPos

    self.FlyButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.FlyButton.Position
        end
    end)

    self.FlyButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
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
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    self.FlyButton.MouseButton1Click:Connect(function()
        self:FlyToggle()
    end)

    self:CreateMobileFlyControls()
end

function Main:CreateMobileFlyControls()
    if self.MobileControlFrame then return end

    if UserInputService.TouchEnabled then
        self.MobileControlFrame = Instance.new("Frame")
        self.MobileControlFrame.Size = UDim2.new(0, 200, 0, 200)
        self.MobileControlFrame.Position = UDim2.new(1, -220, 1, -220)
        self.MobileControlFrame.BackgroundTransparency = 1
        self.MobileControlFrame.Visible = false
        self.MobileControlFrame.Parent = self.UI.ScreenGui

        local movementPad = Instance.new("Frame")
        movementPad.Size = UDim2.new(0, 150, 0, 150)
        movementPad.Position = UDim2.new(0, 0, 0, 0)
        movementPad.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        movementPad.BackgroundTransparency = 0.3
        movementPad.Parent = self.MobileControlFrame

        local padCorner = Instance.new("UICorner")
        padCorner.CornerRadius = UDim.new(0, 20)
        padCorner.Parent = movementPad

        local wBtn = self:CreateMobileButton("W", UDim2.new(0.5, -25, 0, 10), movementPad)
        wBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.W = true end)
        wBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.W = false end)

        local aBtn = self:CreateMobileButton("A", UDim2.new(0, 10, 0.5, -25), movementPad)
        aBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.A = true end)
        aBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.A = false end)

        local sBtn = self:CreateMobileButton("S", UDim2.new(0.5, -25, 1, -60), movementPad)
        sBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.S = true end)
        sBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.S = false end)

        local dBtn = self:CreateMobileButton("D", UDim2.new(1, -60, 0.5, -25), movementPad)
        dBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.D = true end)
        dBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.D = false end)

        local verticalFrame = Instance.new("Frame")
        verticalFrame.Size = UDim2.new(0, 60, 0, 150)
        verticalFrame.Position = UDim2.new(1, -70, 0, 0)
        verticalFrame.BackgroundTransparency = 1
        verticalFrame.Parent = self.MobileControlFrame

        local spaceBtn = self:CreateMobileButton("↑", UDim2.new(0, 0, 0, 10), verticalFrame)
        spaceBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.Space = true end)
        spaceBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.Space = false end)

        local shiftBtn = self:CreateMobileButton("↓", UDim2.new(0, 0, 1, -60), verticalFrame)
        shiftBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.Shift = true end)
        shiftBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.Shift = false end)
    end
end

function Main:CreateMobileButton(text, position, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    return button
end

function Main:StartFlying()
    if self.FlyBV then
        self.FlyBV:Destroy()
        self.FlyBV = nil
    end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        self.FlyBV = Instance.new("BodyVelocity")
        self.FlyBV.Velocity = Vector3.new(0, 0, 0)
        self.FlyBV.MaxForce = Vector3.new(0, 0, 0)
        self.FlyBV.Parent = character.HumanoidRootPart
        self.FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 1000
        bodyGyro.D = 50
        bodyGyro.Parent = character.HumanoidRootPart
        self.FlyGyro = bodyGyro
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

function Main:FlyToggle()
    self.Flying = not self.Flying

    if self.Flying then
        self.FlyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        self.FlyButton.Text = "FLY\nON"
        if self.MobileControlFrame then
            self.MobileControlFrame.Visible = true
        end
        self:StartFlying()
        self.UI:Notify("Flight Enabled", "success")
    else
        self.FlyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        self.FlyButton.Text = "FLY\nOFF"
        if self.MobileControlFrame then
            self.MobileControlFrame.Visible = false
        end
        self:StopFlying()
        for control, _ in pairs(self.MobileFlyControls) do
            self.MobileFlyControls[control] = false
        end
        self.UI:Notify("Flight Disabled", "info")
    end
end

function Main:ToggleGodMode(enable)
    self.GodMode = enable or not self.GodMode
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if self.GodMode then
                humanoid.Name = "GodModeHumanoid"
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
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        self.UI:Notify("Fullbright Enabled", "success")
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
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
    Lighting.ClockTime = tonumber(time) or 12
    self.UI:Notify("Time Set: " .. Lighting.ClockTime, "success")
end

function Main:SetFOV(fov)
    workspace.CurrentCamera.FieldOfView = tonumber(fov) or 70
    self.UI:Notify("FOV Set: " .. workspace.CurrentCamera.FieldOfView, "success")
end

function Main:ExecuteCommand(cmd)
    local args = {}
    for arg in cmd:gmatch("%S+") do
        table.insert(args, arg:lower())
    end

    if #args == 0 then return end

    local commandName = args[1]
    table.remove(args, 1)

    local success, result = pcall(function()
        return self.Commands:Execute(commandName, args)
    end)

    if not success then
        self.UI:Notify("Command Error", "error")
    end
end

function Main:SetWalkSpeed(speed)
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        self.Speed = tonumber(speed) or 16
        humanoid.WalkSpeed = self.Speed
        self.UI:Notify("Speed: " .. humanoid.WalkSpeed, "success")
    end
end

function Main:SetJumpPower(power)
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
        if target then
            self.Spectating = target
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            self.UI:Notify("Watching: " .. target.Name, "success")
        end
    else
        self.Spectating = nil
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        self.UI:Notify("Stopped Watching", "info")
    end
end

function Main:TeleportToPlayer(playerName)
    local target = self:FindPlayer(playerName)
    if target and target.Character and LocalPlayer.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(target.Character.PrimaryPart.CFrame + Vector3.new(0, 3, 0))
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
    if target then
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

function Main:GiveTPTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local existingTool = backpack:FindFirstChild("Teleport Tool")
        if existingTool then
            existingTool:Destroy()
        end
    end
    
    local tool = Instance.new("Tool")
    tool.Name = "Teleport Tool"
    tool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.BrickColor = BrickColor.new("Cyan")
    handle.Material = Enum.Material.Neon
    handle.Parent = tool
    
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(0, 255, 255)
    pointLight.Brightness = 2
    pointLight.Range = 10
    pointLight.Parent = handle
    
    tool.Activated:Connect(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetPos = handle.Position
            character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            self.UI:Notify("Teleported!", "success")
        end
    end)
    
    tool.Parent = LocalPlayer.Backpack
    self.UI:Notify("Teleport Tool Added", "success")
end

function Main:FindPlayer(name)
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
            return player
        end
    end
    return nil
end

Main:Init()
return Main