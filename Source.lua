if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().Syntax = {
    Version = "1.3",
    Loaded = false
}

local function LoadModule(name)
    local url = "https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/src/" .. name .. ".lua"
    return loadstring(game:HttpGet(url))()
end

local Main = LoadModule("Main")
local UI = LoadModule("UI")
local Commands = LoadModule("Commands")

getgenv().Syntax = Main
Main:Init()
