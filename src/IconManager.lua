local IconManager = {}
IconManager.Loaded = true

function IconManager:Load()
    self.MainIcon = "rbxassetid://81795192450289"
    self.ErrorIcon = "rbxassetid://135081399873960"
end

function IconManager:GetIcon(iconType)
    if iconType == "error" then
        return self.ErrorIcon
    else
        return self.MainIcon
    end
end

return IconManager