local Main = {}
Main.Version = "1.0.0"
Main.Prefix = ";"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer

Main.Flying = false
Main.NoClip = false
Main.Spectating = nil
Main.FlyBV = nil
Main.FlyButton = nil
Main.ESPEnabled = false
Main.ESPHandles = {}
Main.NPCESPEnabled = false

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
    if self.FlyButton then
        self.FlyButton.Visible = false
    end
    
    self.UI:Notify("Syntax Commands v" .. self.Version .. " loaded! Use " .. self.Prefix .. "commands", "info")
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
            self:ExecuteCommand(self.UI.CommandBar.Text)
            self.UI.CommandBar.Text = ""
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

            self.FlyBV.Velocity = moveDir * 50
        end
    end)

    self.Connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        
        if self.Flying then
            task.wait(1)
            self:StartFlying()
        end
        
        if self.NoClip then
            self.UI:Notify("Noclip re-enabled after reset", "noclip")
        end
    end)

    self:SetupChatListener()
end

function Main:SetupChatListener()
    if TextChatService then
        local function onIncomingMessage(message)
            if message.TextSource then
                local text = message.Text
                if text:sub(1, 1) == self.Prefix then
                    self:ExecuteCommand(text)
                    return false
                end
            end
        end

        if TextChatService.OnIncomingMessage then
            self.Connections.chatMessage = TextChatService.OnIncomingMessage:Connect(onIncomingMessage)
        end
    end

    self.Connections.chatHook = LocalPlayer.Chatted:Connect(function(message)
        if message:sub(1, 1) == self.Prefix then
            self:ExecuteCommand(message)
        end
    end)

    self.Connections.playerChat = game:GetService("Players").PlayerChatted:Connect(function(chatType, player, message)
        if player == LocalPlayer and message:sub(1, 1) == self.Prefix then
            self:ExecuteCommand(message)
        end
    end)

    self.UI:Notify("Chat commands enabled! Use " .. self.Prefix .. " before commands", "info")
end

function Main:CreateMobileFlyToggle()
    if self.FlyButton then
        self.FlyButton:Destroy()
        self.FlyButton = nil
    end

    self.FlyButton = Instance.new("Frame")
    self.FlyButton.Size = UDim2.new(0, 80, 0, 80)
    self.FlyButton.Position = UDim2.new(0, 30, 0.5, -40)
    self.FlyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    self.FlyButton.BackgroundTransparency = 0.1
    self.FlyButton.Visible = false
    self.FlyButton.Parent = self.UI.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = self.FlyButton

    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(1, -10, 1, -10)
    flyBtn.Position = UDim2.new(0, 5, 0, 5)
    flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    flyBtn.Text = "FLY\nOFF"
    flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyBtn.Font = Enum.Font.GothamBlack
    flyBtn.TextSize = 16
    flyBtn.TextWrapped = true
    flyBtn.ZIndex = 100
    flyBtn.Parent = self.FlyButton

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = flyBtn

    flyBtn.MouseEnter:Connect(function()
        flyBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
    end)

    flyBtn.MouseLeave:Connect(function()
        if self.Flying then
            flyBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        else
            flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)

    local dragging = false
    local dragInput, dragStart, startPos

    self.FlyButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.FlyButton.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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

    flyBtn.MouseButton1Click:Connect(function()
        self:FlyToggle()
    end)

    self:CreateMobileFlyControls()
end

function Main:CreateMobileFlyControls()
    if self.MobileControlFrame then
        self.MobileControlFrame:Destroy()
        self.MobileControlFrame = nil
    end

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
        wBtn.TouchLongPress:Connect(function() self.MobileFlyControls.W = true end)
        wBtn.TouchEnded:Connect(function() self.MobileFlyControls.W = false end)

        local aBtn = self:CreateMobileButton("A", UDim2.new(0, 10, 0.5, -25), movementPad)
        aBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.A = true end)
        aBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.A = false end)
        aBtn.TouchLongPress:Connect(function() self.MobileFlyControls.A = true end)
        aBtn.TouchEnded:Connect(function() self.MobileFlyControls.A = false end)

        local sBtn = self:CreateMobileButton("S", UDim2.new(0.5, -25, 1, -60), movementPad)
        sBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.S = true end)
        sBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.S = false end)
        sBtn.TouchLongPress:Connect(function() self.MobileFlyControls.S = true end)
        sBtn.TouchEnded:Connect(function() self.MobileFlyControls.S = false end)

        local dBtn = self:CreateMobileButton("D", UDim2.new(1, -60, 0.5, -25), movementPad)
        dBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.D = true end)
        dBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.D = false end)
        dBtn.TouchLongPress:Connect(function() self.MobileFlyControls.D = true end)
        dBtn.TouchEnded:Connect(function() self.MobileFlyControls.D = false end)

        local verticalFrame = Instance.new("Frame")
        verticalFrame.Size = UDim2.new(0, 60, 0, 150)
        verticalFrame.Position = UDim2.new(1, -70, 0, 0)
        verticalFrame.BackgroundTransparency = 1
        verticalFrame.Parent = self.MobileControlFrame

        local spaceBtn = self:CreateMobileButton("↑", UDim2.new(0, 0, 0, 10), verticalFrame)
        spaceBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.Space = true end)
        spaceBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.Space = false end)
        spaceBtn.TouchLongPress:Connect(function() self.MobileFlyControls.Space = true end)
        spaceBtn.TouchEnded:Connect(function() self.MobileFlyControls.Space = false end)

        local shiftBtn = self:CreateMobileButton("↓", UDim2.new(0, 0, 1, -60), verticalFrame)
        shiftBtn.MouseButton1Down:Connect(function() self.MobileFlyControls.Shift = true end)
        shiftBtn.MouseButton1Up:Connect(function() self.MobileFlyControls.Shift = false end)
        shiftBtn.TouchLongPress:Connect(function() self.MobileFlyControls.Shift = true end)
        shiftBtn.TouchEnded:Connect(function() self.MobileFlyControls.Shift = false end)
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

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)

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
    end
