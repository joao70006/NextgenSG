-- Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules

-- Variables--
local KeyFunctions = {
    ['One'] = function()
        local GameController = _G.Modules.Game
        
        local LastHole = ReplicatedStorage.Remotes.Admin.LastHole
        local NextHole = ReplicatedStorage.Remotes.Admin.NextHole
        
        local CurrentHole = GameController.FetchHole()

        ReplicatedStorage.Remotes.Game.Disconnect:FireServer()

        if CurrentHole == '18' then
            LastHole:FireServer()

            task.wait(1/4)

            NextHole:FireServer()
        else
            NextHole:FireServer()

            task.wait(1/4)

            LastHole:FireServer()
        end

        task.wait(1/10)

        ReplicatedStorage.Remotes.Game.Play:FireServer()
    end,

    ['E'] = function()
        local DrawingController = _G.Modules.Drawing
        local MathController = _G.Modules.Math
        local AutomationController = _G.Modules.Automation
        local GameController = _G.Modules.Game

        local CurrentPower = GameController.FetchPower()
        local Origin = AutomationController.FetchPosition()
        local Distance = MathController.CalculateDistance(CurrentPower)
        local LookVector = workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1)

        local FinalPosition = Origin + (LookVector * Distance)

        local NewCheckpoint = {
            Position = FinalPosition,
        }

        repeat task.wait() until not UserInputService:IsKeyDown("E")

        DrawingController.DrawCheckpoint('', NewCheckpoint, 1, {Color = Color3.new(0.4, 0.5, 1)})
    end,

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

    ['C'] = function()
        local AutomationController = _G.Modules.Automation
        local GameController = _G.Modules.Game
        local MathController = _G.Modules.Math

        local HolePosition = GameController.FetchHolePosition()  
        local LocalBallPosition = GameController.FetchLocalBall():GetPivot().Position
        local Distance = (LocalBallPosition * Vector3.new(1, 0, 1) - HolePosition * Vector3.new(1, 0, 1)).Magnitude
        local AimDirection = CFrame.lookAt(LocalBallPosition, HolePosition).LookVector * Vector3.new(1, 0, 1)
        local Power = MathController.CalculatePower(Distance)

        AutomationController.AlignAim(AimDirection)
        AutomationController.InsertPower(Power)
    end,

    ['Q'] = function()
        local AutomationController = _G.Modules.Automation
        local GameController = _G.Modules.Game
        local MathController = _G.Modules.Math
        local DrawingController = _G.Modules.Drawing

        local AimDirection, Power
        local NearestCheckpoint = AutomationController.FetchNearestCheckpoint()
        local Checkpoint = NearestCheckpoint
        
        if UserInputService:IsKeyDown("LeftControl") then
            local OptimalCheckpoint = MathController.CalculateBezierAverage()
            
            Checkpoint = OptimalCheckpoint
        end

        if not Checkpoint then
            return
        end

        -- Patch Position
        Checkpoint.Position = AutomationController.FetchPosition()

        -- Execute Checkpoint
        if Checkpoint.AutoHole or Checkpoint.AimToHole then
            local HolePosition = GameController.FetchHolePosition()  
            local LocalBallPosition = GameController.FetchLocalBall():GetPivot().Position
            local Distance = (LocalBallPosition * Vector3.new(1, 0, 1) - HolePosition * Vector3.new(1, 0, 1)).Magnitude
            
            AimDirection = CFrame.lookAt(LocalBallPosition, HolePosition).LookVector * Vector3.new(1, 0, 1)
            
            if Checkpoint.AutoHole then
                Power = MathController.CalculatePower(Distance)
            elseif not Checkpoint.AutoHole then
                Power = Checkpoint.Power
            end
        elseif not Checkpoint.AutoHole then
            AimDirection = Checkpoint.Direction
            Power = Checkpoint.Power
        end

        if Checkpoint.PowerFunction then
            local Map = GameController.FetchMap()
            local Hole = GameController.FetchHole()
            local PowerFunctions = loadstring(game:HttpGet('http://127.0.0.1:5500/Settings/PowerFunctions.lua', true))()
            local PowerFunction = PowerFunctions[`{Map}{Hole}`]
            local LocalBall = GameController.FetchLocalBall()
            local HolePosition = GameController.FetchHolePosition()
            local Distance = (LocalBall:GetPivot().Position - HolePosition).Magnitude
            
            Power = PowerFunction(Distance)
        end

        if Checkpoint.Goal then
            local LocalPosition = AutomationController.FetchPosition()
            local GoalPosition = Checkpoint.Goal
            local Distance = (LocalPosition - GoalPosition).Magnitude
            Power = Checkpoint.Power or MathController.CalculatePower(Distance)
            AimDirection = CFrame.lookAt(LocalPosition, GoalPosition).LookVector * Vector3.new(1, 0, 1)
        end

        --DrawingController.DrawCheckpoint(0, NearestCheckpoint, 3, {Color = Color3.new(0, 0, 0)})
        
        AutomationController.AlignAim(AimDirection)
        AutomationController.InsertPower(Power)
        AutomationController.LastUsedCheckpoint = Checkpoint
    
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