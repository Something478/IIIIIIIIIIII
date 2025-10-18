local IconManager = {}
IconManager.Loaded = false

function IconManager:Load()
    local success, data = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Something478/IIIIIIIIIIII/main/data/icons.json")
    end)

    if success then
        local jsonSuccess, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        
        if jsonSuccess then
            self.MainIcon = decoded.main
            self.ErrorIcon = decoded.error
            self.Loaded = true
        else
            self.MainIcon = "rbxassetid://0"
            self.ErrorIcon = "rbxassetid://0"
        end
    else
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