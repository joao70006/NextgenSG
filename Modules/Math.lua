-- Services

-- Variables

-- Modules
local MathController = {}
local GameController = _G.Require('Modules/Game')

-- Functions
local function CalculatePower(Distance: number): number
    return math.sqrt(Distance / 0.075)
end

local function CalculateDistance(TargetPosition: Vector3): number
    local LocalBall = GameController.FetchLocalBall()

    if not LocalBall then
        return warn('LocalBall not found | 04')
    end
    
    local Origin = LocalBall:GetPivot().Position * Vector3.new(1, 0, 1)
    local Goal = TargetPosition * Vector3.new(1, 0, 1)
    local Distance = (Origin - Goal).Magnitude

    return Distance
end

local function CalculateDirection(TargetPosition: Vector3): Vector3 
    local LocalBall = GameController.FetchLocalBall()

    if not LocalBall then
        return warn('LocalBall not found | 06')
    end

    local Origin = LocalBall:GetPivot().Position
    local Direction = CFrame.lookAt(Origin, TargetPosition).LookVector
    
    return Direction
end

MathController.CalculatePower = CalculatePower
MathController.CalculateDistance = CalculateDistance
MathController.CalculateDirection = CalculateDirection

return MathController