end

function Main:StopFlying()
    if self.FlyBV then
        self.FlyBV:Destroy()
        self.FlyBV = nil
    end
end

function Main:FlyToggle()
    self.Flying = not self.Flying

    if self.Flying then
        if self.FlyButton then
            self.FlyButton.Visible = true
            local flyBtn = self.FlyButton:FindFirstChildOfClass("TextButton")
            if flyBtn then
                flyBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                flyBtn.Text = "FLY\nON"
            end
        end
        
        if self.MobileControlFrame then
            self.MobileControlFrame.Visible = true
        end
        
        self:StartFlying()
        self.UI:Notify("Flight enabled", "fly")
    else
        if self.MobileControlFrame then
            self.MobileControlFrame.Visible = false
        end
        
        if self.FlyButton then
            local flyBtn = self.FlyButton:FindFirstChildOfClass("TextButton")
            if flyBtn then
                flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                flyBtn.Text = "FLY\nOFF"
            end
        end
        
        self:StopFlying()
        
        for control, _ in pairs(self.MobileFlyControls) do
            self.MobileFlyControls[control] = false
        end
        
        self.UI:Notify("Flight disabled", "fly")
    end
end

function Main:ExecuteCommand(cmd)
    if cmd:sub(1, 1) == self.Prefix then
        cmd = cmd:sub(2)
    end

    local args = {}
    for arg in cmd:gmatch("%S+") do
        table.insert(args, arg:lower())
    end

    if #args == 0 then return end

    local commandName = args[1]
    table.remove(args, 1)

    self.Commands:Execute(commandName, args)
end

function Main:SetWalkSpeed(speed)
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = tonumber(speed) or 16
        self.UI:Notify("WalkSpeed: " .. humanoid.WalkSpeed, "walk")
    end
end

function Main:SetJumpPower(power)
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = tonumber(power) or 50
        self.UI:Notify("JumpPower: " .. humanoid.JumpPower, "jump")
    end
end

function Main:NoClipToggle()
    self.NoClip = not self.NoClip
    self.UI:Notify("Noclip " .. (self.NoClip and "enabled" or "disabled"), "noclip")
end

function Main:WatchPlayer(playerName)
    if playerName then
        local target = self:FindPlayer(playerName)
        if target then
            self.Spectating = target
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            self.UI:Notify("Watching: " .. target.Name, "watch")
        end
    else
        self.Spectating = nil
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        self.UI:Notify("Stopped watching", "watch")
    end
end

function Main:TeleportToPlayer(playerName)
    local target = self:FindPlayer(playerName)
    if target and target.Character and LocalPlayer.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(target.Character.PrimaryPart.CFrame + Vector3.new(0, 3, 0))
        self.UI:Notify("Teleported to: " .. target.Name, "teleport")
    end
end

function Main:ResetCharacter()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        self.UI:Notify("Character reset", "reset")
    end
end

function Main:ESPPlayer(playerName)
    local target = self:FindPlayer(playerName)
    if target then
        self:CreateESP(target.Character, target.Name)
        self.UI:Notify("ESP added for " .. target.Name, "esp")
    else
        self.UI:Notify("Player not found: " .. playerName, "error")
    end
end

function Main:ESPAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            self:CreateESP(player.Character, player.Name)
        end
    end
    self.ESPEnabled = true
    self.UI:Notify("ESP added for all players", "esp")
end

function Main:ESPAllNPCs()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            self:CreateESP(obj, "NPC: " .. obj.Name)
        end
    end
    self.NPCESPEnabled = true
    self.UI:Notify("ESP added for all NPCs", "esp")
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

    if target:IsA("Model") then
        local connection
        connection = target.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                task.wait(1) 
                highlight.Adornee = target
                if target:FindFirstChild("Head") then
                    billboard.Adornee = target.Head
                elseif target:FindFirstChild("HumanoidRootPart") then
                    billboard.Adornee = target.HumanoidRootPart
                end
            end
        end)
    end
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
    self.UI:Notify("All ESP removed", "esp")
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
            self.UI:Notify("Teleported!", "teleport")
        end
    end)
    
    tool.Parent = LocalPlayer.Backpack
    self.UI:Notify("Teleport tool added to backpack!", "teleport")
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