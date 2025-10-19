local Commands = {}
local Main = getgenv().Syntax

function Commands:RegisterAll()
    self.CommandList = {
        {
            Names = {"fly", "flight"},
            Function = function(args)
                Main:FlyToggle()
            end,
            Description = "Toggle flight mode"
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
                Main.UI:ShowCommandsList()
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
            Names = {"tptool", "teleporttool", "tpt"},
            Function = function(args)
                Main:GiveTPTool()
            end,
            Description = "Gives a teleport tool"
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
                    Main.UI:Notify("Error executing command: " .. errorMsg, "error")
                end
                return
            end
        end
    end
    Main.UI:Notify("Unknown command: " .. commandName, "error")
end

return Commands