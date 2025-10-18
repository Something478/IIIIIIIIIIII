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
        }
    }
end

function Commands:Execute(commandName, args)
    for _, cmd in pairs(self.CommandList) do
        for _, name in pairs(cmd.Names) do
            if name == commandName then
                cmd.Function(args)
                return
            end
        end
    end
    Main.UI:Notify("Unknown command: " .. commandName, "error")
end

return Commands