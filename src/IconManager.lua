local IconManager = {}

IconManager.Images = {
    MainIcon = "data:image/png;base64,YOUR_ACTUAL_GIANT_MAIN_ICON_STRING",
    ErrorIcon = "data:image/png;base64,YOUR_ACTUAL_GIANT_ERROR_ICON_STRING"
}

function IconManager:GetImage(imageName)
    return self.Images[imageName]
end

return IconManager