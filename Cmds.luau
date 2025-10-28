local Commands = {}
local Main = getgenv().Syntax

function Commands:RegisterAll()
    self.CommandList = {
        {
            Names = {"fly", "flight"},
            Function = function(args)
                if args[1] then
                    Main:SetFlySpeed(args[1])
                end
                Main:FlyToggle()
            end,
            Description = "Toggle flight with optional speed"
        },
        {
            Names = {"unfly", "ground"},
            Function = function(args)
                if Main.Flying then
                    Main:FlyToggle()
                end
            end,
            Description = "Disable flight"
        },
        {
            Names = {"walkspeed", "speed", "ws"},
            Function = function(args)
                Main:SetWalkSpeed(args[1])
            end,
            Description = "Set walk speed"
        },
        {
            Names = {"jumppower", "jp", "jump"},
            Function = function(args)
                Main:SetJumpPower(args[1])
            end,
            Description = "Set jump power"
        },
        {
            Names = {"noclip", "nc", "ghost"},
            Function = function(args)
                Main:NoClipToggle()
            end,
            Description = "Toggle noclip"
        },
        {
            Names = {"clip", "solid", "body"},
            Function = function(args)
                if Main.NoClip then
                    Main:NoClipToggle()
                end
            end,
            Description = "Disable noclip"
        },
        {
            Names = {"godmode", "god"},
            Function = function(args)
                Main:ToggleGodMode()
            end,
            Description = "Toggle god mode"
        },
        {
            Names = {"watch", "view", "spectate"},
            Function = function(args)
                Main:WatchPlayer(args[1])
            end,
            Description = "Spectate a player"
        },
        {
            Names = {"unwatch", "unview", "unspectate"},
            Function = function(args)
                Main:WatchPlayer()
            end,
            Description = "Stop spectating"
        },
        {
            Names = {"teleport", "goto", "to", "tp"},
            Function = function(args)
                Main:TeleportToPlayer(args[1])
            end,
            Description = "Teleport to player"
        },
        {
            Names = {"reset", "re", "refresh"},
            Function = function(args)
                Main:ResetCharacter()
            end,
            Description = "Reset your character"
        },
        {
            Names = {"commands", "cmds", "help"},
            Function = function(args)
                Main:ShowCommandsList()
            end,
            Description = "Show all available commands"
        },
        {
            Names = {"esp", "playeresp"},
            Function = function(args)
                if args[1] then
                    Main:ESPPlayer(args[1])
                else
                    Main:ESPAllPlayers()
                end
            end,
            Description = "ESP a specific player or all players"
        },
        {
            Names = {"npcESP", "espnpc", "npc"},
            Function = function(args)
                Main:ESPAllNPCs()
            end,
            Description = "ESP all NPCs"
        },
        {
            Names = {"unesp", "removeesp", "clearesp"},
            Function = function(args)
                Main:RemoveESP()
            end,
            Description = "Remove all ESP"
        },
        {
            Names = {"rejoin", "rj"},
            Function = function(args)
                Main:Rejoin()
            end,
            Description = "Rejoin the game"
        },
        {
            Names = {"rejoinrefresh", "rjre"},
            Function = function(args)
                Main:RejoinRefresh()
            end,
            Description = "Rejoin to same position"
        },
        {
            Names = {"exit", "leave"},
            Function = function(args)
                Main:ExitGame()
            end,
            Description = "Leave the game"
        },
        {
            Names = {"serverhop", "shop"},
            Function = function(args)
                Main:ServerHop()
            end,
            Description = "Hop to a random server"
        },
        {
            Names = {"pingserverhop", "pshop"},
            Function = function(args)
                Main:PingServerHop()
            end,
            Description = "Hop to best ping server"
        },
        {
            Names = {"antifling", "af"},
            Function = function(args)
                Main:ToggleAntiFling()
            end,
            Description = "Toggle anti-fling"
        },
        {
            Names = {"unantifling", "uaf"},
            Function = function(args)
                if Main.AntiFling then
                    Main:ToggleAntiFling()
                end
            end,
            Description = "Disable anti-fling"
        },
        {
            Names = {"antikick", "ak"},
            Function = function(args)
                Main:ToggleAntiKick()
            end,
            Description = "Toggle anti-kick"
        },
        {
            Names = {"fullbright", "fb"},
            Function = function(args)
                Main:ToggleFullbright()
            end,
            Description = "Toggle fullbright"
        },
        {
            Names = {"xray", "xrayvision"},
            Function = function(args)
                Main:ToggleXRay()
            end,
            Description = "Toggle xray vision"
        },
        {
            Names = {"infinitejump", "ij"},
            Function = function(args)
                Main:ToggleInfiniteJump()
            end,
            Description = "Toggle infinite jump"
        },
        {
            Names = {"antiafk", "aafk"},
            Function = function(args)
                Main:ToggleAntiAFK()
            end,
            Description = "Toggle anti-afk"
        },
        {
            Names = {"autoclick", "ac"},
            Function = function(args)
                Main:ToggleAutoClicker()
            end,
            Description = "Toggle auto-clicker"
        },
        {
            Names = {"time", "settime"},
            Function = function(args)
                Main:SetTime(args[1])
            end,
            Description = "Set game time"
        },
        {
            Names = {"fov", "setfov"},
            Function = function(args)
                Main:SetFOV(args[1])
            end,
            Description = "Set camera FOV"
        },
        {
            Names = {"flyspeed", "fs"},
            Function = function(args)
                Main:SetFlySpeed(args[1])
            end,
            Description = "Set flight speed"
        },
        {
            Names = {"prefix"},
            Function = function(args)
                if args[1] then
                    Main:SetPrefix(args[1])
                else
                    Main:Notify("Current prefix: " .. Main.CommandPrefix, "info")
                end
            end,
            Description = "Set or view command prefix"
        },
        {
            Names = {"togglechat", "chat"},
            Function = function(args)
                Main:ToggleChat()
            end,
            Description = "Toggle chat commands"
        }
    }
end

function Commands:Execute(commandName, args)
    for _, cmd in pairs(self.CommandList) do
        for _, name in pairs(cmd.Names) do
            if name:lower() == commandName:lower() then
                local success, errorMsg = pcall(function()
                    cmd.Function(args)
                end)
                if not success then
                    if Main.UI and Main.UI.Notify then
                        Main.UI:Notify("Error executing command: " .. errorMsg, "error")
                    else
                        warn("Error executing command: " .. errorMsg)
                    end
                end
                return
            end
        end
    end
    if Main.UI and Main.UI.Notify then
        Main.UI:Notify("Unknown command: " .. commandName, "error")
    else
        warn("Unknown command: " .. commandName)
    end
end

Commands:RegisterAll()

return Commands