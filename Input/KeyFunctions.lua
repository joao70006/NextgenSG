-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules

-- Variables--
local KeyFunctions = {
    ['Z'] = function()
        local AutomationController = _G.Modules.Automation

        AutomationController.FetchPosition(true)
    end,

    ['F'] = function()
        local DrawingController = _G.Modules.Drawing
        local AutomationController = _G.Modules.Automation
        local NearestCheckpoint = AutomationController.FetchNearestCheckpoint()

        DrawingController.DrawCheckpoints(3)
        DrawingController.DrawLocalLineOfSight(NearestCheckpoint, 3)
    end,

    ['X'] = function()
        local AutomationController = _G.Modules.Automation
        local DrawingController = _G.Modules.Drawing
        local SettingsController = _G.Modules.Settings
        local NearestCheckpoint = AutomationController.FetchNearestCheckpoint(true)

        if not NearestCheckpoint then
            return
        end

        -- Patch Position
        NearestCheckpoint.Direction = AutomationController.FetchDirection()
        NearestCheckpoint.Position = AutomationController.FetchPosition()

        -- Execute Checkpoint
        AutomationController.InsertPower(NearestCheckpoint.Power)
        AutomationController.LastUsedCheckpoint = NearestCheckpoint

        -- Draw
        local Index = SettingsController.FetchIndexOfCheckpoint(NearestCheckpoint)
        DrawingController.DrawCheckpoint(Index, NearestCheckpoint, 10, {Color = Color3.new(1, 0, 0)})
    end,

    ['Q'] = function()
        local AutomationController = _G.Modules.Automation
        local GameController = _G.Modules.Game
        local MathController = _G.Modules.Math
        
        local AimDirection, Power
        local NearestCheckpoint = AutomationController.FetchNearestCheckpoint()

        if not NearestCheckpoint then
            return
        end

        -- Patch Position
        NearestCheckpoint.Position = AutomationController.FetchPosition()

        -- Execute Checkpoint
        if NearestCheckpoint.AutoHole or NearestCheckpoint.AimToHole then
            local HolePosition = GameController.FetchHolePosition()  
            local LocalBallPosition = GameController.FetchLocalBall():GetPivot().Position
            local Distance = (LocalBallPosition * Vector3.new(1, 0, 1) - HolePosition * Vector3.new(1, 0, 1)).Magnitude
            
            AimDirection = CFrame.lookAt(LocalBallPosition, HolePosition).LookVector * Vector3.new(1, 0, 1)
            
            if NearestCheckpoint.AutoHole then
                Power = MathController.CalculatePower(Distance)
            elseif not NearestCheckpoint.AutoHole then
                Power = NearestCheckpoint.Power
            end
        elseif not NearestCheckpoint.AutoHole then
            AimDirection = NearestCheckpoint.Direction
            Power = NearestCheckpoint.Power
        end

        if NearestCheckpoint.PowerFunction then
            local Map = GameController.FetchMap()
            local Hole = GameController.FetchHole()
            local PowerFunctions = loadstring(game:HttpGet('http://127.0.0.1:5500/Settings/PowerFunctions.lua', true))()
            local PowerFunction = PowerFunctions[`{Map}{Hole}`]
            local LocalBall = GameController.FetchLocalBall()
            local HolePosition = GameController.FetchHolePosition()
            local Distance = (LocalBall:GetPivot().Position - HolePosition).Magnitude
            
            Power = PowerFunction(Distance)
        end

        if NearestCheckpoint.Goal then
            local LocalPosition = AutomationController.FetchPosition()
            local GoalPosition = NearestCheckpoint.Goal
            local Distance = (LocalPosition - GoalPosition).Magnitude
            Power = MathController.CalculatePower(Distance)
            AimDirection = CFrame.lookAt(LocalPosition, GoalPosition).LookVector * Vector3.new(1, 0, 1)
        end

        AutomationController.AlignAim(AimDirection)
        AutomationController.InsertPower(Power)
        AutomationController.LastUsedCheckpoint = NearestCheckpoint
    end,

    ['S'] = function()
        local SettingsController = _G.Modules.Settings
        
        if UserInputService:IsKeyDown("LeftControl") then
            SettingsController.PushHoleSettings(true)
        end
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