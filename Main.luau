local Main = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

Main.Flying = false
Main.NoClip = false
Main.GodMode = false
Main.AntiFling = false
Main.AntiKick = false
Main.Fullbright = false
Main.XRay = false
Main.InfiniteJump = false
Main.AntiAFK = false
Main.AutoClicker = false

Main.ChatEnabled = true
Main.CommandPrefix = "."
Main.ChatListener = nil

Main.BodyVelocity = nil
Main.BodyGyro = nil
Main.FlySpeed = 50
Main.WalkSpeed = 16
Main.JumpPower = 50

Main.ESPObjects = {}
Main.ESPEnabled = false

Main.Connections = {}

function Main:Init()
    if self.Loaded then return end
    
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    self:SetupChatListener()
    self:SetupCharacterHandling()
    self:CreateDefaultUI()
    
    if self.UI and self.UI.Notify then
        self.UI:Notify("Syntax Commands v" .. self.Version .. " loaded! Prefix: " .. self.CommandPrefix, "success")
    end
    
    print("[Syntax Commands] Loaded successfully! Prefix: " .. self.CommandPrefix)
    self.Loaded = true
end

function Main:SetupChatListener()
    if not Main.ChatEnabled then return end
    
    local function ConnectToChat()
        local success, channel = pcall(function()
            return TextChatService:WaitForChild("TextChannels").RBXGeneral
        end)
        
        if success and channel then
            if self.ChatListener then
                self.ChatListener:Disconnect()
            end
            
            self.ChatListener = channel.MessageReceived:Connect(function(message)
                local text = message.Text
                local player = message.TextSource
                
                if player == LocalPlayer then
                    self:ProcessChatCommand(text)
                end
            end)
            
            print("[Chat] Listener connected to RBXGeneral")
        else
            warn("[Chat] Failed to connect to chat channel, retrying...")
            task.wait(2)
            ConnectToChat()
        end
    end
    
    task.spawn(ConnectToChat)
end

function Main:ProcessChatCommand(text)
    if not text then return end
    
    if string.sub(text, 1, #self.CommandPrefix) == self.CommandPrefix then
        local commandText = string.sub(text, #self.CommandPrefix + 1)
        local args = {}
        
        for word in string.gmatch(commandText, "[^%s]+") do
            table.insert(args, word)
        end
        
        if #args > 0 then
            local commandName = args[1]
            table.remove(args, 1)
            
            if self.Commands then
                self.Commands:Execute(commandName, args)
            else
                self:Notify("Commands module not loaded", "error")
            end
        end
    end
end

function Main:SetPrefix(newPrefix)
    if newPrefix and newPrefix ~= "" then
        self.CommandPrefix = newPrefix
        self:Notify("Command prefix set to: " .. newPrefix, "success")
        print("[Prefix] Changed to: " .. newPrefix)
    end
end

function Main:ToggleChat()
    self.ChatEnabled = not self.ChatEnabled
    if self.ChatEnabled then
        self:SetupChatListener()
        self:Notify("Chat commands enabled", "success")
    else
        if self.ChatListener then
            self.ChatListener:Disconnect()
            self.ChatListener = nil
        end
        self:Notify("Chat commands disabled", "warning")
    end
end

function Main:Notify(message, type)
    if self.UI and self.UI.Notify then
        self.UI:Notify(message, type)
    else
        print("[Notify] " .. message)
    end
end

function Main:SetupCharacterHandling()
    local function setupCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            if self.Flying then
                self:FlyToggle()
            end
            if self.NoClip then
                self:NoClipToggle()
            end
        end)
    end
    
    setupCharacter(LocalPlayer.Character)
    LocalPlayer.CharacterAdded:Connect(setupCharacter)
end

function Main:CreateDefaultUI()
    if self.UI then return end
    
    local success, uiModule = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/UI.luau"))()
    end)
    
    if success and uiModule then
        self.UI = uiModule
        self.UI:CreateMainWindow()
    else
        warn("[UI] Failed to load UI module")
    end
end

function Main:FlyToggle()
    self.Flying = not self.Flying
    
    if self.Flying then
        self:StartFlying()
        self:Notify("Flight enabled", "success")
    else
        self:StopFlying()
        self:Notify("Flight disabled", "info")
    end
end

function Main:StartFlying()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    self.BodyVelocity = Instance.new("BodyVelocity")
    self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    self.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    self.BodyVelocity.Parent = humanoidRootPart
    
    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
    self.BodyGyro.P = 1000
    self.BodyGyro.D = 50
    self.BodyGyro.Parent = humanoidRootPart
    
    self.BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    self.BodyGyro.MaxTorque = Vector3.new(40000, 0, 40000)
    
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not self.Flying or not character or not humanoidRootPart then
            flyConnection:Disconnect()
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * self.FlySpeed
        end
        
        self.BodyVelocity.Velocity = moveDirection
        self.BodyGyro.CFrame = camera.CFrame
    end)
end

function Main:StopFlying()
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
        self.BodyVelocity = nil
    end
    if self.BodyGyro then
        self.BodyGyro:Destroy()
        self.BodyGyro = nil
    end
end

function Main:SetFlySpeed(speed)
    local num = tonumber(speed)
    if num and num > 0 then
        self.FlySpeed = num
        self:Notify("Fly speed set to: " .. num, "success")
    else
        self:Notify("Invalid fly speed", "error")
    end
