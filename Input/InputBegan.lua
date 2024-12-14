-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local KeyFunctions = _G.Modules.KeyFunctions

-- Functions
if _G.Loaded then
    _G.InputConnection:Disconnect()
end

_G.InputConnection = UserInputService.InputBegan:Connect(function(Key, IsProcessed)
    if IsProcessed then
        return
    end

    Key = Key.KeyCode.Name:lower() ~= 'unknown' and Key.KeyCode.Name or Key.UserInputType.Name

    if KeyFunctions[Key] then
        KeyFunctions[Key]()
    end
end)