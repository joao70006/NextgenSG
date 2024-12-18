-- Services

-- Variables

-- Modules
local MathController = {}

-- Functions
local function CalculatePower(Distance: number): number
    return math.sqrt(Distance / 0.075)
end

local function CalculateDistance(Power: number): number
    return (Power^2) / (40/3)
end

local function CalculateDirection(TargetPosition: Vector3): Vector3 
    local GameController = _G.Modules.Game
    local LocalBall = GameController.FetchLocalBall()

    if not LocalBall then
        return warn('LocalBall not found | 06')
    end

    local Origin = LocalBall:GetPivot().Position
    local Direction = CFrame.lookAt(Origin, TargetPosition).LookVector
    
    return Direction
end

local function CalculateBezier(Points: table, i: number): number
    local P0, P1, P2, P3, P4 = table.unpack(Points)
    
    local C0 = P0 + (P1 - P0) * i
    local C1 = P1 + (P2 - P1) * i
    local C2 = P2 + (P3 - P2) * i
    local C3 = P3 + (P4 - P3) * i

    local A0 = C0 + (C1 - C0) * i
    local A1 = C1 + (C2 - C1) * i
    local A2 = C2 + (C3 - C2) * i

    local B0 = A0 + (A1 - A0) * i
    local B1 = A1 + (A2 - A1) * i

    local Path = B0 + (B1 - B0) * i

    return Path
end

local function CalculateBezierAverage(): table
    local SettingsController = _G.Modules.Settings
    local AutomationController = _G.Modules.Automation
    local DrawingController = _G.Modules.Drawing

    local HoleSettings = SettingsController.FetchHoleSettings()
    local Checkpoints = HoleSettings.Checkpoints
    local NearestCheckpoint = AutomationController.FetchNearestCheckpoint()

    if #Checkpoints < 5 then
        return warn('Not enough checkpoints | Math.CalculateBezierAverage')
    end

    if not NearestCheckpoint then
        return warn('Nearest checkpoint not found | Math.CalculateBezierAverage')
    end

    local NearestDirection = NearestCheckpoint.Direction

    if not NearestDirection then
        return
    end

    local SimilarCheckpoints = {}

    for Index, Checkpoint in Checkpoints do
        local Direction = Checkpoint.Direction
        
        if not Checkpoint.Direction then
            continue
        end

        local Difference = (NearestDirection - Direction).Magnitude

        if Difference >= 0.1 then
            continue
        end

        table.insert(SimilarCheckpoints, Checkpoint)
    end

    if #SimilarCheckpoints < 5 then
        return
    end

    local SimilarNearestCheckpoints = {}

    for i=1, 5 do
        local NearestDistance = math.huge
        local SimilarNearestCheckpoint = nil

        for _, Checkpoint in SimilarCheckpoints do
            local Distance = (Checkpoint.Position - NearestCheckpoint.Position).Magnitude
    
            if Distance < NearestDistance then
                NearestDistance = Distance
                SimilarNearestCheckpoint = Checkpoint
            end
        end

        table.insert(SimilarNearestCheckpoints, SimilarNearestCheckpoint)
        table.remove(SimilarCheckpoints, table.find(SimilarCheckpoints, SimilarNearestCheckpoint))
    end
    
    for _, Checkpoint in SimilarNearestCheckpoints do
        DrawingController.DrawCheckpoint('', Checkpoint, 3, {Color = Color3.fromRGB(0, 255, 255)})
    end

    local Positions = {}
    local Directions = {}
    local Powers = {}

    for _, Checkpoint in SimilarNearestCheckpoints do
        table.insert(Positions, Checkpoint.Position)
        table.insert(Directions, Checkpoint.Direction)
        table.insert(Powers, Checkpoint.Power)
    end

    local Origin = AutomationController.FetchPosition()
    local NearestDistance = math.huge
    local Coefficient = 0

    for i=0, 1, 0.001 do
        local Position = CalculateBezier(Positions, i)
        local Distance = (Position - Origin).Magnitude
    
        if Distance < NearestDistance then
            NearestDistance = Distance
            Coefficient = i
        end
    end

    local Direction = CalculateBezier(Directions, Coefficient)
    local Power = CalculateBezier(Powers, Coefficient)

    local NewCheckpoint = {
        Position = Origin,
        Direction = Direction,
        Power = Power
    }

    DrawingController.DrawCheckpoint('', NewCheckpoint, 3, {Color = Color3.new(1, 1, 0)})

    return NewCheckpoint
end

MathController.CalculatePower = CalculatePower
MathController.CalculateDistance = CalculateDistance
MathController.CalculateDirection = CalculateDirection
MathController.CalculateBezierAverage = CalculateBezierAverage

return MathController