end

function Main:SetWalkSpeed(speed)
    local num = tonumber(speed)
    if num and num > 0 then
        self.WalkSpeed = num
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = num
                self:Notify("Walk speed set to: " .. num, "success")
                return
            end
        end
        self:Notify("Walk speed saved: " .. num, "success")
    else
        self:Notify("Invalid walk speed", "error")
    end
end

function Main:SetJumpPower(power)
    local num = tonumber(power)
    if num and num > 0 then
        self.JumpPower = num
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = num
                self:Notify("Jump power set to: " .. num, "success")
                return
            end
        end
        self:Notify("Jump power saved: " .. num, "success")
    else
        self:Notify("Invalid jump power", "error")
    end
end

function Main:NoClipToggle()
    self.NoClip = not self.NoClip
    
    if self.NoClip then
        self:StartNoClip()
        self:Notify("Noclip enabled", "success")
    else
        self:StopNoClip()
        self:Notify("Noclip disabled", "info")
    end
end

function Main:StartNoClip()
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    self.NoClipConnection = RunService.Stepped:Connect(function()
        if not self.NoClip or not character then
            if self.NoClipConnection then
                self.NoClipConnection:Disconnect()
            end
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function Main:StopNoClip()
    if self.NoClipConnection then
        self.NoClipConnection:Disconnect()
        self.NoClipConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Main:ToggleGodMode()
    self.GodMode = not self.GodMode
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BreakJointsOnDeath = not self.GodMode
        end
    end
    self:Notify("God mode: " .. (self.GodMode and "ON" or "OFF"), self.GodMode and "success" or "info")
end

function Main:ResetCharacter()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
    self:Notify("Character reset", "info")
end

function Main:ShowCommandsList()
    if self.Commands and self.Commands.CommandList then
        local commandCount = #self.Commands.CommandList
        self:Notify("Loaded " .. commandCount .. " commands. Use .commands for details", "info")
        
        for _, cmd in pairs(self.Commands.CommandList) do
            local mainName = cmd.Names[1]
            local desc = cmd.Description or "No description"
            print(mainName .. " - " .. desc)
        end
    else
        self:Notify("Commands list not available", "error")
    end
end

function Main:Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    self:Notify("Rejoining game...", "info")
end

function Main:ExitGame()
    self:Notify("Exiting game...", "warning")
    task.wait(1)
    game:Shutdown()
end

function Main:ToggleAntiFling()
    self.AntiFling = not self.AntiFling
    self:Notify("Anti-fling: " .. (self.AntiFling and "ON" or "OFF"), self.AntiFling and "success" or "info")
end

function Main:ToggleAntiKick()
    self.AntiKick = not self.AntiKick
    self:Notify("Anti-kick: " .. (self.AntiKick and "ON" or "OFF"), self.AntiKick and "success" or "info")
end

function Main:ToggleFullbright()
    self.Fullbright = not self.Fullbright
    if self.Fullbright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = true
    end
    self:Notify("Fullbright: " .. (self.Fullbright and "ON" or "OFF"), self.Fullbright and "success" or "info")
end

function Main:ToggleXRay()
    self.XRay = not self.XRay
    self:Notify("XRay: " .. (self.XRay and "ON" or "OFF"), self.XRay and "success" or "info")
end

function Main:ToggleInfiniteJump()
    self.InfiniteJump = not self.InfiniteJump
    self:Notify("Infinite jump: " .. (self.InfiniteJump and "ON" or "OFF"), self.InfiniteJump and "success" or "info")
end

function Main:ToggleAntiAFK()
    self.AntiAFK = not self.AntiAFK
    self:Notify("Anti-AFK: " .. (self.AntiAFK and "ON" or "OFF"), self.AntiAFK and "success" or "info")
end

function Main:ToggleAutoClicker()
    self.AutoClicker = not self.AutoClicker
    self:Notify("Auto-clicker: " .. (self.AutoClicker and "ON" or "OFF"), self.AutoClicker and "success" or "info")
end

function Main:SetTime(time)
    local num = tonumber(time)
    if num then
        game:GetService("Lighting").ClockTime = num
        self:Notify("Time set to: " .. num, "success")
    else
        self:Notify("Invalid time", "error")
    end
end

function Main:SetFOV(fov)
    local num = tonumber(fov)
    if num and num > 0 then
        workspace.CurrentCamera.FieldOfView = num
        self:Notify("FOV set to: " .. num, "success")
    else
        self:Notify("Invalid FOV", "error")
    end
end

function Main:ESPPlayer(playerName)
    self:Notify("ESP Player: " .. (playerName or "all"), "info")
end

function Main:ESPAllPlayers()
    self:Notify("ESP All Players", "info")
end

function Main:ESPAllNPCs()
    self:Notify("ESP All NPCs", "info")
end

function Main:RemoveESP()
    self:Notify("ESP Removed", "info")
end

function Main:WatchPlayer(playerName)
    self:Notify("Watching: " .. (playerName or "none"), "info")
end

function Main:TeleportToPlayer(playerName)
    self:Notify("Teleporting to: " .. (playerName or "player"), "info")
end

function Main:ServerHop()
    self:Notify("Server hopping...", "info")
end

function Main:PingServerHop()
    self:Notify("Ping-based server hopping...", "info")
end

function Main:RejoinRefresh()
    self:Notify("Rejoin refresh...", "info")
end

return Main