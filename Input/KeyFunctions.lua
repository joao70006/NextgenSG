-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local Automations = _G.Require('Modules/Automations')

-- Variables--
local KeyFunctions = {
    ['Q'] = function()
        Automations.AlignAim(Vector3.new(-0.9963218569755554, -0, 0.07763054221868515))
        Automations.InsertPower(78)
    end,

    ['X'] = function()
        Automations.CopyDirection()
    end,

    ['Two'] = function()
        if UserInputService:IsKeyDown("LeftControl") then
            loadstring(game:HttpGet('http://127.0.0.1:5500/Start.lua', true))()
        end
    end
}

return KeyFunctions