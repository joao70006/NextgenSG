-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local AutomationController = _G.Require('Modules/Automation')
local MathController = _G.Require('Modules/Math')
local SettingsController = _G.Require('Settings/Controller')

-- Variables--
local KeyFunctions = {
    ['Q'] = function()
    end,

    ['Z'] = function()
        AutomationController.CopyPosition()
    end,

    ['X'] = function()
        AutomationController.CopyDirection()
    end,

    ['Two'] = function()
        if UserInputService:IsKeyDown("LeftControl") then
            loadstring(game:HttpGet('http://127.0.0.1:5500/Start.lua', true))()
        end
    end,

    ['Three'] = function()
        if UserInputService:IsKeyDown("LeftControl") then
            loadstring(game:HttpGet("https://gist.githubusercontent.com/oqzw/54be56c8e42cac45c29f260204416b84/raw/0b1706abd11b2eca86775a2d7a3d7d2fea470d8b/dex"))()
        end
    end
}

return KeyFunctions