local IconManager = {}
IconManager.Loaded = false

function IconManager:Load()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/data/icons.json"))
    end)
    
    if success then
        self.MainIcon = data.main
        self.ErrorIcon = data.error
        self.Loaded = true
    else
        warn("Syntax Commands: Failed to load icons.")
        self.MainIcon = "rbxassetid://0"
        self.ErrorIcon = "rbxassetid://0"
    end
end

function IconManager:GetIcon(iconType)
    if iconType == "error" then
        return self.ErrorIcon
    else
        return self.MainIcon
    end
end

return IconManager
