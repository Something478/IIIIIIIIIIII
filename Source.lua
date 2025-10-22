if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().Syntax = {
    Version = "1.3",
    Loaded = false
}

local function LoadModule(name)
    local url = "https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/" .. name .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("Failed to load " .. name .. ": " .. result)
        return nil
    end
    
    return result
end

local UI = LoadModule("UI")
local Commands = LoadModule("Commands") 
local Main = LoadModule("Main")

if UI and Commands and Main then
    getgenv().Syntax = Main
    Main:Init()
    getgenv().Syntax.Loaded = true
else
    warn("Syntax Commands failed to load one or more modules!")
end