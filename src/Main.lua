local Main = {}
Main.Version = "1.0.0"
Main.Prefix = ";"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

Main.Flying = false
Main.NoClip = false
Main.Spectating = nil
Main.FlyBV = nil

function Main:Init()
    self:LoadUI()
    self:LoadCommands()
    self:SetupConnections()
    self:CreateMobileFlyToggle()
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
    self.UI.CommandBar.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:ExecuteCommand(self.UI.CommandBar.Text)
            self.UI.CommandBar.Text = ""
        end
    end)

  
    RunService.Stepped:Connect(function()
        if self.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

  
    self.FlyConnection = RunService.Heartbeat:Connect(function()
        if self.Flying and self.FlyBV then
            local cam = workspace.CurrentCamera
            self.FlyBV.Velocity = Vector3.new()
            
            if UserInputService:GetFocusedTextBox() then return end
            
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            self.FlyBV.Velocity = moveDir * 50
        end
    end)
end

function Main:CreateMobileFlyToggle()
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(0, 70, 0, 70)
    flyButton.Position = UDim2.new(0, 50, 0, 200)
    flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    flyButton.Text = "FLY\nOFF"
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyButton.Font = Enum.Font.GothamBold
    flyButton.TextSize = 14
    flyButton.TextWrapped = true
    flyButton.ZIndex = 100
    flyButton.Parent = self.UI.ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = flyButton
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    flyButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = flyButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    flyButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            flyButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    flyButton.MouseButton1Click:Connect(function()
        self:FlyToggle()
        if self.Flying then
            flyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            flyButton.Text = "FLY\nON"
        else
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            flyButton.Text = "FLY\nOFF"
        end
    end)
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

function Main:FlyToggle()
    self.Flying = not self.Flying
    
    if self.Flying then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            self.FlyBV = Instance.new("BodyVelocity")
            self.FlyBV.Velocity = Vector3.new(0, 0, 0)
            self.FlyBV.MaxForce = Vector3.new(0, 0, 0)
            self.FlyBV.Parent = character.HumanoidRootPart
            self.FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        end
        self.UI:Notify("Flight enabled", "fly")
    else
        if self.FlyBV then
            self.FlyBV:Destroy()
            self.FlyBV = nil
        end
        self.UI:Notify("Flight disabled", "fly")
    end
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

function Main:FindPlayer(name)
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
            return player
        end
    end
    return nil
end

return Main
